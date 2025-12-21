// 위치 관리 Provider
//
// 앱의 위치 관련 로직을 관리하는 Provider입니다.
// GPS 권한 요청, 위치 추적, Firestore 업데이트 등을 담당합니다.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:mochi_app/services/database_service.dart';

/// 위치 관리를 담당하는 Provider입니다.
///
/// ChangeNotifier를 상속하여 위치 변경 시 UI에 알림을 보냅니다.
class LocationProvider extends ChangeNotifier {
  // Location 인스턴스
  final Location _location = Location();

  // 위치 스트림 구독 관리 변수
  StreamSubscription<LocationData>? _locationSubscription;

  // 현재 위치 데이터
  LocationData? _currentLocation;

  // 현재 상태 (기본값: '말랑')
  String _currentStatus = '☁️ 말랑 (수신 대기)';

  /// 현재 위치 데이터를 반환합니다.
  LocationData? get currentLocation => _currentLocation;

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
      // 1. GPS 서비스가 켜져 있는지 확인
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        // 2. 안 켜져 있으면 켜달라고 요청
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          // GPS 서비스를 켜지 않으면 위치를 가져올 수 없습니다.
          // ignore: avoid_print
          print('GPS 서비스가 활성화되지 않았습니다.');
          return;
        }
      }

      // 3. GPS 권한이 있는지 확인
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        // 4. 권한이 없으면 요청
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          // 권한이 거부되면 위치를 가져올 수 없습니다.
          // ignore: avoid_print
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      // 5. 모든 것이 '허용(granted)'되면, 현재 위치 가져오기
      LocationData locationData = await _location.getLocation();
      _currentLocation = locationData;
      notifyListeners();

      // 6. 실시간 위치 감지 스트림 구독
      _locationSubscription = _location.onLocationChanged.listen(
        (LocationData currentLocation) {
          _currentLocation = currentLocation;
          notifyListeners();

          // DB에 내 실시간 위치 업데이트 (현재 상태 포함)
          _updateLocation(currentLocation);
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
  /// [locationData] 업데이트할 위치 데이터
  Future<void> _updateLocation(LocationData locationData) async {
    try {
      await DatabaseService.instance.updateUserLocation(
        locationData,
        status: _currentStatus,
      );
    } catch (e) {
      // 위치 업데이트 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error updating location in Firestore: $e');
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
      if (_currentLocation != null &&
          _currentLocation!.latitude != null &&
          _currentLocation!.longitude != null) {
        await DatabaseService.instance.updateUserLocation(
          _currentLocation!,
          status: newStatus,
        );
      } else {
        // 현재 위치가 없으면 위치를 가져온 후 업데이트
        final locationData = await _location.getLocation();
        if (locationData.latitude != null && locationData.longitude != null) {
          _currentLocation = locationData;
          notifyListeners();
          await DatabaseService.instance.updateUserLocation(
            locationData,
            status: newStatus,
          );
        }
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
  Future<LocationData?> getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      _currentLocation = locationData;
      notifyListeners();
      return locationData;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting current location: $e');
      return null;
    }
  }

  @override
  void dispose() {
    // 화면이 꺼지면(dispose), GPS 스트림을 '취소(cancel)'하여 배터리 낭비를 막습니다.
    _locationSubscription?.cancel();
    super.dispose();
  }
}

