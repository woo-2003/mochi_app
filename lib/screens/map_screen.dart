// 지도 화면
//
// Google Maps를 사용하여 지도를 표시하고 현재 위치를 추적하는 화면입니다.
// 친구들의 실시간 위치를 마커로 표시합니다.
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mochi_app/services/auth_service.dart';
import 'package:mochi_app/services/database_service.dart';

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
          // (1) DB에 내 실시간 위치 업데이트
          DatabaseService.instance.updateUserLocation(currentLocation);

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
              Set<Marker> friendMarkers = {}; // '상태' 변수가 아닌 '로컬' 변수

              if (locationSnapshot.hasData) {
                // '친구 위치' 데이터가 있으면, 마커 세트를 '채웁니다'.
                for (var doc in locationSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final geoPoint = data['position'] as GeoPoint?;

                  // GeoPoint가 유효한 경우에만 마커를 추가합니다.
                  if (geoPoint != null) {
                    final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

                    // TODO: 'markerId'는 친구의 uid (doc.id)
                    // TODO: 'icon'은 팀장님의 '모찌' 에셋으로 변경
                    friendMarkers.add(
                      Marker(
                        markerId: MarkerId(doc.id),
                        position: latLng,
                        infoWindow: InfoWindow(title: '친구 ${doc.id}'), // 임시
                      ),
                    );
                  }
                }
              }
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
