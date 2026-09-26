// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get save => 'Guardar';

  @override
  String get done => 'Listo';

  @override
  String get close => 'Cerrar';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get changeLanguage => 'Cambiar el idioma de la aplicación';

  @override
  String get chooseLanguage => 'Elige tu idioma';

  @override
  String get stop => 'STOP';

  @override
  String get seeMore => 'Ver más';

  @override
  String get slogan1 => 'No estás solo';

  @override
  String get slogan2 => 'Seguros juntos';

  @override
  String get slogan3 => 'Contigo, siempre';

  @override
  String get emergency => 'Emergencias';

  @override
  String get emergency112Title => 'Número de emergencia';

  @override
  String get emergency112Desc =>
      'Peligro de muerte: policía, ambulancia o bomberos';

  @override
  String get policeNonUrgentTitle => 'Policía, no urgente';

  @override
  String get policeNonUrgentDesc =>
      'Informar o preguntar algo cuando no hay peligro ahora';

  @override
  String get veiligThuisTitle => 'Veilig Thuis';

  @override
  String get veiligThuisDesc =>
      'Violencia doméstica o maltrato infantil, gratis y 24/7';

  @override
  String get suicidePreventionTitle => '113 Prevención del suicidio';

  @override
  String get suicidePreventionDesc => 'Habla con alguien, gratis y 24/7';

  @override
  String get safePlaces => 'Lugares seguros cercanos';

  @override
  String get policeStations => 'Policía';

  @override
  String get hospitals => 'Hospitales';

  @override
  String get pharmacies => 'Farmacias';

  @override
  String get busStations => 'Transporte público';

  @override
  String get mapsQueryPolice => 'comisaría de policía';

  @override
  String get mapsQueryHospital => 'hospital';

  @override
  String get mapsQueryPharmacy => 'farmacia';

  @override
  String get mapsQueryTransport => 'estación de tren';

  @override
  String get mapsOpenFailed =>
      'Algo salió mal. Llama a un número de emergencia.';

  @override
  String get resourcesTitle => 'Ayuda e información';

  @override
  String get resVeiligThuisTitle => 'Veilig Thuis';

  @override
  String get resVeiligThuisDesc =>
      'Consejo y ayuda ante violencia doméstica y maltrato infantil, para víctimas, testigos y profesionales. Llama o chatea, de forma anónima si quieres.';

  @override
  String get resCsgTitle => 'Centrum Seksueel Geweld';

  @override
  String get resCsgDesc =>
      'Ayuda médica, forense y psicológica tras violencia sexual. Contacta lo antes posible, idealmente en los primeros 7 días. Gratis, 24/7.';

  @override
  String get resSlachtofferhulpTitle => 'Slachtofferhulp Nederland';

  @override
  String get resSlachtofferhulpDesc =>
      'Apoyo práctico, legal y emocional gratuito tras un delito, un accidente de tráfico o una catástrofe.';

  @override
  String get res113Title => '113 Prevención del suicidio';

  @override
  String get res113Desc =>
      '¿Piensas en el suicidio o te preocupa alguien? Habla de forma anónima con un profesional formado.';

  @override
  String get resAangifteTitle => 'Denunciar a la policía';

  @override
  String get resAangifteDesc =>
      'Cómo presentar una denuncia en línea, por teléfono o en una comisaría, y qué ocurre después.';

  @override
  String get res112Title => '¿Cuándo llamar al 112?';

  @override
  String get res112Desc =>
      'Llama al 112 solo si hay peligro de muerte o un delito está ocurriendo ahora. Para todo lo demás, llama a la policía al 0900-8844.';

  @override
  String callNumber(String number) {
    return 'Llamar al $number';
  }

  @override
  String get openWebsite => 'Abrir sitio web';

  @override
  String get getHomeSafe => 'Llegar seguro a casa';

  @override
  String get getHomeSafeSubtitle => 'Comparte tu ubicación en el camino';

  @override
  String get getHomeSafeInterval =>
      'Tu ubicación se envía a un contacto cada 15 minutos';

  @override
  String get getHomeSafeActive => 'Activo ahora';

  @override
  String get getHomeSafeOn => 'Llegar seguro a casa está activado';

  @override
  String get getHomeSafeOff => 'Llegar seguro a casa está desactivado';

  @override
  String get selectContactFirst => 'Elige primero un contacto';

  @override
  String get sosContacts => 'Contactos SOS';

  @override
  String get noContacts => 'Aún no hay contactos';

  @override
  String get addContactHint => 'Añade al menos un contacto';

  @override
  String get swipeToDelete =>
      'Desliza a la izquierda para eliminar un contacto';

  @override
  String get noName => 'Sin nombre';

  @override
  String get contactSaved => 'Contacto guardado';

  @override
  String contactNotAdded(int max) {
    return 'Ya guardado, o ya tienes $max contactos';
  }

  @override
  String contactRemoved(String name) {
    return '$name eliminado';
  }

  @override
  String contactCount(int count, int max) {
    return '$count de $max';
  }

  @override
  String get enterPin => 'Introduce tu PIN';

  @override
  String get wrongPin => 'PIN incorrecto, inténtalo de nuevo';

  @override
  String get gladYouAreSafe => 'Nos alegra que estés a salvo';

  @override
  String get notifyingSafe => 'Avisando a tus contactos de que estás a salvo';

  @override
  String get alertSent => 'Alerta enviada';

  @override
  String get noContactsFound => 'No se encontraron contactos SOS';

  @override
  String get smsShake =>
      '¡Ayuda! He agitado mi teléfono para enviar esta alerta. Mi ubicación:';

  @override
  String get smsSos => '¡Ayuda! Esto es un SOS de MetJou. Mi ubicación:';

  @override
  String get smsSafe => 'Ahora estoy a salvo. Ignora mi alerta SOS.';

  @override
  String get smsGetHomeSafe => 'Voy de camino a casa. Mi ubicación:';

  @override
  String get smsNoLocation => '(ubicación no disponible)';

  @override
  String get notifShakeTitle => 'Safe Shake está activado';

  @override
  String get notifShakeBody => 'Agita tu teléfono para avisar a tus contactos';

  @override
  String get notifShakeSent => 'SOS enviado a tus contactos';

  @override
  String get notifShakeNoContacts =>
      'No se encontraron contactos. Llama al 112.';

  @override
  String get notifRecording => 'Grabación de audio';

  @override
  String get notifRecordingReady => 'Listo para grabar';

  @override
  String get notifRecordingStarted => 'Grabación iniciada';

  @override
  String get notifRecordingStopped => 'Grabación detenida';

  @override
  String get createPin => 'Crear PIN';

  @override
  String get changePin => 'Cambiar PIN';

  @override
  String get currentPin => 'PIN actual';

  @override
  String get newPin => 'Nuevo PIN';

  @override
  String get pinRequired => 'Se necesita un PIN para detener una alerta SOS';

  @override
  String get pinChanged => 'PIN cambiado';

  @override
  String get currentPinWrong =>
      'El PIN actual no coincide. Inténtalo de nuevo.';

  @override
  String get enterCurrentPinFirst => 'Introduce primero tu PIN actual';

  @override
  String get alertsSection => 'Alertas';

  @override
  String get safeShake => 'Safe Shake';

  @override
  String get safeShakeSubtitle => 'Detectar una sacudida en segundo plano';

  @override
  String get safeShakeExplain =>
      'Safe Shake es la función principal de MetJou. Cuando está activada, la aplicación detecta en segundo plano si agitas el teléfono. Si te sientes inseguro, agita el teléfono con fuerza para enviar un SOS a tus contactos sin abrir la aplicación.';

  @override
  String get audioRecord => 'Grabación de audio';

  @override
  String get audioRecordSubtitle => 'Grabar audio como prueba al agitar';

  @override
  String get audioRecordLength => 'Duración de la grabación';

  @override
  String get audioRecordLengthSubtitle => 'Duración máxima de una grabación';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get appSection => 'Aplicación';

  @override
  String get about => 'Acerca de';

  @override
  String get licenses => 'Licencias';

  @override
  String get copyright => '© 2026 MetJou';

  @override
  String get tagline => '¡Mereces estar a salvo!';

  @override
  String get aboutDescription =>
      'MetJou te mantiene en contacto con las personas que se preocupan por ti. Comparte tu ubicación en directo mediante alertas SOS, contacta rápido con los servicios de emergencia y recibe ayuda cuando algo ocurre. Tu compañero personal.';

  @override
  String get aboutLegalese =>
      'MetJou te ayuda a mantenerte en contacto con las personas que cuidan de ti.';

  @override
  String get onbIntro => 'Este es el primer paso hacia un mundo más seguro.';

  @override
  String get onbBegin => 'Empecemos';

  @override
  String get onbLocationText =>
      'MetJou usa tu ubicación para los mensajes SOS y para Llegar seguro a casa, también cuando la aplicación está cerrada.';

  @override
  String get onbLocationButton => 'Permitir ubicación';

  @override
  String get onbMicText =>
      'Cuando agitas el teléfono, MetJou puede grabar audio como prueba. Permite el micrófono y las notificaciones para usarlo.';

  @override
  String get onbMicButton => 'Permitir micrófono';

  @override
  String get onbSmsText =>
      'MetJou necesita acceso a SMS y teléfono para avisar a tus contactos y llamar a los números de emergencia.';

  @override
  String get onbSmsButton => 'Permitir SMS y teléfono';

  @override
  String get onbWelcome => 'Bienvenido';

  @override
  String get onbGetStarted => 'Empezar';

  @override
  String get onbNext => 'Siguiente';

  @override
  String get onbSkip => 'Omitir';

  @override
  String get termsPrefix => 'Al continuar aceptas nuestros';

  @override
  String get termsLink => 'Términos y condiciones';

  @override
  String get termsAnd => 'y';

  @override
  String get privacyLink => 'Política de privacidad';
}
