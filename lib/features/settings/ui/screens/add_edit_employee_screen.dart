import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/custom_input_field.dart';
import '../../../../config/style/colors.dart';
import '../../../login/data/models/user_model.dart';
import '../../../users/domain/bloc/users_bloc.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  const AddEditEmployeeScreen({super.key});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeViewState();
}

class _AddEditEmployeeViewState extends State<AddEditEmployeeScreen> {
  final usersBloc = getIt<UsersBloc>();

  String _name = '';
  String? _nameError;

  String _lastName = '';
  String? _lastNameError;

  String _username = '';
  String? _usernameError;

  String _email = '';
  String? _emailError;

  bool get _isFormFilled =>
      _name.trim().isNotEmpty &&
      _lastName.trim().isNotEmpty &&
      _username.trim().isNotEmpty &&
      _email.trim().isNotEmpty;

  // (opciono) basic email check
  bool get _isEmailValid {
    final e = _email.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(e);
  }

  bool get _canSubmit => _isFormFilled && _isEmailValid;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      bloc: usersBloc,
      listener: (context, state) {
        if (state is UsersFetchingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Zaposleni je dodat. Poslan je email za reset lozinke.',
              ),
            ),
          );
          Navigator.of(context).pop(_name.trim());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: Text('Dodajte novog zaposlenog')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomInputField(
                  label: 'Ime',
                  hint: 'Ime',
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
                  errorText: _emailError,
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                      _emailError = null;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // SUBMIT BUTTON
                SizedBox(
                  height: 48,
                  child: BlocBuilder<UsersBloc, UsersState>(
                    bloc: usersBloc,
                    buildWhen:
                        (prev, next) => prev.runtimeType != next.runtimeType,
                    builder: (context, state) {
                      final isSubmitting = state is UsersFetching;

                      return ElevatedButton(
                        onPressed:
                            (isSubmitting || !_canSubmit)
                                ? null
                                : () => _onSubmit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber500,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            isSubmitting
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
                      );
                    },
                  ),
                ),

                // Mala pomoć korisniku kad je dugme disabled
                if (!_isFormFilled) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Popunite sva polja da biste mogli potvrditi.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ] else if (!_isEmailValid) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Unesite ispravan email format.',
                    style: TextStyle(fontSize: 12, color: Colors.redAccent),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    // dodatna validacija (čak i ako je dugme disabled dok nije validno)
    setState(() {
      _nameError = _name.trim().isEmpty ? 'Ime ne smije biti prazno' : null;
      _lastNameError =
          _lastName.trim().isEmpty ? 'Prezime ne smije biti prazno' : null;
      _usernameError =
          _username.trim().isEmpty
              ? 'Korisničko ime ne smije biti prazno'
              : null;

      if (_email.trim().isEmpty) {
        _emailError = 'Email ne smije biti prazan';
      } else if (!_isEmailValid) {
        _emailError = 'Email nije ispravan';
      } else {
        _emailError = null;
      }
    });

    final hasError =
        _nameError != null ||
        _lastNameError != null ||
        _usernameError != null ||
        _emailError != null;

    if (hasError) return;

    usersBloc.add(
      UserAdded(
        user: UserModel(
          name: _name,
          surname: _lastName,
          username: _username,
          email: _email,
        ),
      ),
    );
  }
}
