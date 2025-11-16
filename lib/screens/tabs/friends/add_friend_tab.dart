import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/services/auth_service.dart';
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
  List<UserModel> _foundMochiFriends = [];

  /// 초대할 친구 목록을 저장하는 상태 변수입니다.
  List<Contact> _contactsToInvite = [];

  /// 친구 요청을 보낸 친구의 UID 목록을 저장하는 상태 변수입니다.
  /// (UI에서 버튼 상태를 관리하기 위함)
  Set<String> _requestedFriendUids = {};

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
        // 현재 로그인한 유저의 uid를 가져옵니다.
        final currentUserUid = AuthService.currentUser?.uid;
        if (currentUserUid == null) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        // 자기 자신을 제외한 친구 목록을 검색합니다.
        final foundFriends = await DatabaseService.instance
            .findFriendsFromContacts(currentUserUid, phoneNumbers);

        // 5. '모찌' 친구와 '초대할 친구' 분류
        List<Contact> toInvite = [];
        List<UserModel> mochiFriends = [];

        for (var contact in contacts) {
          if (contact.phones.isEmpty) continue;
          String contactPhone = contact.phones.first.number;

          // DB 검색 결과에서 일치하는 친구 찾기
          var matchingFriend = foundFriends.firstWhere(
            (friend) => friend.phoneNumber == contactPhone,
            orElse: () => UserModel(
              uid: '',
              email: '',
              displayName: '',
            ), // 빈 UserModel
          );

          if (matchingFriend.uid.isNotEmpty) {
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

  /// 친구 요청을 전송하는 메서드입니다.
  Future<void> _sendFriendRequest(String friendUid) async {
    try {
      // DatabaseService를 통해 친구 요청을 전송합니다.
      await DatabaseService.instance.sendFriendRequest(friendUid);

      if (!mounted) {
        return;
      }

      // (UI 업데이트) 요청 보낸 버튼을 '요청함' (회색)으로 변경 (간단한 상태 관리)
      setState(() {
        _requestedFriendUids.add(friendUid);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('친구 요청을 보냈습니다.'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('친구 요청 전송 중 오류가 발생했습니다: $e'),
        ),
      );
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
            ..._foundMochiFriends.asMap().entries.map((entry) {
              final index = entry.key;
              final friend = entry.value;
              final isRequested = _requestedFriendUids.contains(friend.uid);

              return ListTile(
                title: Text(friend.displayName),
                subtitle: Text(friend.phoneNumber ?? '전화번호 없음'),
                trailing: ElevatedButton(
                  onPressed: isRequested
                      ? null
                      : () async {
                          // TODO: 이미 요청했거나 친구인 경우 버튼 비활성화
                          await _sendFriendRequest(friend.uid);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRequested ? Colors.grey : null,
                  ),
                  child: Text(isRequested ? '요청함' : '친구 추가'),
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
