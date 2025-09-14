import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dialog_ui_provider.g.dart';

@riverpod
class DialogUiNotifier extends _$DialogUiNotifier {
  @override
  DialogUiState build() {
    return const DialogUiState();
  }

  void updateIsLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void reset() {
    state = const DialogUiState();
  }
}

class DialogUiState {
  const DialogUiState({
    this.isLoading = false,
  });

  final bool isLoading;

  DialogUiState copyWith({
    bool? isLoading,
  }) {
    return DialogUiState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
