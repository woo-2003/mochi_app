import 'package:flutter/material.dart';
import 'package:mochi_app/screens/tabs/friends/add_friend_tab.dart';
import 'package:mochi_app/screens/tabs/friends/friend_requests_tab.dart';
import 'package:mochi_app/screens/tabs/friends/my_friends_tab.dart';

/// 친구 목록 화면
///
/// 3개의 하위 탭(내 모찌, 모찌 추가, 알림)을 가진 친구 관리 화면입니다.
class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen>
    with TickerProviderStateMixin {
  /// TabController는 탭 간 전환과 애니메이션을 관리합니다.
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3개의 탭을 가진 TabController를 초기화합니다.
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TabController를 정리하여 메모리 누수를 방지합니다.
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '내 모찌'),
            Tab(text: '모찌 추가'),
            Tab(text: '알림 🔔'),
          ],
        ),
      ),
      // TabBarView는 TabController와 연결되어 탭 전환 시 해당 화면을 표시합니다.
      body: TabBarView(
        controller: _tabController,
        children: const [
          MyFriendsTab(),
          AddFriendTab(),
          FriendRequestsTab(),
        ],
      ),
    );
  }
}

