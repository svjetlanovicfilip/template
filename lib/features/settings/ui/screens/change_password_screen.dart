import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_input_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String _oldPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Promjena lozinke',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInputField(
                label: 'Stara šifra',
                hint: 'Stara šifra',
                isPassword: true,
                errorText: _oldPasswordError,
                onChanged: (value) {
                  setState(() {
                    _oldPassword = value;
                    _oldPasswordError = null;
                  });
                },
              ),
              CustomInputField(
                label: 'Nova šifra',
                hint: 'Nova šifra',
                isPassword: true,
                errorText: _newPasswordError,
                onChanged: (value) {
                  setState(() {
                    _newPassword = value;
                    _newPasswordError = null;
                  });
                },
              ),
              CustomInputField(
                label: 'Potvrda nove šifre',
                hint: 'Potvrda nove šifre',
                isPassword: true,
                errorText: _confirmPasswordError,
                onChanged: (value) {
                  setState(() {
                    _confirmPassword = value;
                    _confirmPasswordError = null;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text('Promijeni šifru'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    setState(() {
      _oldPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    var hasError = false;

    if (_oldPassword.isEmpty) {
      _oldPasswordError = 'Unesite staru šifru';
      hasError = true;
    }

    if (_newPassword.isEmpty) {
      _newPasswordError = 'Unesite novu šifru';
      hasError = true;
    } else {
      if (_newPassword.length < 8) {
        _newPasswordError = 'Šifra mora imati najmanje 8 karaktera';
        hasError = true;
      } else if (!_newPassword.contains(RegExp('[A-Z]'))) {
        _newPasswordError = 'Šifra mora sadržavati bar jedno veliko slovo';
        hasError = true;
      } else if (!_newPassword.contains(RegExp(r'\d'))) {
        _newPasswordError = 'Šifra mora sadržavati bar jedan broj';
        hasError = true;
      }
    }

    if (_confirmPassword.isEmpty) {
      _confirmPasswordError = 'Ponovo unesite novu šifru';
      hasError = true;
    } else if (_confirmPassword != _newPassword) {
      _confirmPasswordError = 'Šifra i potvrda šifre moraju biti iste';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      //TODO
      // npr:
      // await authRepository.changePassword(
      //   oldPassword: _oldPassword,
      //   newPassword: _newPassword,
      // );

      await Future.delayed(const Duration(seconds: 1)); // demo delay

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Šifra je uspješno promijenjena')),
      );
      Navigator.of(context).pop();
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      setState(() {
        _oldPasswordError = 'Stara šifra nije tačna ili je došlo do greške';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
