import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // THÊM ĐỘ TRỄ 1.5S KHI TẢI DỮ LIỆU
  Stream<List<Food>> getFoodMenuStream() async* {
    // Ép app phải chờ 1.5 giây để hiện Loading rõ ràng
    await Future.delayed(const Duration(milliseconds: 1500));
    
    yield* _db.collection('foods').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Food.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- ĐĂNG NHẬP ADMIN BẰNG FIREBASE AUTH ---
  Future<bool> signInAdmin(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Đăng xuất
  Future<void> signOut() => _auth.signOut();

  // --- CÁC HÀM QUẢN LÝ MÓN ĂN ---
  Future<void> addFood(String name, String desc, double price, String imageUrl, String category) async {
    await _db.collection('foods').add({
      "name": name,
      "description": desc,
      "price": price,
      "imageUrl": imageUrl,
      "category": category,
    });
  }

  Future<void> updateFood(String id, String name, String desc, double price, String imageUrl, String category) async {
    await _db.collection('foods').doc(id).update({
      "name": name,
      "description": desc,
      "price": price,
      "imageUrl": imageUrl,
      "category": category,
    });
  }

  Future<void> deleteFood(String id) async {
    await _db.collection('foods').doc(id).delete();
  }

  Future<void> seedFoodData() async {
    final snapshot = await _db.collection('foods').limit(1).get();
    if (snapshot.docs.isEmpty) {
      await addFood("Phở Bò", "Phở tái chín", 45000, "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43", "Phở");
    }
  }
}
