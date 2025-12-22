// Gemini AI 서비스
//
// Google Gemini AI를 사용하여 위치와 시간을 기반으로 사용자의 활동을 추론하는 서비스입니다.
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini AI 서비스 클래스
///
/// 위치와 시간을 기반으로 사용자가 무엇을 하고 있을지 추론합니다.
/// 싱글톤 패턴을 사용해 앱 전역에서 동일한 인스턴스를 손쉽게 사용할 수 있도록 합니다.
class GeminiService {
  /// 싱글톤 인스턴스
  static final GeminiService instance = GeminiService._internal();

  /// Gemini API 키 (과제 제출용: 실제 키는 YOUR_GEMINI_API_KEY로 교체 필요)
  static const String apiKey = 'YOUR_GEMINI_API_KEY';

  GeminiService._internal();

  /// 현재 위치와 시간을 기반으로 사용자의 활동을 추론합니다.
  ///
  /// [address] 현재 위치의 주소 (거리명/건물명)
  /// [time] 현재 시간
  /// 반환값: AI가 추론한 상태 텍스트 (한글 3~6글자 + 이모지 1개, 예: '열일 중 🔥', '맛집 탐방 😋', '이불 밖 위험 🛌')
  Future<String> guessActivity(String address, DateTime time) async {
    try {
      // 1. GenerativeModel 초기화 (gemini-pro 모델 사용)
      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

      // 2. 프롬프트 구성 (강화된 버전)
      final prompt = '''
너는 한국인들이 일상에서 자주 쓰는 센스 있고 유쾌한 상태 메시지 작성기야.

입력 정보:
- 위치: $address
- 시간: ${time.hour}시

위 정보를 바탕으로 현재 상황을 추측해서 상태 메시지를 작성해줘.

**중요 규칙:**
1. 너무 딱딱한 표현("업무 중", "이동 중")은 지양해.
2. 너무 어린 표현("수업 째기")도 지양해.
3. **누구나 공감할 수 있는 위트 있는 표현**을 사용해.
4. **형식:** "한글 3~6글자 + 이모지 1개" (딱 이 포맷만 출력할 것)

**상황별 예시 (참고용):**
- 회사/오피스 + 낮 -> "열일 중 🔥" or "월급 루팡 🤫"
- 식당/번화가 -> "맛집 탐방 😋" or "배에 기름칠 🍖"
- 공원/산책로 -> "광합성 중 🌿" or "힐링 타임 ✨"
- 집 + 밤/주말 -> "이불 밖 위험 🛌" or "넷플릭스 🍿"
- 카페 -> "커피 수혈 ☕" or "여유 만끽 🍰"
- 헬스장 -> "득근 득근 💪"
- 정체불명/길거리 -> "동에 번쩍 ⚡"
- 학교 + 낮 -> "수업 듣는 중 🏫" or "자체 공강 🤫"
- 학교 + 밤 -> "과제 노예 🧟"

위치와 시간을 분석해서 센스 있는 상태 메시지를 만들어줘. 설명 없이 "한글 3~6글자 + 이모지 1개" 형식으로만 출력해.
''';

      // 3. AI 모델에 프롬프트 전송 및 응답 받기
      final response = await model.generateContent([Content.text(prompt)]);

      // 4. 응답 텍스트 추출 및 반환 (불필요한 문장 제거)
      final result = response.text?.trim() ?? '활동 중 🏃';

      // 5. 결과에서 불필요한 설명 제거 (상태 텍스트만 추출)
      // 예: "이 사람은 '열일 중 🔥'일 것 같습니다." -> "열일 중 🔥"
      String cleanResult = result;

      // 따옴표로 감싸진 부분이 있으면 추출
      final quoteMatch = RegExp(r"'([^']+)'").firstMatch(result);
      if (quoteMatch != null) {
        cleanResult = quoteMatch.group(1) ?? cleanResult;
      }

      // "입니다", "입니다.", "일 것 같습니다" 등의 불필요한 문장 제거
      cleanResult = cleanResult
          .replaceAll(RegExp(r'입니다\.?'), '')
          .replaceAll(RegExp(r'일 것 같습니다\.?'), '')
          .replaceAll(RegExp(r'이 사람은 '), '')
          .replaceAll(RegExp(r'이 사람이 '), '')
          .replaceAll(RegExp(r'상태 메시지:'), '')
          .replaceAll(RegExp(r'상태:'), '')
          .replaceAll(RegExp(r'추천:'), '')
          .trim();

      // 최종 결과가 비어있거나 너무 길면 기본값 반환
      if (cleanResult.isEmpty || cleanResult.length > 15) {
        return '활동 중 🏃';
      }

      return cleanResult;
    } catch (e) {
      // AI 추론 중 오류가 발생한 경우 로깅하고 기본값 반환
      // ignore: avoid_print
      print('Error getting AI activity guess: $e');
      return '활동 중 🏃';
    }
  }
}
