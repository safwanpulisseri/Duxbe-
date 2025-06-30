part of 'auth_notifier.dart';

enum AuthStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class AuthNotifierState with _$AuthNotifierState {
  const factory AuthNotifierState({
    @Default(AuthStatus.initial) AuthStatus status,
    @Default('') String error,
    AuthResponse? authResponse,
    EmployeeModel? user,
    @Default([]) List<RouteItem> sidebar,
  }) = _AuthState;

  factory AuthNotifierState.initial() => const AuthNotifierState();
}
