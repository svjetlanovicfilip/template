import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/custom_input_field.dart';
import '../../../../common/widgets/logo_widget.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../config/style/colors.dart';
import '../../domain/bloc/login_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final LoginBloc _loginBloc = getIt<LoginBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      bloc: _loginBloc,
      listener: (context, state) {
        if (state.status == FormzSubmissionStatus.success) {
          context.pop();
        } else if (state.status == FormzSubmissionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? ''),
              backgroundColor: AppColors.red600,
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.slate900, AppColors.slate800],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LogoWidget(size: 32, radius: 40),
                        const SizedBox(height: 24),
                        Text(
                          'Zaboravljena lozinka',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 32),
                        ),

                        Text(
                          'Unesite svoj email da bi resetovali lozinku',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<LoginBloc, LoginState>(
                          bloc: _loginBloc,
                          builder: (context, state) {
                            final errorText =
                                state.email.error != null
                                    ? 'Email nije validan'
                                    : null;
                            return CustomInputField(
                              label: 'Email',
                              onChanged:
                                  (value) =>
                                      _loginBloc.add(LoginEmailChanged(value)),
                              errorText:
                                  state.isFormSubmitted ? errorText : null,
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        BlocBuilder<LoginBloc, LoginState>(
                          bloc: _loginBloc,
                          builder: (context, state) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: PrimaryButton(
                                title: 'Resetujte lozinku',
                                onTap:
                                    () => _loginBloc.add(
                                      ForgotPasswordSubmitted(),
                                    ),
                                borderRadius: BorderRadius.circular(8),
                                isLoading:
                                    state.status ==
                                    FormzSubmissionStatus.inProgress,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 50),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_back,
                                color: AppColors.amber500,
                              ),
                              Text(
                                'Vratite se na prijavu',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.amber500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
