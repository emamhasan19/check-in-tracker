import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checkin_point_dialog_provider.g.dart';

@riverpod
class CheckinPointDialogNotifier extends _$CheckinPointDialogNotifier {
  @override
  CheckinPointDialogState build() {
    return const CheckinPointDialogState();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading, error: null);
  }

  void setError(String error) {
    state = state.copyWith(isLoading: false, error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const CheckinPointDialogState();
  }
}

class CheckinPointDialogState {
  const CheckinPointDialogState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  CheckinPointDialogState copyWith({bool? isLoading, String? error}) {
    return CheckinPointDialogState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
