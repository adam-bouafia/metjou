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
  String get appearance => 'Apariencia';

  @override
  String get themeSystem => 'Como el teléfono';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

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
  String get switchboardTitle => 'Switchboard (LGBTQ+)';

  @override
  String get switchboardDesc =>
      'Habla de forma anónima sobre temas LGBTQ+, gratis';

  @override
  String get safePlaces => 'Lugares seguros cercanos';

  @override
  String get policeStations => 'Policía';

  @override
  String get hospitals => 'Hospital';

  @override
  String get pharmacies => 'Farmacia';

  @override
  String get busStations => 'Transporte';

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
  String get resSwitchboardTitle => 'Switchboard';

  @override
  String get resSwitchboardDesc =>
      'La línea de ayuda LGBTQ+ de COC Nederland. Habla de forma anónima y confidencial sobre tus preguntas, dudas o tu historia, por teléfono o chat, gratis.';

  @override
  String callNumber(String number) {
    return 'Llamar al $number';
  }

  @override
  String get openWebsite => 'Abrir sitio web';

  @override
  String get quickExit => 'Salida rápida';

  @override
  String get quickExitHint => 'Abre el tiempo y cierra MetJou';

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
  String get ghsRepeat => 'Repetir';

  @override
  String get ghsOnce => 'Una vez, a una hora concreta';

  @override
  String ghsEvery(int minutes) {
    return 'Cada $minutes min';
  }

  @override
  String get ghsCustom => 'Otro';

  @override
  String get ghsCustomTitle => '¿Cada cuántos minutos?';

  @override
  String get ghsPickTime => 'Elegir fecha y hora';

  @override
  String ghsAt(String time) {
    return 'El $time';
  }

  @override
  String get ghsEveryMinuteWarning =>
      'Envía un SMS cada minuto: 60 por hora, con tu tarifa normal de SMS.';

  @override
  String get ghsTimeInPast => 'Elige una hora en el futuro';

  @override
  String get ghsStart => 'Iniciar';

  @override
  String get ghsStop => 'Detener';

  @override
  String get ghsChooseContact => '¿Quién recibe tu ubicación?';

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
  String countdownTitle(int seconds) {
    return 'Enviando SOS en $seconds';
  }

  @override
  String get countdownBody =>
      'Sacudida detectada. Toca Cancelar si fue un error.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get countdownSetting => 'Cuenta atrás antes de una alerta';

  @override
  String get countdownSettingSubtitle =>
      'Tiempo para cancelar una alerta enviada al agitar';

  @override
  String get off => 'Desactivado';

  @override
  String seconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get alertCancelled => 'Alerta cancelada';

  @override
  String get notifRecording => 'Grabación de audio';

  @override
  String get notifRecordingReady => 'Listo para grabar';

  @override
  String get notifRecordingStarted => 'Grabación iniciada';

  @override
  String get notifRecordingStopped => 'Grabación detenida';

  @override
  String notifRecordingSaved(String location) {
    return 'Grabación guardada: $location';
  }

  @override
  String get notifRecordingFailed => 'La grabación falló';

  @override
  String get createPin => 'Crear PIN';

  @override
  String get changePin => 'Cambiar PIN';

  @override
  String get currentPin => 'PIN actual';

  @override
  String get newPin => 'Nuevo PIN';

  @override
  String get pinRequired =>
      'El PIN detiene una alerta SOS y protege los ajustes y tus contactos';

  @override
  String get discreetMode => 'Modo discreto';

  @override
  String get discreetModeSubtitle =>
      'Muestra MetJou como \'Calculadora\' y desactiva las notificaciones de estado';

  @override
  String get discreetConfirmTitle => '¿Activar el modo discreto?';

  @override
  String get discreetConfirmBody =>
      'El icono y el nombre de MetJou pasan a ser una calculadora en tu pantalla de inicio, las notificaciones de estado se desactivan, y la pantalla de apps recientes no muestra vista previa. La pantalla de inicio puede tardar un momento en actualizarse. Android sigue mostrando el nombre MetJou en la cabecera de las notificaciones y en Ajustes > Aplicaciones.';

  @override
  String get discreetNotification => 'Servicio activo';

  @override
  String get turnOn => 'Activar';

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
  String get audioRecordFolder => 'Carpeta de grabaciones';

  @override
  String get audioRecordFolderPrivate =>
      'Almacenamiento privado de la app (se borra con la app)';

  @override
  String get audioRecordFolderChoose => 'Elegir una carpeta';

  @override
  String get audioRecordFolderReset =>
      'Usar el almacenamiento privado de la app';

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
