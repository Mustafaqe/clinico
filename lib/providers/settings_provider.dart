import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class SettingsProvider extends ChangeNotifier {
  String _clinicName = 'Medical Clinic';
  String _doctorName = 'Doctor';

  String get clinicName => _clinicName;
  String get doctorName => _doctorName;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/clinico_settings.json');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(contents);

        _clinicName = data['clinicName'] ?? 'Medical Clinic';
        _doctorName = data['doctorName'] ?? 'Doctor';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> updateSettings({
    required String clinicName,
    required String doctorName,
  }) async {
    _clinicName = clinicName;
    _doctorName = doctorName;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/clinico_settings.json');

      final data = {
        'clinicName': clinicName,
        'doctorName': doctorName,
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
}
