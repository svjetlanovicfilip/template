import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/container_input_field.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../config/style/colors.dart';
import '../../../calendar/ui/widgets/label.dart';
import '../../../login/data/models/user_model.dart';
import '../../../users/domain/bloc/users_bloc.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  const AddEditEmployeeScreen({super.key});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeViewState();
}

class _AddEditEmployeeViewState extends State<AddEditEmployeeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final usersBloc = getIt<UsersBloc>();

  final _errorNameMessage = 'Ime ne smije biti prazno';
  final _errorLastNameMessage = 'Prezime ne smije biti prazno';
  final _errorUsernameMessage = 'Korisničko ime ne smije biti prazno';
  final _errorEmailMessage = 'Email ne smije biti prazan';

  String? _nameError;
  String? _lastNameError;
  String? _usernameError;
  String? _emailError;

  bool get _isFormFilled =>
      nameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty &&
      usernameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty;

  // (opciono) basic email check
  bool get _isEmailValid {
    final e = emailController.text.trim();
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
          Navigator.of(context).pop(nameController.text.trim());
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
                const SizedBox(height: 16),
                const Label(title: 'Ime'),
                const SizedBox(height: 8),
                ContainerInputField(
                  controller: nameController,
                  hintText: 'Unesite ime',
                  keyboardType: TextInputType.text,
                  inputFormatters: const [],
                  maxLines: 1,
                  errorText: _nameError,
                  onChanged: (value) {
                    setState(() {
                      _nameError = value.isNotEmpty ? null : _errorNameMessage;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Label(title: 'Prezime'),
                const SizedBox(height: 8),
                ContainerInputField(
                  controller: lastNameController,
                  hintText: 'Unesite prezime',
                  keyboardType: TextInputType.text,
                  inputFormatters: const [],
                  maxLines: 1,
                  errorText: _lastNameError,
                  onChanged: (value) {
                    setState(() {
                      _lastNameError =
                          value.isNotEmpty ? null : _errorLastNameMessage;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Label(title: 'Korisnicko ime'),
                const SizedBox(height: 8),
                ContainerInputField(
                  controller: usernameController,
                  hintText: 'Unesite korisnicko ime',
                  keyboardType: TextInputType.text,
                  inputFormatters: const [],
                  maxLines: 1,
                  errorText: _usernameError,
                  onChanged: (value) {
                    setState(() {
                      _usernameError =
                          value.isNotEmpty ? null : _errorUsernameMessage;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Label(title: 'Email'),
                const SizedBox(height: 8),
                ContainerInputField(
                  controller: emailController,
                  hintText: 'Unesite email',
                  keyboardType: TextInputType.text,
                  inputFormatters: const [],
                  maxLines: 1,
                  errorText: _emailError,
                  onChanged: (value) {
                    setState(() {
                      _emailError =
                          value.isNotEmpty ? null : _errorEmailMessage;
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

    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();

    // if (title.isEmpty && price.isEmpty) {
    //   setState(() {
    //     _nameError = _errorNameMessage;
    //     _phoneNumberError = _errorPhoneNumberMessage;
    //   });
    //   return;
    // }

    if (name.isEmpty) {
      setState(() {
        _nameError = _errorNameMessage;
      });
      return;
    }

    if (lastName.isEmpty) {
      setState(() {
        _lastNameError = _errorLastNameMessage;
      });
      return;
    }

    if (username.isEmpty) {
      setState(() {
        _usernameError = _errorUsernameMessage;
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _emailError = _errorEmailMessage;
        if (!_isEmailValid) {
          _emailError = 'Email nije ispravan';
        } else {
          _emailError = null;
        }
      });
    }

    usersBloc.add(
      UserAdded(
        user: UserModel(
          name: name,
          surname: lastName,
          username: username,
          email: email,
        ),
      ),
    );
  }
}
