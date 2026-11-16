import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/features/check_in/data/check_in_service.dart';

/// Mirrors [CheckInService.deadline] into Riverpod, so the card reads it
/// with `ref.watch` instead of a manual `ValueListenable` listener. All the
/// actual check-in logic stays in [CheckInService]; this only exposes it.
class CheckInViewModel extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    CheckInService.deadline.addListener(_sync);
    ref.onDispose(() => CheckInService.deadline.removeListener(_sync));
    return CheckInService.deadline.value;
  }

  void _sync() => state = CheckInService.deadline.value;

  Future<void> start(Duration within, TimeFormatter format) =>
      CheckInService.start(within, format);

  Future<void> extend(Duration by, TimeFormatter format) =>
      CheckInService.extend(by, format);

  Future<void> checkIn() => CheckInService.checkIn();
}

final checkInViewModelProvider = NotifierProvider<CheckInViewModel, DateTime?>(
  CheckInViewModel.new,
);
