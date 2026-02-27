import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/note.dart';
import '../widgets/drawing_dialog.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _imagePath = widget.note?.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Hàm lưu file vào bộ nhớ ứng dụng
  Future<String> _saveFileToHardware(Uint8List bytes, String extension) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'note_asset_${DateTime.now().millisecondsSinceEpoch}$extension';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      debugPrint('Lỗi khi lưu file: $e');
      rethrow;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080, // Giới hạn kích thước để app chạy mượt hơn
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final savedPath = await _saveFileToHardware(bytes, path.extension(image.path));
        setState(() => _imagePath = savedPath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  Future<void> _drawHandwritten() async {
    try {
      final Uint8List? data = await Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => const DrawingDialog()),
      );

      if (data != null) {
        final savedPath = await _saveFileToHardware(data, '.png');
        setState(() => _imagePath = savedPath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu hình vẽ: $e')),
      );
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề ghi chú')),
      );
      return;
    }

    Navigator.pop(context, {
      'title': title,
      'content': content,
      'imagePath': _imagePath,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Ghi chú mới' : 'Chỉnh sửa'),
        actions: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            tooltip: 'Thêm ảnh',
          ),
          IconButton(
            onPressed: _drawHandwritten,
            icon: const Icon(Icons.gesture_rounded),
            tooltip: 'Viết tay',
          ),
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_imagePath != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_imagePath!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _imagePath = null),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _titleController,
              autofocus: widget.note == null,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Tiêu đề',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: null,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Bắt đầu nhập nội dung...',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
