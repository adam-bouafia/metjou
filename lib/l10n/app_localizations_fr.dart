// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get save => 'Enregistrer';

  @override
  String get done => 'Terminé';

  @override
  String get close => 'Fermer';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get changeLanguage => 'Changer la langue de l\'application';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSystem => 'Comme le téléphone';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get chooseLanguage => 'Choisissez votre langue';

  @override
  String get stop => 'STOP';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get slogan1 => 'Vous n\'êtes pas seul·e';

  @override
  String get slogan2 => 'En sécurité, ensemble';

  @override
  String get slogan3 => 'Avec vous, toujours';

  @override
  String get emergency => 'Urgences';

  @override
  String get emergency112Title => 'Numéro d\'urgence';

  @override
  String get emergency112Desc =>
      'Danger de mort : police, ambulance ou pompiers';

  @override
  String get policeNonUrgentTitle => 'Police, non urgent';

  @override
  String get policeNonUrgentDesc =>
      'Signaler ou demander quelque chose sans danger immédiat';

  @override
  String get veiligThuisTitle => 'Veilig Thuis';

  @override
  String get veiligThuisDesc =>
      'Violences conjugales ou maltraitance d\'enfants, gratuit et 24h/24';

  @override
  String get suicidePreventionTitle => '113 Prévention du suicide';

  @override
  String get suicidePreventionDesc => 'Parlez à quelqu\'un, gratuit et 24h/24';

  @override
  String get switchboardTitle => 'Switchboard (LGBTQ+)';

  @override
  String get switchboardDesc =>
      'Parler anonymement de questions LGBTQ+, gratuit';

  @override
  String get safePlaces => 'Lieux sûrs à proximité';

  @override
  String get policeStations => 'Police';

  @override
  String get hospitals => 'Hôpital';

  @override
  String get pharmacies => 'Pharmacie';

  @override
  String get busStations => 'Transports';

  @override
  String get mapsQueryPolice => 'commissariat de police';

  @override
  String get mapsQueryHospital => 'hôpital';

  @override
  String get mapsQueryPharmacy => 'pharmacie';

  @override
  String get mapsQueryTransport => 'gare';

  @override
  String get mapsOpenFailed =>
      'Un problème est survenu. Appelez un numéro d\'urgence.';

  @override
  String get resourcesTitle => 'Aide et informations';

  @override
  String get resVeiligThuisTitle => 'Veilig Thuis';

  @override
  String get resVeiligThuisDesc =>
      'Conseils et aide en cas de violences conjugales et de maltraitance d\'enfants, pour les victimes, les témoins et les professionnels. Appel ou chat, anonyme si vous le souhaitez.';

  @override
  String get resCsgTitle => 'Centrum Seksueel Geweld';

  @override
  String get resCsgDesc =>
      'Aide médicale, médico-légale et psychologique après des violences sexuelles. Prenez contact le plus tôt possible, idéalement dans les 7 jours. Gratuit, 24h/24.';

  @override
  String get resSlachtofferhulpTitle => 'Slachtofferhulp Nederland';

  @override
  String get resSlachtofferhulpDesc =>
      'Soutien pratique, juridique et émotionnel gratuit après un crime, un accident de la route ou une catastrophe.';

  @override
  String get res113Title => '113 Prévention du suicide';

  @override
  String get res113Desc =>
      'Vous pensez au suicide, ou vous vous inquiétez pour quelqu\'un ? Parlez anonymement à un écoutant formé.';

  @override
  String get resAangifteTitle => 'Porter plainte à la police';

  @override
  String get resAangifteDesc =>
      'Comment porter plainte en ligne, par téléphone ou au commissariat, et ce qui se passe ensuite.';

  @override
  String get res112Title => 'Quand appeler le 112 ?';

  @override
  String get res112Desc =>
      'Appelez le 112 uniquement en cas de danger de mort ou de crime en cours. Pour le reste, appelez la police au 0900-8844.';

  @override
  String get resSwitchboardTitle => 'Switchboard';

  @override
  String get resSwitchboardDesc =>
      'La ligne d\'écoute LGBTQ+ de COC Nederland. Parlez de manière anonyme et confidentielle de vos questions, de vos doutes ou de votre histoire, par téléphone ou par chat, gratuitement.';

  @override
  String callNumber(String number) {
    return 'Appeler le $number';
  }

  @override
  String get openWebsite => 'Ouvrir le site';

  @override
  String get getHomeSafe => 'Rentrer en sécurité';

  @override
  String get getHomeSafeSubtitle => 'Partagez votre position en chemin';

  @override
  String get getHomeSafeInterval =>
      'Votre position est envoyée à un contact toutes les 15 minutes';

  @override
  String get getHomeSafeActive => 'Actif';

  @override
  String get getHomeSafeOn => 'Rentrer en sécurité est activé';

  @override
  String get getHomeSafeOff => 'Rentrer en sécurité est désactivé';

  @override
  String get selectContactFirst => 'Choisissez d\'abord un contact';

  @override
  String get ghsRepeat => 'Répéter';

  @override
  String get ghsOnce => 'Une fois, à une heure précise';

  @override
  String ghsEvery(int minutes) {
    return 'Toutes les $minutes min';
  }

  @override
  String get ghsCustom => 'Autre';

  @override
  String get ghsCustomTitle => 'Toutes les combien de minutes ?';

  @override
  String get ghsPickTime => 'Choisir la date et l\'heure';

  @override
  String ghsAt(String time) {
    return 'Le $time';
  }

  @override
  String get ghsEveryMinuteWarning =>
      'Envoie un SMS chaque minute : 60 par heure, à votre tarif SMS habituel.';

  @override
  String get ghsTimeInPast => 'Choisissez une heure dans le futur';

  @override
  String get ghsStart => 'Démarrer';

  @override
  String get ghsStop => 'Arrêter';

  @override
  String get ghsChooseContact => 'Qui reçoit votre position ?';

  @override
  String get sosContacts => 'Contacts SOS';

  @override
  String get noContacts => 'Aucun contact pour l\'instant';

  @override
  String get addContactHint => 'Ajoutez au moins un contact';

  @override
  String get swipeToDelete =>
      'Glissez vers la gauche pour supprimer un contact';

  @override
  String get noName => 'Sans nom';

  @override
  String get contactSaved => 'Contact enregistré';

  @override
  String contactNotAdded(int max) {
    return 'Déjà enregistré, ou vous avez déjà $max contacts';
  }

  @override
  String contactRemoved(String name) {
    return '$name supprimé';
  }

  @override
  String contactCount(int count, int max) {
    return '$count sur $max';
  }

  @override
  String get enterPin => 'Saisissez votre code PIN';

  @override
  String get wrongPin => 'Code PIN incorrect, réessayez';

  @override
  String get gladYouAreSafe => 'Heureux que vous soyez en sécurité';

  @override
  String get notifyingSafe =>
      'Vos contacts sont prévenus que vous êtes en sécurité';

  @override
  String get alertSent => 'Alerte envoyée';

  @override
  String get noContactsFound => 'Aucun contact SOS trouvé';

  @override
  String get smsShake =>
      'À l\'aide ! J\'ai secoué mon téléphone pour envoyer cette alerte. Ma position :';

  @override
  String get smsSos => 'À l\'aide ! Ceci est un SOS de MetJou. Ma position :';

  @override
  String get smsSafe =>
      'Je suis en sécurité maintenant. Ignorez mon alerte SOS.';

  @override
  String get smsGetHomeSafe => 'Je rentre à la maison. Ma position :';

  @override
  String get smsNoLocation => '(position indisponible)';

  @override
  String get notifShakeTitle => 'Safe Shake est activé';

  @override
  String get notifShakeBody =>
      'Secouez votre téléphone pour alerter vos contacts';

  @override
  String get notifShakeSent => 'SOS envoyé à vos contacts';

  @override
  String get notifShakeNoContacts => 'Aucun contact trouvé. Appelez le 112.';

  @override
  String countdownTitle(int seconds) {
    return 'SOS envoyé dans $seconds';
  }

  @override
  String get countdownBody =>
      'Secousse détectée. Touchez Annuler si c\'était une erreur.';

  @override
  String get cancel => 'Annuler';

  @override
  String get countdownSetting => 'Compte à rebours avant une alerte';

  @override
  String get countdownSettingSubtitle =>
      'Temps pour annuler une alerte déclenchée en secouant';

  @override
  String get off => 'Désactivé';

  @override
  String seconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get alertCancelled => 'Alerte annulée';

  @override
  String get notifRecording => 'Enregistrement audio';

  @override
  String get notifRecordingReady => 'Prêt à enregistrer';

  @override
  String get notifRecordingStarted => 'Enregistrement démarré';

  @override
  String get notifRecordingStopped => 'Enregistrement arrêté';

  @override
  String notifRecordingSaved(String location) {
    return 'Enregistrement sauvegardé : $location';
  }

  @override
  String get notifRecordingFailed => 'Échec de l\'enregistrement';

  @override
  String get createPin => 'Créer un code PIN';

  @override
  String get changePin => 'Changer le code PIN';

  @override
  String get currentPin => 'Code PIN actuel';

  @override
  String get newPin => 'Nouveau code PIN';

  @override
  String get pinRequired =>
      'Un code PIN est nécessaire pour arrêter une alerte SOS';

  @override
  String get pinChanged => 'Code PIN modifié';

  @override
  String get currentPinWrong =>
      'Le code PIN actuel ne correspond pas. Réessayez.';

  @override
  String get enterCurrentPinFirst => 'Saisissez d\'abord votre code PIN actuel';

  @override
  String get alertsSection => 'Alertes';

  @override
  String get safeShake => 'Safe Shake';

  @override
  String get safeShakeSubtitle => 'Détecter une secousse en arrière-plan';

  @override
  String get safeShakeExplain =>
      'Safe Shake est la fonction principale de MetJou. Lorsqu\'elle est activée, l\'application détecte en arrière-plan si vous secouez votre téléphone. Si vous ne vous sentez pas en sécurité, secouez fermement votre téléphone pour envoyer un SOS à vos contacts sans ouvrir l\'application.';

  @override
  String get audioRecord => 'Enregistrement audio';

  @override
  String get audioRecordSubtitle =>
      'Enregistrer le son comme preuve quand vous secouez';

  @override
  String get audioRecordLength => 'Durée d\'enregistrement';

  @override
  String get audioRecordLengthSubtitle => 'Durée maximale d\'un enregistrement';

  @override
  String get audioRecordFolder => 'Dossier des enregistrements';

  @override
  String get audioRecordFolderPrivate =>
      'Stockage privé de l\'app (supprimé avec l\'app)';

  @override
  String get audioRecordFolderChoose => 'Choisir un dossier';

  @override
  String get audioRecordFolderReset => 'Utiliser le stockage privé de l\'app';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get appSection => 'Application';

  @override
  String get about => 'À propos';

  @override
  String get licenses => 'Licences';

  @override
  String get copyright => '© 2026 MetJou';

  @override
  String get tagline => 'Vous méritez d\'être en sécurité !';

  @override
  String get aboutDescription =>
      'MetJou vous garde en lien avec les personnes qui tiennent à vous. Partagez votre position en direct via des alertes SOS, joignez rapidement les secours et obtenez de l\'aide quand quelque chose arrive. Votre compagnon personnel.';

  @override
  String get aboutLegalese =>
      'MetJou vous aide à rester en contact avec les personnes qui veillent sur vous.';

  @override
  String get onbIntro => 'C\'est le premier pas vers un monde plus sûr.';

  @override
  String get onbBegin => 'Commençons';

  @override
  String get onbLocationText =>
      'MetJou utilise votre position pour les messages SOS et pour Rentrer en sécurité, même quand l\'application est fermée.';

  @override
  String get onbLocationButton => 'Autoriser la position';

  @override
  String get onbMicText =>
      'Quand vous secouez votre téléphone, MetJou peut enregistrer le son comme preuve. Autorisez le microphone et les notifications pour l\'utiliser.';

  @override
  String get onbMicButton => 'Autoriser le microphone';

  @override
  String get onbSmsText =>
      'MetJou a besoin des SMS et du téléphone pour alerter vos contacts et appeler les numéros d\'urgence.';

  @override
  String get onbSmsButton => 'Autoriser SMS et téléphone';

  @override
  String get onbWelcome => 'Bienvenue';

  @override
  String get onbGetStarted => 'Commencer';

  @override
  String get onbNext => 'Suivant';

  @override
  String get onbSkip => 'Passer';

  @override
  String get termsPrefix => 'En continuant, vous acceptez nos';

  @override
  String get termsLink => 'Conditions générales';

  @override
  String get termsAnd => 'et';

  @override
  String get privacyLink => 'Politique de confidentialité';
}
