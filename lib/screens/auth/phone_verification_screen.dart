// 신규 사용자의 전화번호를 입력받는 화면입니다.
// 전화번호를 입력받아 Firestore에 저장한 후 메인 화면으로 이동합니다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mochi_app/screens/main_navigator.dart';
import 'package:mochi_app/services/database_service.dart';

/// 전화번호 입력 화면
///
/// 신규 사용자가 전화번호를 입력하여 친구 찾기 기능을 사용할 수 있도록 합니다.
class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  /// 전화번호 입력을 위한 텍스트 컨트롤러입니다.
  final TextEditingController _phoneController = TextEditingController();

  /// 저장 중인지 여부를 나타내는 상태 변수입니다.
  bool _isSaving = false;

  @override
  void dispose() {
    // 메모리 누수를 방지하기 위해 컨트롤러를 정리합니다.
    _phoneController.dispose();
    super.dispose();
  }

  /// 전화번호를 저장하는 메서드입니다.
  Future<void> _savePhoneNumber() async {
    final phoneNumber = _phoneController.text.trim();

    // TODO: 전화번호 형식 검증 (예: 010-1234-5678)
    if (phoneNumber.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('전화번호를 입력해주세요.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 상태를 확인할 수 없습니다.'),
          ),
        );
        return;
      }

      // DatabaseService를 통해 전화번호를 저장합니다.
      await DatabaseService.instance.savePhoneNumber(user.uid, phoneNumber);

      if (!mounted) {
        return;
      }

      // 저장 성공 시 메인 네비게이터로 이동합니다.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const MainNavigator(),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('전화번호 저장 중 오류가 발생했습니다: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전화번호 입력'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '친구 찾기를 위해\n전화번호를 입력해주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '010-1234-5678',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isSaving,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _savePhoneNumber,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

