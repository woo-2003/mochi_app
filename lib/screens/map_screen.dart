// 지도 화면
//
// Google Maps를 사용하여 지도를 표시하고 현재 위치를 추적하는 화면입니다.
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mochi_app/services/auth_service.dart';

/// 지도 화면
///
/// 앱의 메인 기능 중 하나인 지도 정보를 표시하는 화면입니다.
/// 현재 위치를 추적하고 지도에 표시합니다.
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
    } catch (e) {
      // 위치 권한 요청 또는 위치 가져오기 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error getting location: $e');
    }
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
      body: GoogleMap(
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
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }

  @override
  void dispose() {
    // 메모리 누수를 방지하기 위해 컨트롤러를 정리합니다.
    _mapController?.dispose();
    super.dispose();
  }
}
