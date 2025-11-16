// 내 모찌 탭 화면
//
// 사용자가 추가한 친구(모찌) 목록을 실시간으로 표시하는 화면입니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/services/database_service.dart';

/// 내 모찌 탭 화면
///
/// 사용자가 추가한 친구(모찌) 목록을 표시하는 화면입니다.
class MyFriendsTab extends StatefulWidget {
  const MyFriendsTab({super.key});

  @override
  State<MyFriendsTab> createState() => _MyFriendsTabState();
}

class _MyFriendsTabState extends State<MyFriendsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // StreamBuilder의 stream: DatabaseService.getMyFriendsStream()를 호출
        stream: DatabaseService.instance.getMyFriendsStream(),
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
              child: Text('아직 추가된 모찌가 없습니다.'),
            );
          }

          // 데이터가 있을 때 ListView.builder로 친구 목록 표시
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // 1. (StreamBuilder) 'friends' 컬렉션에서 `friendId` (친구의 uid)를 가져옴.
              final friendDoc = snapshot.data!.docs[index];
              final friendId = friendDoc.id; // 친구의 uid

              // 2. (FutureBuilder) `DatabaseService.getUserProfile(friendId)`를 호출하여
              //    '친구의 상세 정보'(이름, 번호)를 가져옴.
              return FutureBuilder<UserModel?>(
                future: DatabaseService.instance.getUserProfile(friendId),
                builder: (context, userSnapshot) {
                  // 사용자 정보를 가져오는 중
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('친구 정보 로딩 중...'),
                    );
                  }

                  // 사용자 정보를 가져오지 못한 경우 (탈퇴한 친구)
                  final userProfile = userSnapshot.data;

                  // 4. `userProfile`이 `null`일 경우 (탈퇴한 친구), `ListTile(title: Text("알 수 없는 모찌"))`를 표시.
                  if (userProfile == null) {
                    return const ListTile(
                      title: Text('알 수 없는 모찌'),
                      subtitle: Text('이 친구는 더 이상 존재하지 않습니다.'),
                    );
                  }

                  // 3. `userProfile`이 `null`이 아닐 경우 (정상 친구),
                  //    `ListTile`에 `userProfile.displayName`과 `userProfile.phoneNumber`를 표시.
                  return ListTile(
                    title: Text(userProfile.displayName),
                    subtitle: Text(userProfile.phoneNumber ?? '전화번호 없음'),
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
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
