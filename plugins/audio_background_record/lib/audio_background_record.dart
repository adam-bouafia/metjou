import 'audio_background_record_platform_interface.dart';

class AudioBackgroundRecord {
  static AudioBackgroundRecord? _instance;

  static AudioBackgroundRecord getInstance() =>
      _instance ??= AudioBackgroundRecord._();

  AudioBackgroundRecord._();

  Future<void> startRecordingService() {
    return AudioBackgroundRecordPlatform.instance.startService();
  }

  Future<void> stopRecordingService() {
    return AudioBackgroundRecordPlatform.instance.stopService();
  }

  Future<void> configure({
    String? savetoDirectory,
    int? maxDurationInMillis,
    Map<String, String>? text,
  }) {
    return AudioBackgroundRecordPlatform.instance.setConfiguration(
      savetoDirectory,
      maxDurationInMillis,
      text,
    );
  }

  Future<bool?> isRecordingServiceRunning() {
    return AudioBackgroundRecordPlatform.instance.isServiceRunning();
  }

  /// Name of the picked folder, or null when recordings go to the app's
  /// private folder.
  Future<String?> getRecordingDestination() {
    return AudioBackgroundRecordPlatform.instance.getRecordingDirFromConfig();
  }

  Future<int?> getMaxRecordDuration() {
    return AudioBackgroundRecordPlatform.instance
        .getMaxRecordDurationFromConfig();
  }

  Future<bool?> startRecording() {
    return AudioBackgroundRecordPlatform.instance.startRecording();
  }

  Future<bool?> stopRecording() {
    return AudioBackgroundRecordPlatform.instance.stopRecording();
  }

  Future<bool?> isRecording() {
    return AudioBackgroundRecordPlatform.instance.isRecording();
  }

  void setOnRecordStatusChangedCallback(
    void Function(int status, String? message)? cb,
  ) {
    AudioBackgroundRecordPlatform.instance.onRecordStatusChangedCallback = cb;
  }

  /// Lets the user pick the folder for recordings (Android's folder picker).
  /// Returns the folder name, or null when cancelled.
  Future<String?> pickDirectory() =>
      AudioBackgroundRecordPlatform.instance.pickDirectory();

  /// Stores recordings in the app's private folder again.
  Future<void> resetDirectory() =>
      AudioBackgroundRecordPlatform.instance.resetDirectory();

}
