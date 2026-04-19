import 'user_model.dart';

class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;
  final AuthErrorType? errorType;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.errorType,
  });

  factory AuthResult.success(UserModel user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure({
    required String message,
    AuthErrorType errorType = AuthErrorType.unknown,
  }) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
      errorType: errorType,
    );
  }
}

enum AuthErrorType {
  invalidCredentials,
  emailAlreadyInUse,
  phoneAlreadyInUse,
  networkError,
  userNotFound,
  tooManyRequests,
  unknown,
}