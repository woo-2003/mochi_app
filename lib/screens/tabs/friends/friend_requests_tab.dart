// 친구 요청 알림 탭 화면
//
// 받은 친구 요청을 실시간으로 확인하고 처리할 수 있는 화면입니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/services/database_service.dart';

/// 친구 요청 알림 탭 화면
///
/// 받은 친구 요청과 보낸 친구 요청을 확인하고 처리할 수 있는 화면입니다.
class FriendRequestsTab extends StatefulWidget {
  const FriendRequestsTab({super.key});

  @override
  State<FriendRequestsTab> createState() => _FriendRequestsTabState();
}

class _FriendRequestsTabState extends State<FriendRequestsTab> {
  /// 친구 요청을 수락하는 메서드입니다.
  Future<void> _handleAcceptRequest(
      String requestId, String fromUid) async {
    try {
      // (UI 업데이트) 로딩 인디케이터 표시
      if (!mounted) {
        return;
      }

      // DatabaseService를 통해 친구 요청을 수락합니다.
      await DatabaseService.instance.acceptFriendRequest(requestId, fromUid);

      if (!mounted) {
        return;
      }

      // (UI 업데이트) 로딩 숨김
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('친구 요청을 수락했습니다.'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('친구 요청 수락 중 오류가 발생했습니다: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // StreamBuilder의 stream: DatabaseService.getFriendRequests()를 호출
        stream: DatabaseService.instance.getFriendRequests(),
        builder: (context, snapshot) {
          // 연결 중일 때는 로딩 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 에러가 발생한 경우
          if (snapshot.hasError) {
            return Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            );
          }

          // 데이터가 없을 때
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('받은 친구 요청이 없습니다.'),
            );
          }

          // 데이터가 있을 때 ListView.builder로 요청 목록 표시
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // StreamBuilder의 snapshot에서 requestDoc를 가져옵니다.
              final requestDoc = snapshot.data!.docs[index];
              final requestId = requestDoc.id; // 요청 문서 ID
              final requestData = requestDoc.data() as Map<String, dynamic>;
              final fromUid = requestData['fromUid'] as String; // 보낸 사람 uid

              // 1. (StreamBuilder) 'friend_requests'에서 `fromUid` (보낸 사람 uid)를 가져옴.
              // 2. (FutureBuilder) `DatabaseService.getUserProfile(fromUid)`를 호출하여
              //    '보낸 사람의 상세 정보'(이름, 번호)를 가져옴.
              return FutureBuilder<UserModel?>(
                future: DatabaseService.instance.getUserProfile(fromUid),
                builder: (context, userSnapshot) {
                  // 사용자 정보를 가져오는 중
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('요청자 정보 로딩 중...'),
                    );
                  }

                  // `snapshot.hasData` (데이터가 있음) 블록 안에서 null 체크를 추가합니다.
                  final userProfile = userSnapshot.data;

                  // 요청은 있으나, 보낸 유저의 프로필을 찾을 수 없음 (예: 탈퇴)
                  if (userProfile == null) {
                    return const ListTile(
                      title: Text('알 수 없는 사용자'),
                      trailing: Text('정보 없음'),
                    );
                  }

                  // 정상 유저인 경우 ListTile에 보낸 사람의 이름과 수락/거절 버튼 표시
                  return ListTile(
                    title: Text(userProfile.displayName),
                    subtitle: Text(userProfile.phoneNumber ?? '전화번호 없음'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // 친구 요청 수락 기능 구현
                            await _handleAcceptRequest(requestId, fromUid);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('수락'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: 거절 로직 (요청 문서 삭제 또는 'rejected'로 업데이트)
                            // 지금은 [수락] 버튼만 구현
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('거절'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
