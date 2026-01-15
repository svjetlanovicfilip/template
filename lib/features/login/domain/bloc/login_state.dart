part of 'login_bloc.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.errorMessage,
    this.isFormSubmitted = false,
    this.isEmailSentSuccessfully = false,
  });

  final Email email;
  final Password password;
  final bool isValid;
  final FormzSubmissionStatus? status;
  final String? errorMessage;
  final bool isFormSubmitted;
  final bool isEmailSentSuccessfully;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    bool? isValid,
    String? errorMessage,
    bool? isFormSubmitted,
    bool? isEmailSentSuccessfully,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
      isFormSubmitted: isFormSubmitted ?? this.isFormSubmitted,
      isEmailSentSuccessfully:
          isEmailSentSuccessfully ?? this.isEmailSentSuccessfully,
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    password,
    isValid,
    errorMessage,
    isFormSubmitted,
    isEmailSentSuccessfully,
  ];
}

enum EmailValidationError { invalid }

enum PasswordValidationError { invalid }

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure([super.value = '']) : super.pure();

  const Email.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(
    r'^[a-zA-Z\d.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$',
  );

  @override
  EmailValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) ? null : EmailValidationError.invalid;
  }
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure([super.value = '']) : super.pure();

  const Password.dirty([super.value = '']) : super.dirty();

  static final _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  @override
  PasswordValidationError? validator(String value) {
    return _passwordRegExp.hasMatch(value)
        ? null
        : PasswordValidationError.invalid;
  }
}
