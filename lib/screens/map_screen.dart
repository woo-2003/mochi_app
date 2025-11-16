import 'package:flutter/material.dart';
import 'package:mochi_app/services/auth_service.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mochi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 로그아웃 버튼 클릭 시 AuthService.signOut() 호출
              await AuthService.instance.signOut();
              // AuthGate가 스트림을 감지하고 자동으로 로그인 화면으로 보낼 것임
            },
          ),
        ],
      ),
      body: const Center(child: Text('지도 화면')),
    );
  }
}
