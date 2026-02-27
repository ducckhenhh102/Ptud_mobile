import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class StorageService {
  static const String _notesKey = 'smart_notes_data';

  // 1. Đọc dữ liệu từ thiết bị (Get)
  static Future<List<NoteModel>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString(_notesKey);
    
    // Nếu chưa có dữ liệu -> Trả về mảng rỗng []
    if (notesJson == null) return [];
    
    try {
      // Dùng jsonDecode() ép kiểu về List<dynamic>
      final List<dynamic> decodedList = jsonDecode(notesJson);
      // Dùng .map() qua NoteModel.fromJson để trả về List<NoteModel>
      return decodedList.map((item) => NoteModel.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // 2. Ghi dữ liệu vĩnh viễn (Save)
  static Future<void> saveNotes(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    // Dùng .map() chuyển thành List Map, sau đó dùng jsonEncode() thành chuỗi String JSON
    final String encodedList = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_notesKey, encodedList);
  }
}
