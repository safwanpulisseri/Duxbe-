part of 'home_notifier.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    @Default('') String error,
    PagingController<int, SaleView>? pagingController,
    @Default(HomeModel()) HomeModel dashboardData,
  }) = _HomeState;

  factory HomeState.initial() => const HomeState();
}
