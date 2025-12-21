// 지도 화면
//
// Google Maps를 사용하여 지도를 표시하고 현재 위치를 추적하는 화면입니다.
// 친구들의 실시간 위치를 마커로 표시합니다.
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mochi_app/services/ai_service.dart';
import 'package:mochi_app/services/database_service.dart';
import 'package:mochi_app/screens/profile_screen.dart';
import 'package:mochi_app/utils/marker_generator.dart';
import 'package:mochi_app/utils/image_utils.dart';
import 'package:provider/provider.dart';
import 'package:mochi_app/providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';

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

  // 최초 1회 위치로 카메라 이동 여부를 체크하는 변수
  bool _hasMovedToInitialLocation = false;

  // 현재 사용자 위치 마커 아이콘
  BitmapDescriptor? _myLocationIcon;

  // 친구 위치 마커 아이콘
  BitmapDescriptor? _friendMarkerIcon;

  // 상태 옵션 정의 (이모지와 설명)
  final Map<String, String> _statusOptions = {
    '🔥': '굽기 (즉시 만남)',
    '☁️': '말랑 (수신 대기)',
    '🧊': '단단 (방해 금지)',
    '🍡': '꼬치 (약속 있음)',
  };

  @override
  void initState() {
    super.initState();
    // 마커 아이콘을 미리 로드
    _loadMarkerIcons();
  }

  /// 현재 사용자 및 친구 위치 마커 아이콘을 로드합니다.
  Future<void> _loadMarkerIcons() async {
    try {
      // 내 위치 마커 아이콘 로드
      _myLocationIcon = await getBytesFromAsset(
        'lib/assets/images/marker_mochi.png',
        110, // 적당한 마커 크기 (100~120 범위)
      );

      // 친구 마커 아이콘 로드
      _friendMarkerIcon = await getBytesFromAsset(
        'lib/assets/images/marker_friend.png',
        110, // 적당한 마커 크기 (100~120 범위)
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // ignore: avoid_print
      print('마커 아이콘 로드 실패: $e');
    }
  }

  /// 사용자의 현재 위치로 카메라를 안전하게 이동시키는 메서드입니다.
  ///
  /// [position] 이동할 위치 데이터
  Future<void> _moveCameraToPosition(Position position) async {
    // 안전성 체크: mounted가 false이거나 컨트롤러가 null이면 리턴
    if (!mounted || _mapController == null) return;

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.5, // 적당한 줌 레벨 설정
          ),
        ),
      );
      // 카메라 이동 완료 후 플래그 설정
      if (mounted) {
        setState(() {
          _hasMovedToInitialLocation = true;
        });
      }
    } catch (e) {
      // 지도 컨트롤러가 해제된 경우 무시 (StateError 등)
      // 앱이 죽지 않도록 에러를 무시합니다.
    }
  }

  /// GoogleMapController를 초기화하는 콜백 메서드입니다.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // 컨트롤러가 생성된 후 위치가 이미 로딩되어 있다면 즉시 카메라 이동
    if (!_hasMovedToInitialLocation) {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      if (locationProvider.currentLocation != null) {
        // 화면이 완전히 그려진 후 카메라 이동 (타이밍 이슈 방지)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasMovedToInitialLocation) {
            _moveCameraToPosition(locationProvider.currentLocation!);
          }
        });
      }
    }
  }

  /// 현재 사용자 위치 마커를 생성하는 메서드입니다.
  ///
  /// [locationProvider] 위치 Provider
  /// 반환값: 현재 사용자 위치 마커 (위치가 없으면 null)
  Marker? _buildMyLocationMarker(LocationProvider locationProvider) {
    if (_myLocationIcon == null || locationProvider.currentLocation == null) {
      return null;
    }

    return Marker(
      markerId: const MarkerId('my_location'),
      position: LatLng(
        locationProvider.currentLocation!.latitude,
        locationProvider.currentLocation!.longitude,
      ),
      icon: _myLocationIcon!,
      infoWindow: InfoWindow(
        title: '내 위치',
        snippet: locationProvider.currentStatus, // AI 추론 상태 표시
      ),
    );
  }

  /// 시연 영상 촬영을 위한 데모 모드: 가상 친구 3명의 마커를 생성합니다.
  ///
  /// 반환값: 가상 친구 마커 세트 (친구 마커 이미지 사용)
  Set<Marker> _buildDemoFriendsMarkers() {
    final Set<Marker> demoMarkers = {};

    // 친구 마커 아이콘이 로드되지 않았으면 빈 세트 반환
    if (_friendMarkerIcon == null) {
      return demoMarkers;
    }

    // 친구 1: 미소 - 성결대학교 학술정보관 근처
    demoMarkers.add(
      Marker(
        markerId: const MarkerId('demo_friend_1'),
        position: const LatLng(37.3805, 126.9265),
        icon: _friendMarkerIcon!,
        infoWindow: const InfoWindow(
          title: '미소',
          snippet: '과제 폭파 중 💣',
        ),
      ),
    );

    // 친구 2: 성결 - 성결대학교 운동장 벤치
    demoMarkers.add(
      Marker(
        markerId: const MarkerId('demo_friend_2'),
        position: const LatLng(37.3795, 126.9275),
        icon: _friendMarkerIcon!,
        infoWindow: const InfoWindow(
          title: '성결',
          snippet: '농구 한 판? 🏀',
        ),
      ),
    );

    // 친구 3: 공대 - 학교 앞 카페
    demoMarkers.add(
      Marker(
        markerId: const MarkerId('demo_friend_3'),
        position: const LatLng(37.3810, 126.9255),
        icon: _friendMarkerIcon!,
        infoWindow: const InfoWindow(
          title: '공대',
          snippet: '아아 수혈 시급 ☕',
        ),
      ),
    );

    return demoMarkers;
  }

  /// 친구 위치 문서들을 기반으로 커스텀 마커를 생성하는 메서드입니다.
  ///
  /// [locationDocs] 친구 위치 문서 리스트
  /// 반환값: 생성된 커스텀 마커 세트
  Future<Set<Marker>> _buildCustomMarkers(
    List<QueryDocumentSnapshot> locationDocs,
  ) async {
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
        final friendProfile = await DatabaseService.instance.getUserProfile(
          doc.id,
        );
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
            infoWindow: InfoWindow(title: friendName, snippet: status),
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
    if (!mounted) return;

    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    // Provider의 changeStatus 메서드를 호출하여 상태 변경 및 DB 업데이트
    await locationProvider.changeStatus(newStatus);
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
      // 1. Provider에서 현재 위치 가져오기
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      final position = await locationProvider.getCurrentLocation();

      if (position == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('위치를 가져올 수 없습니다.')));
        return;
      }

      // 2. AI 서비스를 통해 상태 추천 받기
      final suggestedStatus = await AIService.instance.suggestStatus(
        position.latitude,
        position.longitude,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI 추천 중 오류가 발생했습니다: $e')));
    }
  }

  /// 상태 선택 UI를 하단 시트로 표시하는 메서드입니다.
  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            final currentStatus = locationProvider.currentStatus;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목
                  const Text(
                    '상태 선택',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        selected: currentStatus == statusText,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mochi'),
        actions: [
          // 프로필 버튼 (원형 이미지)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                // 프로필 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: const AssetImage(
                  'lib/assets/images/profile_placeholder.png',
                ),
                onBackgroundImageError: (exception, stackTrace) {
                  // 이미지 로드 실패 시 기본 아이콘 사용
                },
                child: const Icon(Icons.person, size: 20),
              ),
            ),
          ),
        ],
      ),
      // 1. (Stream 1) '내 친구' 목록을 가져옵니다.
      body: Stack(
        children: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
          // 위치가 로딩되었고 아직 카메라를 이동하지 않았다면 자동으로 이동
          // Race Condition 방지를 위해 addPostFrameCallback 사용
          if (locationProvider.currentLocation != null &&
              !_hasMovedToInitialLocation &&
              _mapController != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // 화면이 완전히 그려진 후에만 카메라 이동 (안전성 체크)
              if (mounted &&
                  !_hasMovedToInitialLocation &&
                  locationProvider.currentLocation != null) {
                _moveCameraToPosition(locationProvider.currentLocation!);
              }
            });
          }

          return StreamBuilder<QuerySnapshot>(
            stream: DatabaseService.instance
                .getMyFriendsStream(), // [Op 14]에서 만듦
            builder: (context, friendsSnapshot) {
              // '친구 목록'을 가져오는 중이면, '빈 지도'를 표시
              if (!friendsSnapshot.hasData) {
                // 현재 사용자 위치 마커 생성
                final myLocationMarker = _buildMyLocationMarker(locationProvider);
                final markers = <Marker>{};
                if (myLocationMarker != null) {
                  markers.add(myLocationMarker);
                }
                // 데모 모드: 가상 친구 3명 추가
                markers.addAll(_buildDemoFriendsMarkers());

                return GoogleMap(
                  initialCameraPosition: _kInitialPosition,
                  mapType: MapType.normal,
                  myLocationEnabled: false, // 커스텀 마커 사용
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  onMapCreated: _onMapCreated, // 컨트롤러는 유지
                  markers: markers,
                );
              }

              // '친구 목록'을 uid 리스트로 변환
              final friendUids = friendsSnapshot.data!.docs
                  .map((doc) => doc.id)
                  .toList();

              // 친구가 없는 경우에도 지도를 표시합니다.
              if (friendUids.isEmpty) {
                // 현재 사용자 위치 마커 생성
                final myLocationMarker = _buildMyLocationMarker(locationProvider);
                final markers = <Marker>{};
                if (myLocationMarker != null) {
                  markers.add(myLocationMarker);
                }
                // 데모 모드: 가상 친구 3명 추가
                markers.addAll(_buildDemoFriendsMarkers());

                return GoogleMap(
                  initialCameraPosition: _kInitialPosition,
                  mapType: MapType.normal,
                  myLocationEnabled: false, // 커스텀 마커 사용
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  onMapCreated: _onMapCreated,
                  markers: markers,
                );
              }

              // 2. (Stream 2) '친구들의 실시간 위치'를 가져옵니다.
              return StreamBuilder<QuerySnapshot>(
                stream: DatabaseService.instance.getFriendsLocationsStream(
                  friendUids,
                ), // [Op 18]에서 만듦
                builder: (context, locationSnapshot) {
                  // '친구 위치'를 가져오는 중이거나 데이터가 없어도, '지도'는 계속 표시

                  // --- 여기가 핵심 수정 ---
                  // 'builder' 함수 '내부'에서 마커 세트를 '새로' 생성합니다.
                  // 'setState'를 호출하지 않습니다. (Reactive 방식)
                  // 커스텀 마커 생성을 위한 FutureBuilder 사용
                  if (locationSnapshot.hasData &&
                      locationSnapshot.data!.docs.isNotEmpty) {
                    // 친구 위치 데이터가 있으면, 각 친구에 대해 커스텀 마커를 생성합니다.
                    return FutureBuilder<Set<Marker>>(
                      future: _buildCustomMarkers(locationSnapshot.data!.docs),
                      builder: (context, markersSnapshot) {
                        if (markersSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          // 마커 생성 중일 때는 기본 지도 표시
                          // 현재 사용자 위치 마커 생성
                          final myLocationMarker =
                              _buildMyLocationMarker(locationProvider);
                          final markers = <Marker>{};
                          if (myLocationMarker != null) {
                            markers.add(myLocationMarker);
                          }
                          // 데모 모드: 가상 친구 3명 추가
                          markers.addAll(_buildDemoFriendsMarkers());

                          return GoogleMap(
                            initialCameraPosition: _kInitialPosition,
                            mapType: MapType.normal,
                            myLocationButtonEnabled: true,
                            myLocationEnabled: false, // 커스텀 마커 사용
                            zoomControlsEnabled: true,
                            compassEnabled: true,
                            onMapCreated: _onMapCreated,
                            markers: markers,
                          );
                        }

                        // 생성된 커스텀 마커 세트를 사용
                        final friendMarkers = markersSnapshot.data ?? {};
                        // 현재 사용자 위치 마커 추가
                        final myLocationMarker =
                            _buildMyLocationMarker(locationProvider);
                        if (myLocationMarker != null) {
                          friendMarkers.add(myLocationMarker);
                        }
                        // 데모 모드: 가상 친구 3명 추가
                        friendMarkers.addAll(_buildDemoFriendsMarkers());

                        return GoogleMap(
                          initialCameraPosition: _kInitialPosition,
                          mapType: MapType.normal,
                          myLocationButtonEnabled: true,
                          myLocationEnabled: false, // 커스텀 마커 사용
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
                  // 현재 사용자 위치 마커 추가
                  final myLocationMarker =
                      _buildMyLocationMarker(locationProvider);
                  if (myLocationMarker != null) {
                    friendMarkers.add(myLocationMarker);
                  }
                  // 데모 모드: 가상 친구 3명 추가
                  friendMarkers.addAll(_buildDemoFriendsMarkers());
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
                    // 내 위치 표시 비활성화 (커스텀 마커 사용)
                    myLocationEnabled: false,
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
          );
          },
          ),
          // 좌측 하단: 내 위치로 이동 버튼 (BottomNavigationBar 위에 배치)
          Positioned(
            left: 16,
            bottom: 80, // BottomNavigationBar 높이(약 56px) + 여백(24px)
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                return FloatingActionButton(
                  onPressed: () {
                    // 현재 위치가 있으면 카메라 이동
                    if (locationProvider.currentLocation != null &&
                        _mapController != null) {
                      _moveCameraToPosition(locationProvider.currentLocation!);
                    } else {
                      // 위치가 없으면 사용자에게 알림
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('현재 위치를 가져올 수 없습니다.'),
                        ),
                      );
                    }
                  },
                  heroTag: 'my_location_btn',
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                  tooltip: '내 위치로 이동',
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
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
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          // 간격
          const SizedBox(height: 10),
          // 상태 변경 버튼 (아래쪽)
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              return FloatingActionButton(
                onPressed: _showStatusPicker,
                heroTag: 'status_btn', // 고유한 heroTag 필요
                tooltip: '상태 변경',
                child: Text(
                  // 현재 상태의 이모지만 표시 (예: '🔥')
                  locationProvider.currentStatus.split(' ').first,
                  style: const TextStyle(fontSize: 24),
                ),
              );
            },
          ),
        ],
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
