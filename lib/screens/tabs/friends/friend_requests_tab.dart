import 'package:flutter/material.dart';

/// 친구 요청 알림 탭 화면
///
/// 받은 친구 요청과 보낸 친구 요청을 확인하고 처리할 수 있는 화면입니다.
class FriendRequestsTab extends StatelessWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('친구 요청 알림'),
      ),
    );
  }
}

