import 'package:flutter/material.dart';

/// 내 모찌 탭 화면
///
/// 사용자가 추가한 친구(모찌) 목록을 표시하는 화면입니다.
class MyFriendsTab extends StatelessWidget {
  const MyFriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('내 모찌 목록'),
      ),
    );
  }
}

