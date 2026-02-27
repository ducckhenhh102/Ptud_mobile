import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/storage_service.dart';

class DetailScreen extends StatefulWidget {
  final NoteModel? note;

  const DetailScreen({super.key, this.note});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // LOGIC AUTO-SAVE: Đảm bảo lưu xong mới thoát
  Future<void> _saveAndExit() async {
    if (_isSaving) return;
    
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Nếu cả hai đều rỗng thì không cần lưu, thoát luôn
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final allNotes = await StorageService.getNotes();

      if (widget.note == null) {
        // Thêm mới vào đầu danh sách
        allNotes.insert(0, NoteModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          content: content,
          updatedAt: DateTime.now(),
        ));
      } else {
        // Cập nhật ghi chú cũ
        final index = allNotes.indexWhere((n) => n.id == widget.note!.id);
        if (index != -1) {
          allNotes[index].title = title;
          allNotes[index].content = content;
          allNotes[index].updatedAt = DateTime.now();
        }
      }

      // Đợi ghi xong vào ổ cứng
      await StorageService.saveNotes(allNotes);
    } catch (e) {
      debugPrint('Lỗi lưu ghi chú: $e');
    }

    // Sau khi lưu xong mới thực hiện thoát màn hình
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Chặn thoát mặc định để đợi lưu
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _saveAndExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Soạn thảo'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async => await _saveAndExit(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_isSaving)
                const LinearProgressIndicator(), // Hiện thanh chạy khi đang lưu
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration.collapsed(hintText: 'Tiêu đề'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration.collapsed(hintText: 'Bắt đầu ghi chú...'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
