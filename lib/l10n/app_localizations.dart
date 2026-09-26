import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('nl'),
  ];

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change the app language'**
  String get changeLanguage;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as phone'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get stop;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @slogan1.
  ///
  /// In en, this message translates to:
  /// **'You are not alone'**
  String get slogan1;

  /// No description provided for @slogan2.
  ///
  /// In en, this message translates to:
  /// **'Safe together'**
  String get slogan2;

  /// No description provided for @slogan3.
  ///
  /// In en, this message translates to:
  /// **'With you, always'**
  String get slogan3;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @emergency112Title.
  ///
  /// In en, this message translates to:
  /// **'Emergency number'**
  String get emergency112Title;

  /// No description provided for @emergency112Desc.
  ///
  /// In en, this message translates to:
  /// **'Life in danger: police, ambulance or fire brigade'**
  String get emergency112Desc;

  /// No description provided for @policeNonUrgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Police, not urgent'**
  String get policeNonUrgentTitle;

  /// No description provided for @policeNonUrgentDesc.
  ///
  /// In en, this message translates to:
  /// **'Report something or ask a question when there is no danger now'**
  String get policeNonUrgentDesc;

  /// No description provided for @veiligThuisTitle.
  ///
  /// In en, this message translates to:
  /// **'Veilig Thuis'**
  String get veiligThuisTitle;

  /// No description provided for @veiligThuisDesc.
  ///
  /// In en, this message translates to:
  /// **'Domestic violence or child abuse, free and 24/7'**
  String get veiligThuisDesc;

  /// No description provided for @suicidePreventionTitle.
  ///
  /// In en, this message translates to:
  /// **'113 Suicide Prevention'**
  String get suicidePreventionTitle;

  /// No description provided for @suicidePreventionDesc.
  ///
  /// In en, this message translates to:
  /// **'Talk to someone, free and 24/7'**
  String get suicidePreventionDesc;

  /// No description provided for @switchboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Switchboard (LGBTQ+)'**
  String get switchboardTitle;

  /// No description provided for @switchboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Talk anonymously about LGBTQ+ questions, free'**
  String get switchboardDesc;

  /// No description provided for @safePlaces.
  ///
  /// In en, this message translates to:
  /// **'Nearby safe places'**
  String get safePlaces;

  /// No description provided for @policeStations.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get policeStations;

  /// No description provided for @hospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospitals;

  /// No description provided for @pharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacies;

  /// No description provided for @busStations.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get busStations;

  /// No description provided for @mapsQueryPolice.
  ///
  /// In en, this message translates to:
  /// **'police station'**
  String get mapsQueryPolice;

  /// No description provided for @mapsQueryHospital.
  ///
  /// In en, this message translates to:
  /// **'hospital'**
  String get mapsQueryHospital;

  /// No description provided for @mapsQueryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'pharmacy'**
  String get mapsQueryPharmacy;

  /// No description provided for @mapsQueryTransport.
  ///
  /// In en, this message translates to:
  /// **'train station'**
  String get mapsQueryTransport;

  /// No description provided for @mapsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Call an emergency number.'**
  String get mapsOpenFailed;

  /// No description provided for @resourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Help and information'**
  String get resourcesTitle;

  /// No description provided for @resVeiligThuisTitle.
  ///
  /// In en, this message translates to:
  /// **'Veilig Thuis'**
  String get resVeiligThuisTitle;

  /// No description provided for @resVeiligThuisDesc.
  ///
  /// In en, this message translates to:
  /// **'Advice and help with domestic violence and child abuse, for victims, witnesses and professionals. Call or chat, anonymously if you want.'**
  String get resVeiligThuisDesc;

  /// No description provided for @resCsgTitle.
  ///
  /// In en, this message translates to:
  /// **'Centrum Seksueel Geweld'**
  String get resCsgTitle;

  /// No description provided for @resCsgDesc.
  ///
  /// In en, this message translates to:
  /// **'Medical, forensic and psychological help after sexual violence. Get in touch as soon as possible, ideally within 7 days. Free, 24/7.'**
  String get resCsgDesc;

  /// No description provided for @resSlachtofferhulpTitle.
  ///
  /// In en, this message translates to:
  /// **'Slachtofferhulp Nederland'**
  String get resSlachtofferhulpTitle;

  /// No description provided for @resSlachtofferhulpDesc.
  ///
  /// In en, this message translates to:
  /// **'Free practical, legal and emotional support after a crime, traffic accident or disaster.'**
  String get resSlachtofferhulpDesc;

  /// No description provided for @res113Title.
  ///
  /// In en, this message translates to:
  /// **'113 Suicide Prevention'**
  String get res113Title;

  /// No description provided for @res113Desc.
  ///
  /// In en, this message translates to:
  /// **'Are you thinking about suicide, or worried about someone? Talk anonymously with a trained counsellor.'**
  String get res113Desc;

  /// No description provided for @resAangifteTitle.
  ///
  /// In en, this message translates to:
  /// **'Report to the police'**
  String get resAangifteTitle;

  /// No description provided for @resAangifteDesc.
  ///
  /// In en, this message translates to:
  /// **'How to file a report online, by phone or at a police station, and what happens next.'**
  String get resAangifteDesc;

  /// No description provided for @res112Title.
  ///
  /// In en, this message translates to:
  /// **'When to call 112'**
  String get res112Title;

  /// No description provided for @res112Desc.
  ///
  /// In en, this message translates to:
  /// **'Call 112 only when life is in danger or a crime is happening now. For everything else, call the police on 0900-8844.'**
  String get res112Desc;

  /// No description provided for @resSwitchboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Switchboard'**
  String get resSwitchboardTitle;

  /// No description provided for @resSwitchboardDesc.
  ///
  /// In en, this message translates to:
  /// **'The LGBTQ+ helpline of COC Nederland. Talk anonymously and confidentially about questions, doubts or your story, by phone or chat, free of charge.'**
  String get resSwitchboardDesc;

  /// No description provided for @callNumber.
  ///
  /// In en, this message translates to:
  /// **'Call {number}'**
  String callNumber(String number);

  /// No description provided for @openWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get openWebsite;

  /// No description provided for @quickExit.
  ///
  /// In en, this message translates to:
  /// **'Quick exit'**
  String get quickExit;

  /// No description provided for @quickExitHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the weather and closes MetJou'**
  String get quickExitHint;

  /// No description provided for @getHomeSafe.
  ///
  /// In en, this message translates to:
  /// **'Get home safe'**
  String get getHomeSafe;

  /// No description provided for @getHomeSafeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your location on the way'**
  String get getHomeSafeSubtitle;

  /// No description provided for @getHomeSafeInterval.
  ///
  /// In en, this message translates to:
  /// **'Your location is sent to one contact every 15 minutes'**
  String get getHomeSafeInterval;

  /// No description provided for @getHomeSafeActive.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get getHomeSafeActive;

  /// No description provided for @getHomeSafeOn.
  ///
  /// In en, this message translates to:
  /// **'Get home safe is on'**
  String get getHomeSafeOn;

  /// No description provided for @getHomeSafeOff.
  ///
  /// In en, this message translates to:
  /// **'Get home safe is off'**
  String get getHomeSafeOff;

  /// No description provided for @selectContactFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a contact first'**
  String get selectContactFirst;

  /// No description provided for @ghsRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get ghsRepeat;

  /// No description provided for @ghsOnce.
  ///
  /// In en, this message translates to:
  /// **'Once, at a set time'**
  String get ghsOnce;

  /// No description provided for @ghsEvery.
  ///
  /// In en, this message translates to:
  /// **'Every {minutes} min'**
  String ghsEvery(int minutes);

  /// No description provided for @ghsCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get ghsCustom;

  /// No description provided for @ghsCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Every how many minutes?'**
  String get ghsCustomTitle;

  /// No description provided for @ghsPickTime.
  ///
  /// In en, this message translates to:
  /// **'Choose date and time'**
  String get ghsPickTime;

  /// No description provided for @ghsAt.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String ghsAt(String time);

  /// No description provided for @ghsEveryMinuteWarning.
  ///
  /// In en, this message translates to:
  /// **'Sends an SMS every minute: 60 per hour, at your normal SMS rates.'**
  String get ghsEveryMinuteWarning;

  /// No description provided for @ghsTimeInPast.
  ///
  /// In en, this message translates to:
  /// **'Choose a time in the future'**
  String get ghsTimeInPast;

  /// No description provided for @ghsStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get ghsStart;

  /// No description provided for @ghsStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get ghsStop;

  /// No description provided for @ghsChooseContact.
  ///
  /// In en, this message translates to:
  /// **'Who gets your location?'**
  String get ghsChooseContact;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in timer'**
  String get checkIn;

  /// No description provided for @checkInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts your contacts if you don\'t check in on time'**
  String get checkInSubtitle;

  /// No description provided for @checkInBefore.
  ///
  /// In en, this message translates to:
  /// **'Check in before {time}'**
  String checkInBefore(String time);

  /// No description provided for @checkInSafe.
  ///
  /// In en, this message translates to:
  /// **'I\'m safe'**
  String get checkInSafe;

  /// No description provided for @checkInExtend.
  ///
  /// In en, this message translates to:
  /// **'+{minutes} min'**
  String checkInExtend(int minutes);

  /// No description provided for @checkInHowLong.
  ///
  /// In en, this message translates to:
  /// **'Alert my contacts if I don\'t check in within'**
  String get checkInHowLong;

  /// No description provided for @checkInNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Tap I\'m safe when you are OK'**
  String get checkInNotifBody;

  /// No description provided for @checkInAlerted.
  ///
  /// In en, this message translates to:
  /// **'Your contacts were alerted'**
  String get checkInAlerted;

  /// No description provided for @checkInDone.
  ///
  /// In en, this message translates to:
  /// **'Checked in. Glad you\'re safe.'**
  String get checkInDone;

  /// No description provided for @quickTools.
  ///
  /// In en, this message translates to:
  /// **'Quick help'**
  String get quickTools;

  /// No description provided for @fakeCall.
  ///
  /// In en, this message translates to:
  /// **'Fake call'**
  String get fakeCall;

  /// No description provided for @fakeCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A realistic incoming call, to get away'**
  String get fakeCallSubtitle;

  /// No description provided for @fakeCallCaller.
  ///
  /// In en, this message translates to:
  /// **'Caller name'**
  String get fakeCallCaller;

  /// No description provided for @fakeCallDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Mom'**
  String get fakeCallDefaultName;

  /// No description provided for @fakeCallMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get fakeCallMobile;

  /// No description provided for @fakeCallWhen.
  ///
  /// In en, this message translates to:
  /// **'Ring in'**
  String get fakeCallWhen;

  /// No description provided for @fakeCallNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get fakeCallNow;

  /// No description provided for @fakeCallDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get fakeCallDecline;

  /// No description provided for @fakeCallAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get fakeCallAccept;

  /// No description provided for @fakeCallEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get fakeCallEnd;

  /// No description provided for @fakeCallStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get fakeCallStart;

  /// No description provided for @fakeCallFrom.
  ///
  /// In en, this message translates to:
  /// **'Incoming call: {name}'**
  String fakeCallFrom(String name);

  /// No description provided for @siren.
  ///
  /// In en, this message translates to:
  /// **'Siren'**
  String get siren;

  /// No description provided for @sirenSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sirenSound;

  /// No description provided for @sirenFlash.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get sirenFlash;

  /// No description provided for @sirenStop.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get sirenStop;

  /// No description provided for @smsCheckInMissed.
  ///
  /// In en, this message translates to:
  /// **'I did not check in on time with MetJou. I may need help. My location:'**
  String get smsCheckInMissed;

  /// No description provided for @sosContacts.
  ///
  /// In en, this message translates to:
  /// **'SOS contacts'**
  String get sosContacts;

  /// No description provided for @noContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get noContacts;

  /// No description provided for @addContactHint.
  ///
  /// In en, this message translates to:
  /// **'Add at least one contact'**
  String get addContactHint;

  /// No description provided for @swipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete a contact'**
  String get swipeToDelete;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noName;

  /// No description provided for @contactSaved.
  ///
  /// In en, this message translates to:
  /// **'Contact saved'**
  String get contactSaved;

  /// No description provided for @contactNotAdded.
  ///
  /// In en, this message translates to:
  /// **'Already saved, or you already have {max} contacts'**
  String contactNotAdded(int max);

  /// No description provided for @contactRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String contactRemoved(String name);

  /// No description provided for @contactCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max}'**
  String contactCount(int count, int max);

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterPin;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN, try again'**
  String get wrongPin;

  /// No description provided for @gladYouAreSafe.
  ///
  /// In en, this message translates to:
  /// **'Glad you are safe'**
  String get gladYouAreSafe;

  /// No description provided for @notifyingSafe.
  ///
  /// In en, this message translates to:
  /// **'Letting your contacts know you are safe'**
  String get notifyingSafe;

  /// No description provided for @alertSent.
  ///
  /// In en, this message translates to:
  /// **'Alert sent'**
  String get alertSent;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No SOS contacts found'**
  String get noContactsFound;

  /// No description provided for @smsShake.
  ///
  /// In en, this message translates to:
  /// **'Help! I shook my phone to send this alert. My location:'**
  String get smsShake;

  /// No description provided for @smsSos.
  ///
  /// In en, this message translates to:
  /// **'Help! This is an SOS from MetJou. My location:'**
  String get smsSos;

  /// No description provided for @smsSafe.
  ///
  /// In en, this message translates to:
  /// **'I am safe now. Please ignore my SOS alert.'**
  String get smsSafe;

  /// No description provided for @smsGetHomeSafe.
  ///
  /// In en, this message translates to:
  /// **'I am on my way home. My location:'**
  String get smsGetHomeSafe;

  /// No description provided for @smsNoLocation.
  ///
  /// In en, this message translates to:
  /// **'(location not available)'**
  String get smsNoLocation;

  /// No description provided for @smsTest.
  ///
  /// In en, this message translates to:
  /// **'This is a TEST from MetJou, no need to act. If I really need help, you will get a message like this. My location:'**
  String get smsTest;

  /// No description provided for @smsHome.
  ///
  /// In en, this message translates to:
  /// **'I\'m home safe. (MetJou)'**
  String get smsHome;

  /// No description provided for @imHome.
  ///
  /// In en, this message translates to:
  /// **'I\'m home'**
  String get imHome;

  /// No description provided for @imHomeSent.
  ///
  /// In en, this message translates to:
  /// **'Your contacts know you are home'**
  String get imHomeSent;

  /// No description provided for @testAlert.
  ///
  /// In en, this message translates to:
  /// **'Send a test alert'**
  String get testAlert;

  /// No description provided for @testAlertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check that your contacts receive your alerts'**
  String get testAlertSubtitle;

  /// No description provided for @testAlertConfirm.
  ///
  /// In en, this message translates to:
  /// **'Send a test message with your location to all SOS contacts?'**
  String get testAlertConfirm;

  /// No description provided for @testAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Test sent to {count} contacts'**
  String testAlertSent(int count);

  /// No description provided for @medicalId.
  ///
  /// In en, this message translates to:
  /// **'Medical ID'**
  String get medicalId;

  /// No description provided for @medicalIdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Health details for first responders, also on the lock screen'**
  String get medicalIdSubtitle;

  /// No description provided for @medName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get medName;

  /// No description provided for @medBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get medBirth;

  /// No description provided for @medBlood.
  ///
  /// In en, this message translates to:
  /// **'Blood type'**
  String get medBlood;

  /// No description provided for @medAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get medAllergies;

  /// No description provided for @medMedications.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medMedications;

  /// No description provided for @medConditions.
  ///
  /// In en, this message translates to:
  /// **'Medical conditions'**
  String get medConditions;

  /// No description provided for @medEmergencyName.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get medEmergencyName;

  /// No description provided for @medEmergencyPhone.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact phone'**
  String get medEmergencyPhone;

  /// No description provided for @medNotes.
  ///
  /// In en, this message translates to:
  /// **'Other notes'**
  String get medNotes;

  /// No description provided for @medLockScreen.
  ///
  /// In en, this message translates to:
  /// **'Show on lock screen'**
  String get medLockScreen;

  /// No description provided for @medLockScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Anyone holding your phone can read this without unlocking it'**
  String get medLockScreenSubtitle;

  /// No description provided for @medUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get medUnknown;

  /// No description provided for @medSaved.
  ///
  /// In en, this message translates to:
  /// **'Medical ID saved'**
  String get medSaved;

  /// No description provided for @diary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diary;

  /// No description provided for @diaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident diary'**
  String get diaryTitle;

  /// No description provided for @diaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Write down what happened, when and where, and add photos if you want. You can export everything as a PDF for the police or Veilig Thuis.'**
  String get diaryEmpty;

  /// No description provided for @diaryNoPin.
  ///
  /// In en, this message translates to:
  /// **'Tip: set a PIN in Settings so only you can open the diary.'**
  String get diaryNoPin;

  /// No description provided for @diaryNew.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get diaryNew;

  /// No description provided for @diaryWhat.
  ///
  /// In en, this message translates to:
  /// **'What happened? Where, who was there?'**
  String get diaryWhat;

  /// No description provided for @diaryWhen.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get diaryWhen;

  /// No description provided for @diaryPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get diaryPhotos;

  /// No description provided for @diaryCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get diaryCamera;

  /// No description provided for @diaryGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get diaryGallery;

  /// No description provided for @diaryExport.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get diaryExport;

  /// No description provided for @diaryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get diaryDelete;

  /// No description provided for @diaryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry and its photos?'**
  String get diaryDeleteConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @diaryPdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'Made with MetJou on {date}'**
  String diaryPdfGenerated(String date);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @smsLowBattery.
  ///
  /// In en, this message translates to:
  /// **'My phone battery is almost empty ({level}%). My last location:'**
  String smsLowBattery(int level);

  /// No description provided for @lowBattery.
  ///
  /// In en, this message translates to:
  /// **'Low battery message'**
  String get lowBattery;

  /// No description provided for @lowBatterySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sends your location to your contacts once when the battery drops to 10%'**
  String get lowBatterySubtitle;

  /// No description provided for @notifShakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Shake is on'**
  String get notifShakeTitle;

  /// No description provided for @notifShakeBody.
  ///
  /// In en, this message translates to:
  /// **'Shake your phone to alert your contacts'**
  String get notifShakeBody;

  /// No description provided for @notifShakeSent.
  ///
  /// In en, this message translates to:
  /// **'SOS sent to your contacts'**
  String get notifShakeSent;

  /// No description provided for @notifShakeNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts found. Call 112.'**
  String get notifShakeNoContacts;

  /// No description provided for @countdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Sending SOS in {seconds}'**
  String countdownTitle(int seconds);

  /// No description provided for @countdownBody.
  ///
  /// In en, this message translates to:
  /// **'Shake detected. Tap Cancel if this was a mistake.'**
  String get countdownBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @countdownSetting.
  ///
  /// In en, this message translates to:
  /// **'Countdown before a shake alert'**
  String get countdownSetting;

  /// No description provided for @countdownSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time to cancel an alert sent by shaking'**
  String get countdownSettingSubtitle;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String seconds(int seconds);

  /// No description provided for @alertCancelled.
  ///
  /// In en, this message translates to:
  /// **'Alert cancelled'**
  String get alertCancelled;

  /// No description provided for @notifRecording.
  ///
  /// In en, this message translates to:
  /// **'Audio recording'**
  String get notifRecording;

  /// No description provided for @notifRecordingReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to record'**
  String get notifRecordingReady;

  /// No description provided for @notifRecordingStarted.
  ///
  /// In en, this message translates to:
  /// **'Recording started'**
  String get notifRecordingStarted;

  /// No description provided for @notifRecordingStopped.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped'**
  String get notifRecordingStopped;

  /// No description provided for @notifRecordingSaved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved: {location}'**
  String notifRecordingSaved(String location);

  /// No description provided for @notifRecordingFailed.
  ///
  /// In en, this message translates to:
  /// **'Recording failed'**
  String get notifRecordingFailed;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPin;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'The PIN stops an SOS alert and protects Settings and your contacts'**
  String get pinRequired;

  /// No description provided for @discreetMode.
  ///
  /// In en, this message translates to:
  /// **'Discreet mode'**
  String get discreetMode;

  /// No description provided for @discreetModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows MetJou as \'Calculator\' and turns off status notifications'**
  String get discreetModeSubtitle;

  /// No description provided for @discreetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on discreet mode?'**
  String get discreetConfirmTitle;

  /// No description provided for @discreetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'MetJou\'s icon and name change to a calculator on your home screen, status notifications are turned off, and the recent apps screen shows no preview. The home screen can take a moment to update. Android still shows the name MetJou in notification headers and under Settings > Apps.'**
  String get discreetConfirmBody;

  /// No description provided for @discreetNotification.
  ///
  /// In en, this message translates to:
  /// **'Service active'**
  String get discreetNotification;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @pinChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get pinChanged;

  /// No description provided for @currentPinWrong.
  ///
  /// In en, this message translates to:
  /// **'The current PIN does not match. Try again.'**
  String get currentPinWrong;

  /// No description provided for @enterCurrentPinFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN first'**
  String get enterCurrentPinFirst;

  /// No description provided for @alertsSection.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsSection;

  /// No description provided for @safeShake.
  ///
  /// In en, this message translates to:
  /// **'Safe Shake'**
  String get safeShake;

  /// No description provided for @safeShakeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listen for a shake in the background'**
  String get safeShakeSubtitle;

  /// No description provided for @safeShakeExplain.
  ///
  /// In en, this message translates to:
  /// **'Safe Shake is the key feature of MetJou. When it is on, the app listens for a shake in the background. If you feel unsafe, shake your phone firmly to send an SOS to your contacts without opening the app.'**
  String get safeShakeExplain;

  /// No description provided for @audioRecord.
  ///
  /// In en, this message translates to:
  /// **'Audio recording'**
  String get audioRecord;

  /// No description provided for @audioRecordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record audio as evidence when you shake'**
  String get audioRecordSubtitle;

  /// No description provided for @audioRecordLength.
  ///
  /// In en, this message translates to:
  /// **'Recording length'**
  String get audioRecordLength;

  /// No description provided for @audioRecordLengthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maximum length of one recording'**
  String get audioRecordLengthSubtitle;

  /// No description provided for @audioRecordFolder.
  ///
  /// In en, this message translates to:
  /// **'Recording folder'**
  String get audioRecordFolder;

  /// No description provided for @audioRecordFolderPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private app storage (removed with the app)'**
  String get audioRecordFolderPrivate;

  /// No description provided for @audioRecordFolderChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder'**
  String get audioRecordFolderChoose;

  /// No description provided for @audioRecordFolderReset.
  ///
  /// In en, this message translates to:
  /// **'Use private app storage'**
  String get audioRecordFolderReset;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutes(int count);

  /// No description provided for @appSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appSection;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 MetJou'**
  String get copyright;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'You deserve to be safe!'**
  String get tagline;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'MetJou keeps you connected with the people who care about you. Share your live location through SOS alerts, reach emergency services quickly, and get help when something happens. Your personal companion.'**
  String get aboutDescription;

  /// No description provided for @aboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'MetJou helps you stay in touch with the people who look out for you.'**
  String get aboutLegalese;

  /// No description provided for @onbIntro.
  ///
  /// In en, this message translates to:
  /// **'This is the first step towards a safer world.'**
  String get onbIntro;

  /// No description provided for @onbBegin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get onbBegin;

  /// No description provided for @onbLocationText.
  ///
  /// In en, this message translates to:
  /// **'MetJou uses your location for SOS messages and for Get home safe, also when the app is closed.'**
  String get onbLocationText;

  /// No description provided for @onbLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get onbLocationButton;

  /// No description provided for @onbMicText.
  ///
  /// In en, this message translates to:
  /// **'When you shake your phone, MetJou can record audio as evidence. Allow the microphone and notifications to use this.'**
  String get onbMicText;

  /// No description provided for @onbMicButton.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone'**
  String get onbMicButton;

  /// No description provided for @onbSmsText.
  ///
  /// In en, this message translates to:
  /// **'MetJou needs SMS and phone access to alert your contacts and to call emergency numbers.'**
  String get onbSmsText;

  /// No description provided for @onbSmsButton.
  ///
  /// In en, this message translates to:
  /// **'Allow SMS and phone'**
  String get onbSmsButton;

  /// No description provided for @onbWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onbWelcome;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbGetStarted;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept our'**
  String get termsPrefix;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsLink;

  /// No description provided for @termsAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get termsAnd;

  /// No description provided for @privacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
