import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- AUTH LOGIC ---
  
  // Stream theo dõi trạng thái đăng nhập
  Stream<User?> get userStream => _auth.authStateChanges();

  // Đăng nhập/Đăng ký nhanh (Anonymous hoặc Email/Password tùy chọn)
  // Ở đây tôi dùng Email/Password để chuyên nghiệp
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Nếu không có user thì tự động đăng ký luôn cho tiện
        return await _auth.createUserWithEmailAndPassword(email: email, password: password);
      }
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  // --- FIRESTORE LOGIC ---

  CollectionReference get _noteRef {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");
    // Mỗi user có một thư mục ghi chú riêng
    return _db.collection('users').doc(user.uid).collection('notes');
  }

  // Lấy danh sách ghi chú (Real-time)
  Stream<List<NoteModel>> getNotesStream() {
    return _noteRef.orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Dùng ID của Firestore
        return NoteModel.fromJson(data);
      }).toList();
    });
  }

  // Lưu hoặc cập nhật ghi chú
  Future<void> saveNote(NoteModel note) async {
    final data = note.toJson();
    if (note.id.isEmpty || note.id.length < 10) {
      // Ghi chú mới (Firestore tự sinh ID)
      await _noteRef.add(data);
    } else {
      // Cập nhật ghi chú cũ
      await _noteRef.doc(note.id).set(data);
    }
  }

  // Xóa ghi chú
  Future<void> deleteNote(String id) async {
    await _noteRef.doc(id).delete();
  }
}
