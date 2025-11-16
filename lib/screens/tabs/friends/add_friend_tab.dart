import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// 모찌 추가 탭 화면
///
/// 새로운 친구(모찌)를 검색하거나 연락처에서 추가하는 화면입니다.
class AddFriendTab extends StatefulWidget {
  const AddFriendTab({super.key});

  @override
  State<AddFriendTab> createState() => _AddFriendTabState();
}

class _AddFriendTabState extends State<AddFriendTab> {
  /// 연락처 목록을 저장하는 상태 변수입니다.
  List<Contact> _contacts = [];

  /// 로딩 상태를 나타내는 상태 변수입니다.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 화면이 초기화될 때 연락처를 불러옵니다.
    _loadContacts();
  }

  /// 연락처를 로드하는 메서드입니다.
  Future<void> _loadContacts() async {
    // 1. 먼저 연락처 권한을 요청합니다.
    if (await FlutterContacts.requestPermission()) {
      // 2. 권한이 허용되면, 연락처를 가져옵니다.
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true, // 전화번호, 이메일 등 속성 포함
      );
      if (mounted) {
        setState(() {
          _contacts = contacts; // 상태 변수에 저장
          _isLoading = false; // 로딩 완료
        });
      }
    } else {
      // 3. 권한이 거부되면, 로딩을 끄고 빈 화면을 표시
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때는 로딩 인디케이터를 표시합니다.
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 연락처가 없거나 권한이 거부된 경우 메시지를 표시합니다.
    if (_contacts.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('연락처가 없거나 권한이 거부되었습니다.'),
        ),
      );
    }

    // 연락처 목록을 ListView로 표시합니다.
    return Scaffold(
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          // TODO: 여기서 '연락처에 있는 모찌 유저'와 '내 연락처(전체)'를 분리해야 함
          // 지금은 모든 연락처를 임시로 표시합니다. (기능 테스트용)
          return ListTile(
            title: Text(contact.displayName),
            subtitle: contact.phones.isNotEmpty
                ? Text(contact.phones.first.number)
                : const Text('전화번호 없음'),
          );
        },
      ),
    );
  }
}
