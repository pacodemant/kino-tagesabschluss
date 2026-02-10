import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:kino_bar_app/models/cash_count_draft.dart';

class LocalStore {
  static const String activeCinemaIdKey = 'activeCinemaId';

  static Future<String?> loadActiveCinemaId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(activeCinemaIdKey);
  }

  static Future<void> saveActiveCinemaId(String cinemaId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(activeCinemaIdKey, cinemaId);
  }

  static Future<int> loadChangeTargetCents(String cinemaId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('change_target_cents_$cinemaId') ?? 20000;
  }

  static Future<CashCountDraft?> loadCashCountDraft({
    required String cinemaId,
    required String isoDate,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = draftKey(cinemaId: cinemaId, isoDate: isoDate);
    final String? raw = prefs.getString(key);
    if (raw == null) {
      return null;
    }

    try {
      final Map<String, dynamic> parsed = jsonDecode(raw) as Map<String, dynamic>;
      return CashCountDraft.fromJson(parsed);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCashCountDraft({
    required String cinemaId,
    required String isoDate,
    required CashCountDraft draft,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = draftKey(cinemaId: cinemaId, isoDate: isoDate);
    await prefs.setString(key, jsonEncode(draft.toJson()));
  }

  static String draftKey({required String cinemaId, required String isoDate}) {
    return 'draft_closure_${cinemaId}_$isoDate';
  }
}
