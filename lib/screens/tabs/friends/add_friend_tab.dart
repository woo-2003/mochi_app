import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mochi_app/services/database_service.dart';

/// 모찌 추가 탭 화면
///
/// 새로운 친구(모찌)를 검색하거나 연락처에서 추가하는 화면입니다.
/// 연락처와 DB를 비교하여 이미 가입한 친구와 초대할 친구를 분류합니다.
class AddFriendTab extends StatefulWidget {
  const AddFriendTab({super.key});

  @override
  State<AddFriendTab> createState() => _AddFriendTabState();
}

class _AddFriendTabState extends State<AddFriendTab> {
  /// 연락처 목록을 저장하는 상태 변수입니다.
  List<Contact> _contacts = [];

  /// 모찌에 가입한 친구 목록을 저장하는 상태 변수입니다.
  List<Map<String, dynamic>> _foundMochiFriends = [];

  /// 초대할 친구 목록을 저장하는 상태 변수입니다.
  List<Contact> _contactsToInvite = [];

  /// 로딩 상태를 나타내는 상태 변수입니다.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 화면이 초기화될 때 연락처를 불러옵니다.
    _loadContacts();
  }

  /// 연락처를 로드하고, '모찌' 친구와 '초대할 친구'를 분류합니다.
  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    // 1. 권한 요청
    if (await FlutterContacts.requestPermission()) {
      // 2. 연락처 가져오기
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true, // 사진도 가져오기
      );

      // 3. 연락처에서 전화번호 목록 추출 (TODO: 010-1234-5678 형식으로 정규화 필요)
      List<String> phoneNumbers = contacts
          .where((c) => c.phones.isNotEmpty)
          .map((c) => c.phones.first.number)
          .toList();

      // 4. DB에서 '모찌' 친구 검색
      if (phoneNumbers.isNotEmpty) {
        final foundFriends =
            await DatabaseService.instance.findFriendsFromContacts(phoneNumbers);

        // 5. '모찌' 친구와 '초대할 친구' 분류
        List<Contact> toInvite = [];
        List<Map<String, dynamic>> mochiFriends = [];

        for (var contact in contacts) {
          if (contact.phones.isEmpty) continue;
          String contactPhone = contact.phones.first.number;

          // DB 검색 결과에서 일치하는 친구 찾기
          var matchingFriend = foundFriends.firstWhere(
            (friend) => friend['phoneNumber'] == contactPhone,
            orElse: () => {}, // empty map
          );

          if (matchingFriend.isNotEmpty) {
            // 일치 -> '모찌' 친구
            mochiFriends.add(matchingFriend);
          } else {
            // 불일치 -> '초대할' 친구
            toInvite.add(contact);
          }
        }

        if (mounted) {
          setState(() {
            _contacts = contacts; // 원본
            _foundMochiFriends = mochiFriends; // 찾은 친구
            _contactsToInvite = toInvite; // 초대할 친구
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // 권한 거부
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

    // 두 섹션을 표시하는 ListView
    return Scaffold(
      body: ListView(
        children: [
          // 섹션 1: 모찌에 가입한 친구
          if (_foundMochiFriends.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '모찌에 가입한 친구',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._foundMochiFriends.map((friend) {
              return ListTile(
                title: Text(friend['displayName'] ?? '이름 없음'),
                subtitle: Text(friend['phoneNumber'] ?? '전화번호 없음'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // TODO: 친구 추가 기능 구현
                  },
                  child: const Text('친구 추가'),
                ),
              );
            }),
            const Divider(),
          ],

          // 섹션 2: 초대하기
          if (_contactsToInvite.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '초대하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._contactsToInvite.map((contact) {
              return ListTile(
                title: Text(contact.displayName),
                subtitle: contact.phones.isNotEmpty
                    ? Text(contact.phones.first.number)
                    : const Text('전화번호 없음'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // TODO: 초대 기능 구현
                  },
                  child: const Text('초대'),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
