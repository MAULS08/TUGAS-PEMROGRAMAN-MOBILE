import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin.dart';

class AdminService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _storageKey = 'admins_json';
  static const int adminIdFromNim = 987; // 792 + 071

  // GET: mengambil seluruh Admin. Data disimpan lokal agar DELETE tetap terlihat
  // setelah aplikasi dibuka kembali (JSONPlaceholder sendiri tidak menyimpan perubahan).
  static Future<List<Admin>> getAdmins() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_storageKey);

    if (cached != null && cached.isNotEmpty) {
      try {
        final decoded = jsonDecode(cached) as List<dynamic>;
        return decoded
            .map((item) => Admin.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (_) {
        await prefs.remove(_storageKey);
      }
    }

    List<dynamic> source;
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      source = jsonDecode(response.body) as List<dynamic>;
    } catch (_) {
      source = _fallbackAdmins;
    }

    final admins = source.asMap().entries.map((entry) {
      final json = Map<String, dynamic>.from(entry.value);
      json['department'] ??= 'Department ${entry.key + 1}';
      return Admin.fromJson(json);
    }).toList();

    // Admin dengan ID dari NIM agar fitur detail dan DELETE dapat diuji.
    if (!admins.any((admin) => admin.id == adminIdFromNim)) {
      admins.add(
        const Admin(
          id: adminIdFromNim,
          name: 'Rafi Maulana Saputra',
          email: 'rafi.admin@example.com',
          department: 'Information Technology',
        ),
      );
    }

    await _save(admins, prefs);
    return admins;
  }

  // GET: mengambil satu Admin berdasarkan ID.
  static Future<Admin> getAdmin(int id) async {
    final admins = await getAdmins();
    try {
      return admins.firstWhere((admin) => admin.id == id);
    } catch (_) {
      throw Exception('Admin dengan ID $id tidak ditemukan');
    }
  }

  // DELETE: menghapus Admin berdasarkan ID.
  static Future<bool> deleteAdmin(int id) async {
    final admins = await getAdmins();
    final oldLength = admins.length;
    admins.removeWhere((admin) => admin.id == id);

    if (admins.length == oldLength) return false;

    final prefs = await SharedPreferences.getInstance();
    await _save(admins, prefs);
    return true;
  }

  static Future<void> _save(List<Admin> admins, SharedPreferences prefs) async {
    await prefs.setString(
      _storageKey,
      jsonEncode(admins.map((admin) => admin.toJson()).toList()),
    );
  }

  static const List<Map<String, dynamic>> _fallbackAdmins = [
    {
      'id': 1,
      'name': 'mlehoy',
      'email': 'mlehoy@gmail.com',
      'department': 'Human Resources',
    },
    {
      'id': 2,
      'name': 'cihuy',
      'email': 'cihuy@gmail.com',
      'department': 'Finance',
    },
    {
      'id': 3,
      'name': 'paul',
      'email': 'paul@gmail.com',
      'department': 'Information Technology',
    },
  ];
}
