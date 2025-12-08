import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_input_field.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  const AddEditEmployeeScreen({super.key});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  String _name = '';
  String? _nameError;
  String _lastName = '';
  String? _lastNameError;
  String _username = '';
  String? _usernameError;
  String _email = '';
  String? _emailError;
  String _password = '';
  String? _passwordError;
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
          'Dodajte novog zaposlenog',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInputField(
                label: 'Ime',
                hint: "Ime",
                isPassword: false,
                errorText: _nameError,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                    _nameError = null;
                  });
                },
              ),
              CustomInputField(
                label: 'Prezime',
                hint: 'Prezime',
                isPassword: false,
                errorText: _lastNameError,
                onChanged: (value) {
                  setState(() {
                    _lastName = value;
                    _lastNameError = null;
                  });
                },
              ),
              CustomInputField(
                label: 'Korisnicko ime',
                hint: 'Korisnicko ime',
                isPassword: false,
                errorText: _usernameError,
                onChanged: (value) {
                  setState(() {
                    _username = value;
                    _usernameError = null;
                  });
                },
              ),
              CustomInputField(
                label: 'Email',
                hint: 'Email',
                isPassword: false,
                errorText: _emailError,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                    _emailError = null;
                  });
                },
              ),
              CustomInputField(
                label: 'Lozinka',
                hint: 'Lozinka',
                isPassword: false,
                errorText: _passwordError,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                    _passwordError = null;
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
                          : const Text('Potvrdi'),
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
      _nameError = _name.trim().isEmpty ? 'Ime ne smije biti prazno' : null;
      _lastNameError =
          _lastName.trim().isEmpty ? 'Prezime ne smije biti prazno' : null;
      _usernameError =
          _username.trim().isEmpty
              ? 'Korisničko ime ne smije biti prazno'
              : null;
      _emailError = _email.trim().isEmpty ? 'Email ne smije biti prazan' : null;
      _passwordError =
          _password.trim().isEmpty ? 'Lozinka ne smije biti prazna' : null;
    });

    final hasError =
        _nameError != null ||
        _lastNameError != null ||
        _usernameError != null ||
        _emailError != null ||
        _passwordError != null;

    if (hasError) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: ovdje pravi poziv prema serveru / backendu
      await Future.delayed(const Duration(seconds: 1)); // demo delay

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Novi zaposleni je uspješno dodat')),
      );
      Navigator.of(context).pop(_name.trim());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške prilikom dodavanja zaposlenog'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
