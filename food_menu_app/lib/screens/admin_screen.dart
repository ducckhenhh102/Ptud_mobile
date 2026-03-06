import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_model.dart';
import '../services/firebase_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // Danh sách danh mục chuẩn
  final List<String> _categories = ['Cơm', 'Phở', 'Nước uống', 'Khác'];

  void _showFoodDialog({Food? food}) {
    final nameController = TextEditingController(text: food?.name ?? '');
    final descController = TextEditingController(text: food?.description ?? '');
    final priceController = TextEditingController(text: food?.price.toString() ?? '');
    final imageController = TextEditingController(text: food?.imageUrl ?? '');
    
    // Kiểm tra nếu category của food không nằm trong danh sách chuẩn thì mặc định là 'Khác'
    String selectedCat = (food != null && _categories.contains(food.category))
        ? food.category
        : 'Khác';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(food == null ? 'Thêm món mới' : 'Sửa món ăn'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
                TextField(
                  controller: priceController, 
                  decoration: const InputDecoration(labelText: 'Giá tiền'), 
                  keyboardType: TextInputType.number
                ),
                TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Link ảnh')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: const InputDecoration(labelText: 'Phân loại'),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      selectedCat = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final desc = descController.text;
                final price = double.tryParse(priceController.text) ?? 0;
                final img = imageController.text;

                if (food == null) {
                  await _firebaseService.addFood(name, desc, price, img, selectedCat);
                } else {
                  await _firebaseService.updateFood(food.id, name, desc, price, img, selectedCat);
                }
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thực đơn (Admin)'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<List<Food>>(
        stream: _firebaseService.getFoodMenuStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có món ăn nào.'));
          }

          final foods = snapshot.data!;
          return ListView.builder(
            itemCount: foods.length,
            itemBuilder: (ctx, i) {
              final food = foods[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food.imageUrl,
                      width: 50, height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => const Icon(Icons.fastfood)
                    ),
                  ),
                  title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(food.price)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                        child: Text(food.category, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showFoodDialog(food: food)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _firebaseService.deleteFood(food.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFoodDialog(),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
