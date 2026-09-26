// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change the app language';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'Same as phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get stop => 'STOP';

  @override
  String get seeMore => 'See more';

  @override
  String get slogan1 => 'You are not alone';

  @override
  String get slogan2 => 'Safe together';

  @override
  String get slogan3 => 'With you, always';

  @override
  String get emergency => 'Emergency';

  @override
  String get emergency112Title => 'Emergency number';

  @override
  String get emergency112Desc =>
      'Life in danger: police, ambulance or fire brigade';

  @override
  String get policeNonUrgentTitle => 'Police, not urgent';

  @override
  String get policeNonUrgentDesc =>
      'Report something or ask a question when there is no danger now';

  @override
  String get veiligThuisTitle => 'Veilig Thuis';

  @override
  String get veiligThuisDesc =>
      'Domestic violence or child abuse, free and 24/7';

  @override
  String get suicidePreventionTitle => '113 Suicide Prevention';

  @override
  String get suicidePreventionDesc => 'Talk to someone, free and 24/7';

  @override
  String get switchboardTitle => 'Switchboard (LGBTQ+)';

  @override
  String get switchboardDesc => 'Talk anonymously about LGBTQ+ questions, free';

  @override
  String get safePlaces => 'Nearby safe places';

  @override
  String get policeStations => 'Police';

  @override
  String get hospitals => 'Hospital';

  @override
  String get pharmacies => 'Pharmacy';

  @override
  String get busStations => 'Transit';

  @override
  String get mapsQueryPolice => 'police station';

  @override
  String get mapsQueryHospital => 'hospital';

  @override
  String get mapsQueryPharmacy => 'pharmacy';

  @override
  String get mapsQueryTransport => 'train station';

  @override
  String get mapsOpenFailed =>
      'Something went wrong. Call an emergency number.';

  @override
  String get resourcesTitle => 'Help and information';

  @override
  String get resVeiligThuisTitle => 'Veilig Thuis';

  @override
  String get resVeiligThuisDesc =>
      'Advice and help with domestic violence and child abuse, for victims, witnesses and professionals. Call or chat, anonymously if you want.';

  @override
  String get resCsgTitle => 'Centrum Seksueel Geweld';

  @override
  String get resCsgDesc =>
      'Medical, forensic and psychological help after sexual violence. Get in touch as soon as possible, ideally within 7 days. Free, 24/7.';

  @override
  String get resSlachtofferhulpTitle => 'Slachtofferhulp Nederland';

  @override
  String get resSlachtofferhulpDesc =>
      'Free practical, legal and emotional support after a crime, traffic accident or disaster.';

  @override
  String get res113Title => '113 Suicide Prevention';

  @override
  String get res113Desc =>
      'Are you thinking about suicide, or worried about someone? Talk anonymously with a trained counsellor.';

  @override
  String get resAangifteTitle => 'Report to the police';

  @override
  String get resAangifteDesc =>
      'How to file a report online, by phone or at a police station, and what happens next.';

  @override
  String get res112Title => 'When to call 112';

  @override
  String get res112Desc =>
      'Call 112 only when life is in danger or a crime is happening now. For everything else, call the police on 0900-8844.';

  @override
  String get resSwitchboardTitle => 'Switchboard';

  @override
  String get resSwitchboardDesc =>
      'The LGBTQ+ helpline of COC Nederland. Talk anonymously and confidentially about questions, doubts or your story, by phone or chat, free of charge.';

  @override
  String callNumber(String number) {
    return 'Call $number';
  }

  @override
  String get openWebsite => 'Open website';

  @override
  String get quickExit => 'Quick exit';

  @override
  String get quickExitHint => 'Opens the weather and closes MetJou';

  @override
  String get getHomeSafe => 'Get home safe';

  @override
  String get getHomeSafeSubtitle => 'Share your location on the way';

  @override
  String get getHomeSafeInterval =>
      'Your location is sent to one contact every 15 minutes';

  @override
  String get getHomeSafeActive => 'Active now';

  @override
  String get getHomeSafeOn => 'Get home safe is on';

  @override
  String get getHomeSafeOff => 'Get home safe is off';

  @override
  String get selectContactFirst => 'Select a contact first';

  @override
  String get ghsRepeat => 'Repeat';

  @override
  String get ghsOnce => 'Once, at a set time';

  @override
  String ghsEvery(int minutes) {
    return 'Every $minutes min';
  }

  @override
  String get ghsCustom => 'Custom';

  @override
  String get ghsCustomTitle => 'Every how many minutes?';

  @override
  String get ghsPickTime => 'Choose date and time';

  @override
  String ghsAt(String time) {
    return 'At $time';
  }

  @override
  String get ghsEveryMinuteWarning =>
      'Sends an SMS every minute: 60 per hour, at your normal SMS rates.';

  @override
  String get ghsTimeInPast => 'Choose a time in the future';

  @override
  String get ghsStart => 'Start';

  @override
  String get ghsStop => 'Stop';

  @override
  String get ghsChooseContact => 'Who gets your location?';

  @override
  String get checkIn => 'Check-in timer';

  @override
  String get checkInSubtitle =>
      'Alerts your contacts if you don\'t check in on time';

  @override
  String checkInBefore(String time) {
    return 'Check in before $time';
  }

  @override
  String get checkInSafe => 'I\'m safe';

  @override
  String checkInExtend(int minutes) {
    return '+$minutes min';
  }

  @override
  String get checkInHowLong => 'Alert my contacts if I don\'t check in within';

  @override
  String get checkInNotifBody => 'Tap I\'m safe when you are OK';

  @override
  String get checkInAlerted => 'Your contacts were alerted';

  @override
  String get checkInDone => 'Checked in. Glad you\'re safe.';

  @override
  String get quickTools => 'Quick help';

  @override
  String get fakeCall => 'Fake call';

  @override
  String get fakeCallSubtitle => 'A realistic incoming call, to get away';

  @override
  String get fakeCallCaller => 'Caller name';

  @override
  String get fakeCallDefaultName => 'Mom';

  @override
  String get fakeCallMobile => 'Mobile';

  @override
  String get fakeCallWhen => 'Ring in';

  @override
  String get fakeCallNow => 'Now';

  @override
  String get fakeCallDecline => 'Decline';

  @override
  String get fakeCallAccept => 'Accept';

  @override
  String get fakeCallEnd => 'End';

  @override
  String get fakeCallStart => 'Start';

  @override
  String fakeCallFrom(String name) {
    return 'Incoming call: $name';
  }

  @override
  String get siren => 'Siren';

  @override
  String get sirenSound => 'Sound';

  @override
  String get sirenFlash => 'Flashlight';

  @override
  String get sirenStop => 'STOP';

  @override
  String get smsCheckInMissed =>
      'I did not check in on time with MetJou. I may need help. My location:';

  @override
  String get sosContacts => 'SOS contacts';

  @override
  String get noContacts => 'No contacts yet';

  @override
  String get addContactHint => 'Add at least one contact';

  @override
  String get swipeToDelete => 'Swipe left to delete a contact';

  @override
  String get noName => 'No name';

  @override
  String get contactSaved => 'Contact saved';

  @override
  String contactNotAdded(int max) {
    return 'Already saved, or you already have $max contacts';
  }

  @override
  String contactRemoved(String name) {
    return '$name removed';
  }

  @override
  String contactCount(int count, int max) {
    return '$count of $max';
  }

  @override
  String get enterPin => 'Enter your PIN';

  @override
  String get wrongPin => 'Wrong PIN, try again';

  @override
  String get gladYouAreSafe => 'Glad you are safe';

  @override
  String get notifyingSafe => 'Letting your contacts know you are safe';

  @override
  String get alertSent => 'Alert sent';

  @override
  String get noContactsFound => 'No SOS contacts found';

  @override
  String get smsShake =>
      'Help! I shook my phone to send this alert. My location:';

  @override
  String get smsSos => 'Help! This is an SOS from MetJou. My location:';

  @override
  String get smsSafe => 'I am safe now. Please ignore my SOS alert.';

  @override
  String get smsGetHomeSafe => 'I am on my way home. My location:';

  @override
  String get smsNoLocation => '(location not available)';

  @override
  String get smsTest =>
      'This is a TEST from MetJou, no need to act. If I really need help, you will get a message like this. My location:';

  @override
  String get smsHome => 'I\'m home safe. (MetJou)';

  @override
  String get smsFall =>
      'MetJou detected a hard fall and I did not respond. I may need help. My location:';

  @override
  String get fallDetection => 'Fall detection';

  @override
  String get fallDetectionSubtitle =>
      'After a hard fall without movement, starts the SOS countdown (at least 15 s to cancel)';

  @override
  String get imHome => 'I\'m home';

  @override
  String get imHomeSent => 'Your contacts know you are home';

  @override
  String get testAlert => 'Send a test alert';

  @override
  String get testAlertSubtitle =>
      'Check that your contacts receive your alerts';

  @override
  String get testAlertConfirm =>
      'Send a test message with your location to all SOS contacts?';

  @override
  String testAlertSent(int count) {
    return 'Test sent to $count contacts';
  }

  @override
  String get medicalId => 'Medical ID';

  @override
  String get medicalIdSubtitle =>
      'Health details for first responders, also on the lock screen';

  @override
  String get medName => 'Name';

  @override
  String get medBirth => 'Date of birth';

  @override
  String get medBlood => 'Blood type';

  @override
  String get medAllergies => 'Allergies';

  @override
  String get medMedications => 'Medication';

  @override
  String get medConditions => 'Medical conditions';

  @override
  String get medEmergencyName => 'Emergency contact';

  @override
  String get medEmergencyPhone => 'Emergency contact phone';

  @override
  String get medNotes => 'Other notes';

  @override
  String get medLockScreen => 'Show on lock screen';

  @override
  String get medLockScreenSubtitle =>
      'Anyone holding your phone can read this without unlocking it';

  @override
  String get medUnknown => 'Unknown';

  @override
  String get medSaved => 'Medical ID saved';

  @override
  String get diary => 'Diary';

  @override
  String get diaryTitle => 'Incident diary';

  @override
  String get diaryEmpty =>
      'No entries yet. Write down what happened, when and where, and add photos if you want. You can export everything as a PDF for the police or Veilig Thuis.';

  @override
  String get diaryNoPin =>
      'Tip: set a PIN in Settings so only you can open the diary.';

  @override
  String get diaryNew => 'New entry';

  @override
  String get diaryWhat => 'What happened? Where, who was there?';

  @override
  String get diaryWhen => 'Date and time';

  @override
  String get diaryPhotos => 'Photos';

  @override
  String get diaryCamera => 'Take a photo';

  @override
  String get diaryGallery => 'Choose from gallery';

  @override
  String get diaryExport => 'Export as PDF';

  @override
  String get diaryDelete => 'Delete entry';

  @override
  String get diaryDeleteConfirm => 'Delete this entry and its photos?';

  @override
  String get delete => 'Delete';

  @override
  String diaryPdfGenerated(String date) {
    return 'Made with MetJou on $date';
  }

  @override
  String get send => 'Send';

  @override
  String smsLowBattery(int level) {
    return 'My phone battery is almost empty ($level%). My last location:';
  }

  @override
  String get lowBattery => 'Low battery message';

  @override
  String get lowBatterySubtitle =>
      'Sends your location to your contacts once when the battery drops to 10%';

  @override
  String get notifShakeTitle => 'Safe Shake is on';

  @override
  String get notifShakeBody => 'Shake your phone to alert your contacts';

  @override
  String get notifShakeSent => 'SOS sent to your contacts';

  @override
  String get notifShakeNoContacts => 'No contacts found. Call 112.';

  @override
  String countdownTitle(int seconds) {
    return 'Sending SOS in $seconds';
  }

  @override
  String get countdownBody =>
      'Shake detected. Tap Cancel if this was a mistake.';

  @override
  String get cancel => 'Cancel';

  @override
  String get countdownSetting => 'Countdown before a shake alert';

  @override
  String get countdownSettingSubtitle =>
      'Time to cancel an alert sent by shaking';

  @override
  String get off => 'Off';

  @override
  String seconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get alertCancelled => 'Alert cancelled';

  @override
  String get notifRecording => 'Audio recording';

  @override
  String get notifRecordingReady => 'Ready to record';

  @override
  String get notifRecordingStarted => 'Recording started';

  @override
  String get notifRecordingStopped => 'Recording stopped';

  @override
  String notifRecordingSaved(String location) {
    return 'Recording saved: $location';
  }

  @override
  String get notifRecordingFailed => 'Recording failed';

  @override
  String get createPin => 'Create PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get pinRequired =>
      'The PIN stops an SOS alert and protects Settings and your contacts';

  @override
  String get discreetMode => 'Discreet mode';

  @override
  String get discreetModeSubtitle =>
      'Shows MetJou as \'Calculator\' and turns off status notifications';

  @override
  String get discreetConfirmTitle => 'Turn on discreet mode?';

  @override
  String get discreetConfirmBody =>
      'MetJou\'s icon and name change to a calculator on your home screen, status notifications are turned off, and the recent apps screen shows no preview. The home screen can take a moment to update. Android still shows the name MetJou in notification headers and under Settings > Apps.';

  @override
  String get discreetNotification => 'Service active';

  @override
  String get turnOn => 'Turn on';

  @override
  String get pinChanged => 'PIN changed';

  @override
  String get pinTurnOff => 'Turn off PIN';

  @override
  String get pinTurnedOff => 'PIN turned off';

  @override
  String get currentPinWrong => 'The current PIN does not match. Try again.';

  @override
  String get enterCurrentPinFirst => 'Enter your current PIN first';

  @override
  String get alertsSection => 'Alerts';

  @override
  String get safeShake => 'Safe Shake';

  @override
  String get safeShakeSubtitle => 'Listen for a shake in the background';

  @override
  String get safeShakeExplain =>
      'Safe Shake is the key feature of MetJou. When it is on, the app listens for a shake in the background. If you feel unsafe, shake your phone firmly to send an SOS to your contacts without opening the app.';

  @override
  String get audioRecord => 'Audio recording';

  @override
  String get audioRecordSubtitle => 'Record audio as evidence when you shake';

  @override
  String get audioRecordLength => 'Recording length';

  @override
  String get audioRecordLengthSubtitle => 'Maximum length of one recording';

  @override
  String get audioRecordFolder => 'Recording folder';

  @override
  String get audioRecordFolderPrivate =>
      'Private app storage (removed with the app)';

  @override
  String get audioRecordFolderChoose => 'Choose a folder';

  @override
  String get audioRecordFolderReset => 'Use private app storage';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get appSection => 'App';

  @override
  String get about => 'About';

  @override
  String get licenses => 'Licenses';

  @override
  String get copyright => '© 2026 MetJou';

  @override
  String get tagline => 'You deserve to be safe!';

  @override
  String get aboutDescription =>
      'MetJou keeps you connected with the people who care about you. Share your live location through SOS alerts, reach emergency services quickly, and get help when something happens. Your personal companion.';

  @override
  String get aboutLegalese =>
      'MetJou helps you stay in touch with the people who look out for you.';

  @override
  String get onbIntro => 'This is the first step towards a safer world.';

  @override
  String get onbBegin => 'Let\'s begin';

  @override
  String get onbLocationText =>
      'MetJou uses your location for SOS messages and for Get home safe, also when the app is closed.';

  @override
  String get onbLocationButton => 'Allow location';

  @override
  String get onbMicText =>
      'When you shake your phone, MetJou can record audio as evidence. Allow the microphone and notifications to use this.';

  @override
  String get onbMicButton => 'Allow microphone';

  @override
  String get onbSmsText =>
      'MetJou needs SMS and phone access to alert your contacts and to call emergency numbers.';

  @override
  String get onbSmsButton => 'Allow SMS and phone';

  @override
  String get onbWelcome => 'Welcome';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onbNext => 'Next';

  @override
  String get onbSkip => 'Skip';

  @override
  String get termsPrefix => 'By continuing you accept our';

  @override
  String get termsLink => 'Terms and Conditions';

  @override
  String get termsAnd => 'and';

  @override
  String get privacyLink => 'Privacy Policy';
}
