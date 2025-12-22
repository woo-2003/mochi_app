// AI 서비스 로직
//
// Google Gemini AI를 사용하여 현재 위치와 시간을 기반으로 사용자 상태를 추천하는 서비스입니다.
import 'package:google_generative_ai/google_generative_ai.dart';

/// AI 서비스 클래스
///
/// Google Gemini AI를 사용하여 사용자의 현재 상황을 분석하고 상태를 추천합니다.
/// 싱글톤 패턴을 사용해 앱 전역에서 동일한 인스턴스를 손쉽게 사용할 수 있도록 합니다.
class AIService {
  /// 싱글톤 인스턴스
  static final AIService instance = AIService._internal();

  /// Gemini API 키 (과제 제출용: 실제 키는 YOUR_GEMINI_API_KEY로 교체 필요)
  static const String apiKey = 'YOUR_GEMINI_API_KEY';

  AIService._internal();

  /// 현재 위치와 시간을 기반으로 사용자 상태를 추천합니다.
  ///
  /// [lat] 현재 위치의 위도
  /// [lng] 현재 위치의 경도
  /// 반환값: AI가 추천한 상태 문자열 (예: '🔥 굽기', '☁️ 말랑', '🧊 단단', '🍡 꼬치')
  Future<String> suggestStatus(double lat, double lng) async {
    try {
      // 1. GenerativeModel 초기화 (gemini-pro 모델 사용)
      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

      // 2. 현재 시간 가져오기
      final now = DateTime.now();
      final timeString =
          '${now.year}년 ${now.month}월 ${now.day}일 ${now.hour}시 ${now.minute}분';

      // 3. 프롬프트 구성
      final prompt =
          '''
현재 시간은 $timeString이고, 위도는 $lat, 경도는 $lng이야.
이 사용자가 무엇을 하고 있을지 추측해서, 다음 4가지 상태 중 하나만 딱 골라서 답변해줘.
(답변 형식: '이모지 상태명')

옵션:
- 🔥 굽기 (즉시 만남)
- ☁️ 말랑 (수신 대기)
- 🧊 단단 (방해 금지)
- 🍡 꼬치 (약속 있음)

예를 들어:
- 학교나 도서관 같으면 '🧊 단단'
- 번화가나 카페면 '🔥 굽기'
- 집이나 휴식 공간이면 '☁️ 말랑'
- 특정 장소에 약속이 있으면 '🍡 꼬치'

답변은 반드시 '이모지 상태명' 형식으로만 해줘. 예: '🔥 굽기'
''';

      // 4. AI 모델에 프롬프트 전송 및 응답 받기
      final response = await model.generateContent([Content.text(prompt)]);

      // 5. 응답 텍스트 추출 및 반환
      final result = response.text?.trim() ?? '☁️ 말랑 (수신 대기)';

      // 응답이 올바른 형식인지 확인 (이모지와 상태명이 포함되어 있는지)
      if (result.contains('🔥') ||
          result.contains('☁️') ||
          result.contains('🧊') ||
          result.contains('🍡')) {
        return result;
      } else {
        // 응답이 올바른 형식이 아니면 기본값 반환
        return '☁️ 말랑 (수신 대기)';
      }
    } catch (e) {
      // AI 추천 중 오류가 발생한 경우 로깅하고 기본값 반환
      // ignore: avoid_print
      print('Error getting AI suggestion: $e');
      return '☁️ 말랑 (수신 대기)';
    }
  }
}
