import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metjou/core/services/background_services.dart';
import 'package:metjou/features/check_in/data/check_in_service.dart';
import 'package:metjou/features/contacts/data/sos_contacts.dart';
import 'package:metjou/features/get_home_safe/data/get_home_safe_service.dart';

const _unset = Object();

/// What a start or stop attempt did, for the View to turn into a toast.
enum GhsAction { started, stopped, noContactSelected, timeInPast }

/// What the Get home safe card and sheet show. Shared by both, so starting
/// or stopping in the sheet is reflected on the home card without either
/// one calling the other.
class GetHomeSafeUiState {
  const GetHomeSafeUiState({
    this.running,
    this.contacts = const [],
    this.selectedContact,
    this.repeat = true,
    this.minutes = 15,
    this.at,
  });

  /// The schedule in effect; null when Get home safe is off.
  final GetHomeSafeState? running;
  final List<SosContact> contacts;
  final String? selectedContact;
  final bool repeat;
  final int minutes;
  final DateTime? at;

  bool get active => running != null;

  GetHomeSafeUiState copyWith({
    Object? running = _unset,
    List<SosContact>? contacts,
    Object? selectedContact = _unset,
    bool? repeat,
    int? minutes,
    Object? at = _unset,
  }) => GetHomeSafeUiState(
    running: running == _unset ? this.running : running as GetHomeSafeState?,
    contacts: contacts ?? this.contacts,
    selectedContact: selectedContact == _unset
        ? this.selectedContact
        : selectedContact as String?,
    repeat: repeat ?? this.repeat,
    minutes: minutes ?? this.minutes,
    at: at == _unset ? this.at : at as DateTime?,
  );
}

/// Holds Get home safe's state: the running schedule, the chosen contact
/// and the form the sheet edits before starting it.
class GetHomeSafeViewModel extends Notifier<GetHomeSafeUiState> {
  @override
  GetHomeSafeUiState build() {
    _load();
    return const GetHomeSafeUiState();
  }

  Future<void> _load() async {
    final running = await GetHomeSafeService.load();
    final contacts = await loadSosContacts();
    var selected = state.selectedContact;
    var repeat = state.repeat;
    var minutes = state.minutes;
    var at = state.at;
    if (running != null) {
      selected = running.contact;
      switch (running.schedule) {
        case RepeatEvery(:final interval):
          repeat = true;
          minutes = interval.inMinutes;
        case SendOnceAt(at: final sendAt):
          repeat = false;
          at = sendAt;
      }
    }
    state = state.copyWith(
      running: running,
      contacts: contacts,
      selectedContact: selected,
      repeat: repeat,
      minutes: minutes,
      at: at,
    );
  }

  Future<void> reloadContacts() async {
    state = state.copyWith(contacts: await loadSosContacts());
  }

  void selectContact(String? phone) {
    if (!state.active) state = state.copyWith(selectedContact: phone);
  }

  void setRepeat(bool repeat) {
    if (!state.active) state = state.copyWith(repeat: repeat);
  }

  void setMinutes(int minutes) {
    if (!state.active) state = state.copyWith(minutes: minutes);
  }

  void setAt(DateTime at) => state = state.copyWith(at: at);

  Future<GhsAction> startOrStop() async {
    if (state.active) {
      await GetHomeSafeService.stop();
      await _load();
      return GhsAction.stopped;
    }
    final contact = state.selectedContact;
    if (contact == null) return GhsAction.noContactSelected;
    final GetHomeSafeSchedule schedule;
    if (state.repeat) {
      schedule = RepeatEvery(Duration(minutes: state.minutes));
    } else {
      final at = state.at;
      if (at == null || !at.isAfter(DateTime.now())) {
        return GhsAction.timeInPast;
      }
      schedule = SendOnceAt(at);
    }
    await GetHomeSafeService.start(contact, schedule);
    await _load();
    return GhsAction.started;
  }

  /// Tells the contacts you are home, and ends Get home safe and a running
  /// check-in timer in one go. Returns how many contacts were told.
  Future<int> imHome(String smsText) async {
    await GetHomeSafeService.stop();
    await CheckInService.checkIn();
    final sent = await BackgroundServices.sendSosAlert(
      smsText,
      withLocation: false,
    );
    await _load();
    return sent;
  }
}

final getHomeSafeViewModelProvider =
    NotifierProvider<GetHomeSafeViewModel, GetHomeSafeUiState>(
      GetHomeSafeViewModel.new,
    );
