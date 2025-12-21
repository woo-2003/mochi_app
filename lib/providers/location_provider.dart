// 위치 관리 Provider
//
// 앱의 위치 관련 로직을 관리하는 Provider입니다.
// GPS 권한 요청, 위치 추적, Firestore 업데이트 등을 담당합니다.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mochi_app/services/database_service.dart';
import 'package:mochi_app/services/gemini_service.dart';

/// 위치 관리를 담당하는 Provider입니다.
///
/// ChangeNotifier를 상속하여 위치 변경 시 UI에 알림을 보냅니다.
class LocationProvider extends ChangeNotifier {
  // 위치 스트림 구독 관리 변수
  StreamSubscription<Position>? _positionSubscription;

  // 현재 위치 데이터
  Position? _currentLocation;

  // 현재 상태 (기본값: '말랑')
  String _currentStatus = '☁️ 말랑 (수신 대기)';

  // AI 상태 추론을 위한 마지막 업데이트 시간 (너무 자주 호출 방지)
  DateTime? _lastAIUpdateTime;

  // AI 상태 추론을 위한 마지막 위치 (일정 거리 이동 시에만 호출)
  Position? _lastAILocation;

  /// 현재 위치 데이터를 반환합니다.
  Position? get currentLocation => _currentLocation;

  /// 현재 상태를 반환합니다.
  String get currentStatus => _currentStatus;

  /// 현재 위치의 위도를 반환합니다.
  double? get latitude => _currentLocation?.latitude;

  /// 현재 위치의 경도를 반환합니다.
  double? get longitude => _currentLocation?.longitude;

  LocationProvider() {
    // Provider 생성 시 위치 추적 시작
    _initializeLocation();
  }

  /// 위치 추적을 초기화합니다.
  ///
  /// GPS 권한을 요청하고 위치 스트림을 구독합니다.
  Future<void> _initializeLocation() async {
    try {
      // 1. 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // GPS 서비스를 켜지 않으면 위치를 가져올 수 없습니다.
        // ignore: avoid_print
        print('GPS 서비스가 활성화되지 않았습니다.');
        return;
      }

      // 2. 위치 권한이 있는지 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // 3. 권한이 없으면 요청
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          // 권한이 거부되면 위치를 가져올 수 없습니다.
          // ignore: avoid_print
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      // 4. 모든 것이 '허용'되면, 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _currentLocation = position;
      _lastAILocation = position;

      // 초기 위치 로드 시 AI 상태 추론
      await _updateStatusWithAI(position);

      notifyListeners();

      // 5. 실시간 위치 감지 스트림 구독
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // 10미터 이상 이동 시에만 업데이트
            ),
          ).listen(
            (Position currentPosition) {
              _currentLocation = currentPosition;
              notifyListeners();

              // DB에 내 실시간 위치 업데이트 (현재 상태 포함)
              _updateLocation(currentPosition);

              // 일정 거리 이동 시 AI 상태 추론 (너무 자주 호출 방지)
              _checkAndUpdateStatusWithAI(currentPosition);
            },
            onError: (error) {
              // 위치 스트림에서 오류가 발생한 경우 로깅합니다.
              // ignore: avoid_print
              print('Error in location stream: $error');
            },
          );
    } catch (e) {
      // 위치 권한 요청 또는 위치 가져오기 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error getting location: $e');
    }
  }

  /// 위치를 Firestore에 업데이트합니다.
  ///
  /// [position] 업데이트할 위치 데이터
  Future<void> _updateLocation(Position position) async {
    try {
      await DatabaseService.instance.updateUserLocation(
        position,
        status: _currentStatus,
      );
    } catch (e) {
      // 위치 업데이트 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error updating location in Firestore: $e');
    }
  }

  /// 일정 거리 이동 시 AI 상태 추론을 수행합니다.
  ///
  /// [position] 현재 위치 데이터
  /// 100미터 이상 이동했거나 5분 이상 경과했을 때만 AI 호출
  Future<void> _checkAndUpdateStatusWithAI(Position position) async {
    // 마지막 AI 업데이트 위치가 없으면 업데이트
    if (_lastAILocation == null) {
      await _updateStatusWithAI(position);
      return;
    }

    // 거리 계산 (미터 단위) - Geolocator의 distanceBetween 사용
    final distance = Geolocator.distanceBetween(
      _lastAILocation!.latitude,
      _lastAILocation!.longitude,
      position.latitude,
      position.longitude,
    );

    // 시간 체크 (마지막 업데이트로부터 5분 경과)
    final now = DateTime.now();
    final timeSinceLastUpdate = _lastAIUpdateTime != null
        ? now.difference(_lastAIUpdateTime!)
        : const Duration(minutes: 10);

    // 100미터 이상 이동했거나 5분 이상 경과했을 때만 AI 호출
    if (distance >= 100 || timeSinceLastUpdate.inMinutes >= 5) {
      await _updateStatusWithAI(position);
    }
  }

  /// AI를 사용하여 상태를 추론하고 업데이트합니다.
  ///
  /// [position] 현재 위치 데이터
  Future<void> _updateStatusWithAI(Position position) async {
    try {
      // 1. 좌표를 주소로 변환
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // 2. 주소 텍스트 생성 (거리명/건물명 우선, 없으면 지역명)
      String address = '알 수 없는 위치';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        address =
            placemark.street ?? placemark.name ?? placemark.locality ?? address;
      }

      // 3. 현재 시간 가져오기
      final now = DateTime.now();

      // 4. AI를 사용하여 활동 추론
      final aiStatus = await GeminiService.instance.guessActivity(address, now);

      // 5. 상태 업데이트
      _currentStatus = aiStatus;
      _lastAIUpdateTime = now;
      _lastAILocation = position;
      notifyListeners();

      // 6. DB에도 업데이트
      await DatabaseService.instance.updateUserLocation(
        position,
        status: aiStatus,
      );
    } catch (e) {
      // AI 상태 추론 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error updating status with AI: $e');
    }
  }

  /// 상태를 변경하고 즉시 DB에 반영합니다.
  ///
  /// [newStatus] 새로 선택한 상태 (예: '🔥 굽기 (즉시 만남)')
  Future<void> changeStatus(String newStatus) async {
    // 1. 상태 변수 업데이트
    _currentStatus = newStatus;
    notifyListeners();

    // 2. 즉시 DB에 반영 (현재 위치 + 새 상태)
    try {
      if (_currentLocation != null) {
        await DatabaseService.instance.updateUserLocation(
          _currentLocation!,
          status: newStatus,
        );
      } else {
        // 현재 위치가 없으면 위치를 가져온 후 업데이트
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        _currentLocation = position;
        notifyListeners();
        await DatabaseService.instance.updateUserLocation(
          position,
          status: newStatus,
        );
      }
    } catch (e) {
      // 상태 변경 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error updating status: $e');
    }
  }

  /// 현재 위치를 다시 가져옵니다.
  ///
  /// 반환값: 현재 위치 데이터
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _currentLocation = position;
      notifyListeners();
      return position;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting current location: $e');
      return null;
    }
  }

  @override
  void dispose() {
    // 화면이 꺼지면(dispose), GPS 스트림을 '취소(cancel)'하여 배터리 낭비를 막습니다.
    _positionSubscription?.cancel();
    super.dispose();
  }
}
