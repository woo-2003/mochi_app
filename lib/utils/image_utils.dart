// 이미지 유틸리티
//
// 에셋 이미지를 Google Maps 마커로 사용할 수 있도록 변환하는 유틸리티 함수를 제공합니다.
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 에셋 이미지 경로와 원하는 너비를 받아서 BitmapDescriptor로 변환하는 함수입니다.
///
/// [assetPath] 에셋 이미지 경로 (예: 'lib/assets/images/marker_mochi.png')
/// [width] 원하는 마커 너비 (픽셀 단위)
/// 반환값: Google Maps 마커로 사용할 수 있는 BitmapDescriptor
Future<BitmapDescriptor> getBytesFromAsset(
  String assetPath,
  int width,
) async {
  // 1. 에셋 이미지를 ByteData로 로드
  final ByteData data = await rootBundle.load(assetPath);
  
  // 2. ByteData를 Uint8List로 변환
  final Uint8List bytes = data.buffer.asUint8List();
  
  // 3. 이미지를 디코딩
  final ui.Codec codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: width,
  );
  
  // 4. 프레임을 가져와서 이미지로 변환
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;
  
  // 5. 이미지를 ByteData로 변환
  final ByteData? imageData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  
  if (imageData == null) {
    throw Exception('이미지를 ByteData로 변환하는데 실패했습니다.');
  }
  
  // 6. BitmapDescriptor 생성
  return BitmapDescriptor.fromBytes(imageData.buffer.asUint8List());
}

