// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get save => 'Opslaan';

  @override
  String get done => 'Klaar';

  @override
  String get close => 'Sluiten';

  @override
  String get settings => 'Instellingen';

  @override
  String get language => 'Taal';

  @override
  String get changeLanguage => 'Wijzig de taal van de app';

  @override
  String get appearance => 'Weergave';

  @override
  String get themeSystem => 'Zoals de telefoon';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get chooseLanguage => 'Kies je taal';

  @override
  String get stop => 'STOP';

  @override
  String get seeMore => 'Meer';

  @override
  String get slogan1 => 'Je staat er niet alleen voor';

  @override
  String get slogan2 => 'Samen veilig';

  @override
  String get slogan3 => 'Met jou, altijd';

  @override
  String get emergency => 'Noodnummers';

  @override
  String get emergency112Title => 'Alarmnummer';

  @override
  String get emergency112Desc =>
      'Levensgevaar: politie, ambulance of brandweer';

  @override
  String get policeNonUrgentTitle => 'Politie, geen spoed';

  @override
  String get policeNonUrgentDesc =>
      'Iets melden of vragen als er nu geen gevaar is';

  @override
  String get veiligThuisTitle => 'Veilig Thuis';

  @override
  String get veiligThuisDesc =>
      'Huiselijk geweld of kindermishandeling, gratis en 24/7';

  @override
  String get suicidePreventionTitle => '113 Zelfmoordpreventie';

  @override
  String get suicidePreventionDesc => 'Praat met iemand, gratis en 24/7';

  @override
  String get switchboardTitle => 'Switchboard (LHBTIQ+)';

  @override
  String get switchboardDesc => 'Anoniem praten over LHBTIQ+ vragen, gratis';

  @override
  String get safePlaces => 'Veilige plekken in de buurt';

  @override
  String get policeStations => 'Politie';

  @override
  String get hospitals => 'Ziekenhuis';

  @override
  String get pharmacies => 'Apotheek';

  @override
  String get busStations => 'OV';

  @override
  String get mapsQueryPolice => 'politiebureau';

  @override
  String get mapsQueryHospital => 'ziekenhuis';

  @override
  String get mapsQueryPharmacy => 'apotheek';

  @override
  String get mapsQueryTransport => 'treinstation';

  @override
  String get mapsOpenFailed => 'Er ging iets mis. Bel een noodnummer.';

  @override
  String get resourcesTitle => 'Hulp en informatie';

  @override
  String get resVeiligThuisTitle => 'Veilig Thuis';

  @override
  String get resVeiligThuisDesc =>
      'Advies en hulp bij huiselijk geweld en kindermishandeling, voor slachtoffers, omstanders en professionals. Bel of chat, anoniem als je wilt.';

  @override
  String get resCsgTitle => 'Centrum Seksueel Geweld';

  @override
  String get resCsgDesc =>
      'Medische, forensische en psychologische hulp na seksueel geweld. Neem zo snel mogelijk contact op, liefst binnen 7 dagen. Gratis, 24/7.';

  @override
  String get resSlachtofferhulpTitle => 'Slachtofferhulp Nederland';

  @override
  String get resSlachtofferhulpDesc =>
      'Gratis praktische, juridische en emotionele steun na een misdrijf, verkeersongeval of ramp.';

  @override
  String get res113Title => '113 Zelfmoordpreventie';

  @override
  String get res113Desc =>
      'Denk je aan zelfmoord, of maak je je zorgen om iemand? Praat anoniem met een getrainde hulpverlener.';

  @override
  String get resAangifteTitle => 'Aangifte doen bij de politie';

  @override
  String get resAangifteDesc =>
      'Zo doe je aangifte online, telefonisch of op het bureau, en dit gebeurt er daarna.';

  @override
  String get res112Title => 'Wanneer bel je 112?';

  @override
  String get res112Desc =>
      'Bel 112 alleen bij levensgevaar of als er nu een misdrijf gebeurt. Voor al het andere bel je de politie op 0900-8844.';

  @override
  String get resSwitchboardTitle => 'Switchboard';

  @override
  String get resSwitchboardDesc =>
      'De LHBTIQ+ hulplijn van COC Nederland. Praat anoniem en vertrouwelijk over je vragen, twijfels of je verhaal, via telefoon of chat, gratis.';

  @override
  String callNumber(String number) {
    return 'Bel $number';
  }

  @override
  String get openWebsite => 'Open website';

  @override
  String get getHomeSafe => 'Veilig thuiskomen';

  @override
  String get getHomeSafeSubtitle => 'Deel je locatie onderweg';

  @override
  String get getHomeSafeInterval =>
      'Elke 15 minuten wordt je locatie naar één contact gestuurd';

  @override
  String get getHomeSafeActive => 'Nu actief';

  @override
  String get getHomeSafeOn => 'Veilig thuiskomen staat aan';

  @override
  String get getHomeSafeOff => 'Veilig thuiskomen staat uit';

  @override
  String get selectContactFirst => 'Kies eerst een contact';

  @override
  String get ghsRepeat => 'Herhalen';

  @override
  String get ghsOnce => 'Eén keer, op een tijdstip';

  @override
  String ghsEvery(int minutes) {
    return 'Elke $minutes min';
  }

  @override
  String get ghsCustom => 'Anders';

  @override
  String get ghsCustomTitle => 'Om de hoeveel minuten?';

  @override
  String get ghsPickTime => 'Kies datum en tijd';

  @override
  String ghsAt(String time) {
    return 'Op $time';
  }

  @override
  String get ghsEveryMinuteWarning =>
      'Stuurt elke minuut een sms: 60 per uur, tegen je normale sms-tarief.';

  @override
  String get ghsTimeInPast => 'Kies een tijdstip in de toekomst';

  @override
  String get ghsStart => 'Starten';

  @override
  String get ghsStop => 'Stoppen';

  @override
  String get ghsChooseContact => 'Wie krijgt je locatie?';

  @override
  String get sosContacts => 'SOS-contacten';

  @override
  String get noContacts => 'Nog geen contacten';

  @override
  String get addContactHint => 'Voeg minstens één contact toe';

  @override
  String get swipeToDelete => 'Veeg naar links om een contact te verwijderen';

  @override
  String get noName => 'Geen naam';

  @override
  String get contactSaved => 'Contact opgeslagen';

  @override
  String contactNotAdded(int max) {
    return 'Al opgeslagen, of je hebt al $max contacten';
  }

  @override
  String contactRemoved(String name) {
    return '$name verwijderd';
  }

  @override
  String contactCount(int count, int max) {
    return '$count van $max';
  }

  @override
  String get enterPin => 'Voer je pincode in';

  @override
  String get wrongPin => 'Verkeerde pincode, probeer opnieuw';

  @override
  String get gladYouAreSafe => 'Fijn dat je veilig bent';

  @override
  String get notifyingSafe => 'Je contacten krijgen bericht dat je veilig bent';

  @override
  String get alertSent => 'Alarm verstuurd';

  @override
  String get noContactsFound => 'Geen SOS-contacten gevonden';

  @override
  String get smsShake =>
      'Help! Ik heb mijn telefoon geschud om dit alarm te sturen. Mijn locatie:';

  @override
  String get smsSos => 'Help! Dit is een SOS van MetJou. Mijn locatie:';

  @override
  String get smsSafe => 'Ik ben nu veilig. Negeer mijn SOS-alarm.';

  @override
  String get smsGetHomeSafe => 'Ik ben onderweg naar huis. Mijn locatie:';

  @override
  String get smsNoLocation => '(locatie niet beschikbaar)';

  @override
  String get notifShakeTitle => 'Safe Shake staat aan';

  @override
  String get notifShakeBody =>
      'Schud je telefoon om je contacten te waarschuwen';

  @override
  String get notifShakeSent => 'SOS verstuurd naar je contacten';

  @override
  String get notifShakeNoContacts => 'Geen contacten gevonden. Bel 112.';

  @override
  String countdownTitle(int seconds) {
    return 'SOS wordt verstuurd over $seconds';
  }

  @override
  String get countdownBody =>
      'Schudden herkend. Tik op Annuleren als dit per ongeluk was.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get countdownSetting => 'Aftellen voor een schudalarm';

  @override
  String get countdownSettingSubtitle =>
      'Tijd om een alarm door schudden te annuleren';

  @override
  String get off => 'Uit';

  @override
  String seconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get alertCancelled => 'Alarm geannuleerd';

  @override
  String get notifRecording => 'Geluidsopname';

  @override
  String get notifRecordingReady => 'Klaar om op te nemen';

  @override
  String get notifRecordingStarted => 'Opname gestart';

  @override
  String get notifRecordingStopped => 'Opname gestopt';

  @override
  String notifRecordingSaved(String location) {
    return 'Opname opgeslagen: $location';
  }

  @override
  String get notifRecordingFailed => 'Opnemen mislukt';

  @override
  String get createPin => 'Pincode instellen';

  @override
  String get changePin => 'Pincode wijzigen';

  @override
  String get currentPin => 'Huidige pincode';

  @override
  String get newPin => 'Nieuwe pincode';

  @override
  String get pinRequired => 'Met een pincode stop je een SOS-alarm';

  @override
  String get pinChanged => 'Pincode gewijzigd';

  @override
  String get currentPinWrong =>
      'De huidige pincode klopt niet. Probeer opnieuw.';

  @override
  String get enterCurrentPinFirst => 'Voer eerst je huidige pincode in';

  @override
  String get alertsSection => 'Alarmen';

  @override
  String get safeShake => 'Safe Shake';

  @override
  String get safeShakeSubtitle => 'Luister op de achtergrond naar schudden';

  @override
  String get safeShakeExplain =>
      'Safe Shake is de belangrijkste functie van MetJou. Als het aan staat, luistert de app op de achtergrond of je je telefoon schudt. Voel je je onveilig, schud je telefoon dan stevig om een SOS naar je contacten te sturen zonder de app te openen.';

  @override
  String get audioRecord => 'Geluidsopname';

  @override
  String get audioRecordSubtitle =>
      'Neem geluid op als bewijs wanneer je schudt';

  @override
  String get audioRecordLength => 'Opnameduur';

  @override
  String get audioRecordLengthSubtitle => 'Maximale duur van één opname';

  @override
  String get audioRecordFolder => 'Map voor opnames';

  @override
  String get audioRecordFolderPrivate =>
      'Privéopslag van de app (verdwijnt met de app)';

  @override
  String get audioRecordFolderChoose => 'Kies een map';

  @override
  String get audioRecordFolderReset => 'Privéopslag van de app gebruiken';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get appSection => 'App';

  @override
  String get about => 'Over MetJou';

  @override
  String get licenses => 'Licenties';

  @override
  String get copyright => '© 2026 MetJou';

  @override
  String get tagline => 'Jij verdient het om veilig te zijn!';

  @override
  String get aboutDescription =>
      'MetJou houdt je verbonden met de mensen die om je geven. Deel je live locatie via SOS-alarmen, bereik snel de hulpdiensten en krijg hulp als er iets gebeurt. Je persoonlijke steun.';

  @override
  String get aboutLegalese =>
      'MetJou helpt je in contact te blijven met de mensen die op je letten.';

  @override
  String get onbIntro => 'Dit is de eerste stap naar een veiligere wereld.';

  @override
  String get onbBegin => 'Laten we beginnen';

  @override
  String get onbLocationText =>
      'MetJou gebruikt je locatie voor SOS-berichten en voor Veilig thuiskomen, ook als de app gesloten is.';

  @override
  String get onbLocationButton => 'Locatie toestaan';

  @override
  String get onbMicText =>
      'Als je je telefoon schudt, kan MetJou geluid opnemen als bewijs. Sta de microfoon en meldingen toe om dit te gebruiken.';

  @override
  String get onbMicButton => 'Microfoon toestaan';

  @override
  String get onbSmsText =>
      'MetJou heeft toegang tot sms en telefoon nodig om je contacten te waarschuwen en noodnummers te bellen.';

  @override
  String get onbSmsButton => 'Sms en telefoon toestaan';

  @override
  String get onbWelcome => 'Welkom';

  @override
  String get onbGetStarted => 'Aan de slag';

  @override
  String get onbNext => 'Volgende';

  @override
  String get onbSkip => 'Overslaan';

  @override
  String get termsPrefix => 'Door verder te gaan accepteer je onze';

  @override
  String get termsLink => 'Algemene voorwaarden';

  @override
  String get termsAnd => 'en';

  @override
  String get privacyLink => 'Privacyverklaring';
}
