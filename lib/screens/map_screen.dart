// 지도 화면
//
// Google Maps를 사용하여 지도를 표시하고 현재 위치를 추적하는 화면입니다.
// 친구들의 실시간 위치를 마커로 표시합니다.
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mochi_app/services/ai_service.dart';
import 'package:mochi_app/services/auth_service.dart';
import 'package:mochi_app/services/database_service.dart';
import 'package:mochi_app/utils/marker_generator.dart';

/// 지도 화면
///
/// 앱의 메인 기능 중 하나인 지도 정보를 표시하는 화면입니다.
/// 현재 위치를 추적하고 지도에 표시하며, 친구들의 실시간 위치를 마커로 표시합니다.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 서울 시청 근처의 임시 위도/경도
  static final CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780), // 서울 시청 좌표
    zoom: 14.0,
  );

  // GoogleMapController를 저장할 변수
  GoogleMapController? _mapController;

  // Location 인스턴스
  final Location _location = Location();

  // 위치 스트림 구독 관리 변수
  StreamSubscription<LocationData>? _locationSubscription;

  // 상태 옵션 정의 (이모지와 설명)
  final Map<String, String> _statusOptions = {
    '🔥': '굽기 (즉시 만남)',
    '☁️': '말랑 (수신 대기)',
    '🧊': '단단 (방해 금지)',
    '🍡': '꼬치 (약속 있음)',
  };

  // 현재 선택된 상태 (기본값: '말랑')
  String _currentStatus = '☁️ 말랑 (수신 대기)';

  @override
  void initState() {
    super.initState();
    // 화면이 초기화될 때 GPS 권한을 요청하고 카메라를 현재 위치로 이동시킵니다.
    _requestLocationPermissionAndMoveCamera();
  }

  /// GPS 권한을 요청하고 현재 위치로 카메라를 이동시키는 메서드입니다.
  Future<void> _requestLocationPermissionAndMoveCamera() async {
    try {
      // 1. GPS 서비스가 켜져 있는지 확인 (location.serviceEnabled())
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        // 2. 안 켜져 있으면 켜달라고 요청 (location.requestService())
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          // GPS 서비스를 켜지 않으면 위치를 가져올 수 없습니다.
          return;
        }
      }

      // 3. GPS 권한이 있는지 확인 (location.hasPermission())
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        // 4. 권한이 없으면 요청 (location.requestPermission())
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          // 권한이 거부되면 위치를 가져올 수 없습니다.
          return;
        }
      }

      // 5. 모든 것이 '허용(granted)'되면,
      // 6. '현재 위치' 가져오기 (location.getLocation())
      LocationData locationData = await _location.getLocation();

      // 7. 'GoogleMapController'를 사용해 '현재 위치'로 카메라를 '애니메이션(animateCamera)' 이동.
      if (_mapController != null && mounted) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                locationData.latitude ?? _kInitialPosition.target.latitude,
                locationData.longitude ?? _kInitialPosition.target.longitude,
              ),
              zoom: 15.0,
            ),
          ),
        );
      }

      // '현재 위치'를 가져오는 `location.getLocation()` *'뒤'*에,
      // '실시간' 위치 감지 스트림을 '추가'합니다.
      _locationSubscription = _location.onLocationChanged.listen(
        (LocationData currentLocation) {
          // (1) DB에 내 실시간 위치 업데이트 (현재 상태 포함)
          DatabaseService.instance.updateUserLocation(
            currentLocation,
            status: _currentStatus,
          );

          // (2) TODO: (다음 단계) 친구 마커들도 이 위치 기반으로 다시 그림
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

  /// GoogleMapController를 초기화하는 콜백 메서드입니다.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// 친구 위치 문서들을 기반으로 커스텀 마커를 생성하는 메서드입니다.
  ///
  /// [locationDocs] 친구 위치 문서 리스트
  /// 반환값: 생성된 커스텀 마커 세트
  Future<Set<Marker>> _buildCustomMarkers(
      List<QueryDocumentSnapshot> locationDocs) async {
    final Set<Marker> markers = {};

    for (var doc in locationDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final geoPoint = data['position'] as GeoPoint?;

      // GeoPoint가 유효한 경우에만 마커를 추가합니다.
      if (geoPoint != null) {
        final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        // 친구의 상태와 이름을 가져옵니다.
        final status = data['status'] as String? ?? '☁️ 말랑 (수신 대기)';
        final statusEmoji = status.split(' ').first; // 이모지만 추출 (예: '🔥')

        // 친구의 프로필 정보를 가져와서 이름을 가져옵니다.
        final friendProfile =
            await DatabaseService.instance.getUserProfile(doc.id);
        final friendName = friendProfile?.displayName ?? '친구';

        // 커스텀 마커 비트맵 생성
        final customIcon = await MarkerGenerator.createCustomMarkerBitmap(
          friendName,
          statusEmoji,
        );

        // 마커 추가
        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: latLng,
            icon: customIcon,
            infoWindow: InfoWindow(
              title: friendName,
              snippet: status,
            ),
          ),
        );
      }
    }

    return markers;
  }

  /// 상태를 변경하고 즉시 DB에 반영하는 메서드입니다.
  ///
  /// [newStatus] 새로 선택한 상태 (예: '🔥 굽기 (즉시 만남)')
  Future<void> _changeStatus(String newStatus) async {
    // 1. 상태 변수 업데이트
    setState(() {
      _currentStatus = newStatus;
    });

    // 2. 즉시 DB에 반영 (현재 위치 + 새 상태)
    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        await DatabaseService.instance.updateUserLocation(
          locationData,
          status: newStatus,
        );
      }
    } catch (e) {
      // 상태 변경 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error updating status: $e');
    }
  }

  /// AI를 사용하여 현재 위치와 시간을 기반으로 상태를 추천받는 메서드입니다.
  Future<void> _requestAIStatusSuggestion() async {
    // 로딩 인디케이터 표시
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('AI가 상태를 추천하고 있어요...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      // 1. 현재 위치 가져오기
      final locationData = await _location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치를 가져올 수 없습니다.'),
          ),
        );
        return;
      }

      // 2. AI 서비스를 통해 상태 추천 받기
      final suggestedStatus = await AIService.instance.suggestStatus(
        locationData.latitude!,
        locationData.longitude!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // 3. AI 추천 결과를 보여주는 다이얼로그 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🤖 AI의 제안'),
            content: Text(
              "지금 **'$suggestedStatus'** 상태이신가요?",
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              // '아니요' 버튼
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('아니요'),
              ),
              // '네, 변경할게요' 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 상태 변경
                  _changeStatus(suggestedStatus);
                },
                child: const Text('네, 변경할게요'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI 추천 중 오류가 발생했습니다: $e'),
        ),
      );
    }
  }

  /// 상태 선택 UI를 하단 시트로 표시하는 메서드입니다.
  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              const Text(
                '상태 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // 상태 옵션 리스트
              ListView.builder(
                shrinkWrap: true,
                itemCount: _statusOptions.length,
                itemBuilder: (context, index) {
                  final emoji = _statusOptions.keys.elementAt(index);
                  final description = _statusOptions[emoji]!;
                  final statusText = '$emoji $description';

                  return ListTile(
                    leading: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(description),
                    // 현재 선택된 상태인지 확인
                    selected: _currentStatus == statusText,
                    onTap: () {
                      // 상태 변경 및 시트 닫기
                      _changeStatus(statusText);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mochi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 로그아웃 버튼 클릭 시 AuthService.signOut() 호출
              await AuthService.instance.signOut();
              // AuthGate가 스트림을 감지하고 자동으로 로그인 화면으로 보낼 것임
            },
          ),
        ],
      ),
      // 1. (Stream 1) '내 친구' 목록을 가져옵니다.
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.instance.getMyFriendsStream(), // [Op 14]에서 만듦
        builder: (context, friendsSnapshot) {
          // '친구 목록'을 가져오는 중이면, '빈 지도'를 표시
          if (!friendsSnapshot.hasData) {
            return GoogleMap(
              initialCameraPosition: _kInitialPosition,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
              onMapCreated: _onMapCreated, // 컨트롤러는 유지
              markers: {}, // 마커 0개
            );
          }

          // '친구 목록'을 uid 리스트로 변환
          final friendUids = friendsSnapshot.data!.docs
              .map((doc) => doc.id)
              .toList();

          // 친구가 없는 경우에도 지도를 표시합니다.
          if (friendUids.isEmpty) {
            return GoogleMap(
              initialCameraPosition: _kInitialPosition,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
              onMapCreated: _onMapCreated,
              markers: {}, // 마커 0개
            );
          }

          // 2. (Stream 2) '친구들의 실시간 위치'를 가져옵니다.
          return StreamBuilder<QuerySnapshot>(
            stream: DatabaseService.instance
                .getFriendsLocationsStream(friendUids), // [Op 18]에서 만듦
            builder: (context, locationSnapshot) {
              // '친구 위치'를 가져오는 중이거나 데이터가 없어도, '지도'는 계속 표시

              // --- 여기가 핵심 수정 ---
              // 'builder' 함수 '내부'에서 마커 세트를 '새로' 생성합니다.
              // 'setState'를 호출하지 않습니다. (Reactive 방식)
              // 커스텀 마커 생성을 위한 FutureBuilder 사용
              if (locationSnapshot.hasData && locationSnapshot.data!.docs.isNotEmpty) {
                // 친구 위치 데이터가 있으면, 각 친구에 대해 커스텀 마커를 생성합니다.
                return FutureBuilder<Set<Marker>>(
                  future: _buildCustomMarkers(locationSnapshot.data!.docs),
                  builder: (context, markersSnapshot) {
                    if (markersSnapshot.connectionState == ConnectionState.waiting) {
                      // 마커 생성 중일 때는 기본 지도 표시
                      return GoogleMap(
                        initialCameraPosition: _kInitialPosition,
                        mapType: MapType.normal,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        zoomControlsEnabled: true,
                        compassEnabled: true,
                        onMapCreated: _onMapCreated,
                        markers: {},
                      );
                    }

                    // 생성된 커스텀 마커 세트를 사용
                    final friendMarkers = markersSnapshot.data ?? {};

                    return GoogleMap(
                      initialCameraPosition: _kInitialPosition,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomControlsEnabled: true,
                      compassEnabled: true,
                      onMapCreated: _onMapCreated,
                      markers: friendMarkers,
                    );
                  },
                );
              }

              // 친구 위치 데이터가 없을 때는 빈 마커 세트로 지도 표시
              Set<Marker> friendMarkers = {};
              // --- 여기까지 ---

              // 'StreamBuilder'는 'GoogleMap' 위젯을 '반환'합니다.
              // 'builder'가 재실행될 때마다, '새로운' 마커 세트가 지도에 전달됩니다.
              return GoogleMap(
                // 초기 카메라 위치 설정 (서울 시청 근처)
                initialCameraPosition: _kInitialPosition,
                // 지도 타입 설정 (일반 지도)
                mapType: MapType.normal,
                // 내 위치 버튼 활성화 ('내 위치로 이동' 버튼 활성화)
                myLocationButtonEnabled: true,
                // 내 위치 표시 활성화 (내 위치 '파란 점' 활성화)
                myLocationEnabled: true,
                // 줌 컨트롤 활성화
                zoomControlsEnabled: true,
                // 컴패스 활성화
                compassEnabled: true,
                // GoogleMapController를 초기화하는 콜백
                onMapCreated: _onMapCreated,
                // '새로' 만든 로컬 마커 세트를 전달 (Reactive 방식)
                markers: friendMarkers,
              );
            },
          );
        },
      ),
      // AI 버튼과 상태 변경 버튼을 세로로 배치
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI 추천 버튼 (위쪽)
          FloatingActionButton.small(
            onPressed: _requestAIStatusSuggestion,
            heroTag: 'ai_btn', // 고유한 heroTag 필요
            backgroundColor: Colors.white,
            child: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
          ),
          // 간격
          const SizedBox(height: 10),
          // 상태 변경 버튼 (아래쪽)
          FloatingActionButton(
            onPressed: _showStatusPicker,
            heroTag: 'status_btn', // 고유한 heroTag 필요
            child: Text(
              // 현재 상태의 이모지만 표시 (예: '🔥')
              _currentStatus.split(' ').first,
              style: const TextStyle(fontSize: 24),
            ),
            tooltip: '상태 변경',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 화면이 꺼지면(dispose), GPS 스트림을 '취소(cancel)'하여 배터리 낭비를 막습니다.
    _locationSubscription?.cancel();

    // 메모리 누수를 방지하기 위해 컨트롤러를 정리합니다.
    _mapController?.dispose();
    super.dispose();
  }
}
