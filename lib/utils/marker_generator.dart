// 마커 생성 유틸리티
//
// 이모지와 텍스트를 결합하여 실시간으로 커스텀 마커 이미지를 생성하는 로직입니다.
// 별도의 이미지 파일 없이 Flutter 코드로 UI를 그리고 이를 Bitmap으로 변환하여 지도에 띄웁니다.
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 마커 생성 유틸리티 클래스
///
/// 커스텀 마커 비트맵을 생성하는 정적 메서드를 제공합니다.
class MarkerGenerator {
  /// 커스텀 마커 비트맵을 생성합니다.
  ///
  /// [name] 마커에 표시할 이름
  /// [statusEmoji] 마커에 표시할 상태 이모지 (예: '🔥', '☁️', '🧊', '🍡')
  /// 반환값: 생성된 커스텀 마커 비트맵 디스크립터
  static Future<BitmapDescriptor> createCustomMarkerBitmap(
    String name,
    String statusEmoji,
  ) async {
    // 1. PictureRecorder와 Canvas를 생성합니다.
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);

    // 마커 크기 설정
    const double markerWidth = 120.0;
    const double markerHeight = 80.0;

    // 2. 둥근 배경(Container 느낌)을 그림 (Paint 사용, 색상은 보라색 계열)
    final Paint backgroundPaint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.fill;

    // 둥근 사각형 배경 그리기
    final RRect backgroundRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, markerWidth, markerHeight),
      const Radius.circular(12),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // 테두리 그리기 (선택 사항)
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(backgroundRect, borderPaint);

    // 3. 그 위에 statusEmoji (크게)와 name (작게) 텍스트를 그림 (TextPainter)

    // 이모지 텍스트 그리기 (위쪽)
    final TextPainter emojiPainter = TextPainter(
      text: TextSpan(
        text: statusEmoji,
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    emojiPainter.layout();
    emojiPainter.paint(
      canvas,
      Offset(
        (markerWidth - emojiPainter.width) / 2,
        8, // 상단 여백
      ),
    );

    // 이름 텍스트 그리기 (아래쪽)
    final TextPainter namePainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
      ellipsis: '...',
    );
    namePainter.layout(maxWidth: markerWidth - 16); // 좌우 여백 고려
    namePainter.paint(
      canvas,
      Offset(
        (markerWidth - namePainter.width) / 2,
        markerHeight - namePainter.height - 8, // 하단 여백
      ),
    );

    // 4. picture.toImage()를 통해 BitmapDescriptor로 변환하여 반환
    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(
      markerWidth.toInt(),
      markerHeight.toInt(),
    );
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }
}

