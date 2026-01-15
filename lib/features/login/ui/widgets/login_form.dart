import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/custom_input_field.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../config/style/colors.dart';
import '../../domain/bloc/login_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({required this.loginBloc, super.key});

  final LoginBloc loginBloc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          bloc: loginBloc,
          builder: (context, state) {
            final errorText =
                state.email.error != null ? 'Email nije validan' : null;

            return CustomInputField(
              label: 'Email',
              errorText: state.isFormSubmitted ? errorText : null,
              onChanged: (value) => loginBloc.add(LoginEmailChanged(value)),
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<LoginBloc, LoginState>(
          bloc: loginBloc,
          builder: (context, state) {
            final errorText =
                state.password.error != null ? 'Lozinka nije validna' : null;

            return CustomInputField(
              label: 'Lozinka',
              errorText: state.isFormSubmitted ? errorText : null,
              onChanged: (value) => loginBloc.add(LoginPasswordChanged(value)),
              isPassword: true,
            );
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.pushNamed(Routes.forgotPassword),
            child: Text(
              'Zaboravljena lozinka?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.amber500),
            ),
          ),
        ),

        const SizedBox(height: 50),

        BlocBuilder<LoginBloc, LoginState>(
          bloc: loginBloc,
          builder:
              (context, state) => SizedBox(
                width: MediaQuery.of(context).size.width,
                child: PrimaryButton(
                  title: 'Prijavi se',
                  onTap: () => loginBloc.add(const LoginSubmitted()),
                  borderRadius: BorderRadius.circular(8),
                  isLoading: state.status == FormzSubmissionStatus.inProgress,
                ),
              ),
        ),
      ],
    );
  }
}
