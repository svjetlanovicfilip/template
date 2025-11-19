import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_input_field.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../domain/bloc/login_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  LoginBloc get _loginBloc => getIt<LoginBloc>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          bloc: _loginBloc,
          builder: (context, state) {
            final errorText =
                state.email.error != null ? 'Invalid email' : null;

            return CustomInputField(
              label: 'Email',
              errorText: state.isFormSubmitted ? errorText : null,
              onChanged: (value) => _loginBloc.add(LoginEmailChanged(value)),
            );
          },
        ),
        BlocBuilder<LoginBloc, LoginState>(
          bloc: _loginBloc,
          builder: (context, state) {
            final errorText =
                state.password.error != null ? 'Invalid password' : null;

            return CustomInputField(
              label: 'Password',
              errorText: state.isFormSubmitted ? errorText : null,
              onChanged: (value) => _loginBloc.add(LoginPasswordChanged(value)),
              isPassword: true,
            );
          },
        ),

        const SizedBox(height: 50),

        BlocBuilder<LoginBloc, LoginState>(
          bloc: _loginBloc,
          builder:
              (context, state) => SizedBox(
                width: MediaQuery.of(context).size.width,
                child: PrimaryButton(
                  title: 'Prijavi se',
                  onTap: () => _loginBloc.add(const LoginSubmitted()),
                  borderRadius: BorderRadius.circular(8),
                  isLoading: state.status == FormzSubmissionStatus.inProgress,
                ),
              ),
        ),
      ],
    );
  }
}
