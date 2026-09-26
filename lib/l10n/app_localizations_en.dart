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
  String get hospitals => 'Hospitals';

  @override
  String get pharmacies => 'Pharmacies';

  @override
  String get busStations => 'Public transport';

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
  String get notifShakeTitle => 'Safe Shake is on';

  @override
  String get notifShakeBody => 'Shake your phone to alert your contacts';

  @override
  String get notifShakeSent => 'SOS sent to your contacts';

  @override
  String get notifShakeNoContacts => 'No contacts found. Call 112.';

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
  String get pinRequired => 'A PIN is needed to stop an SOS alert';

  @override
  String get pinChanged => 'PIN changed';

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
