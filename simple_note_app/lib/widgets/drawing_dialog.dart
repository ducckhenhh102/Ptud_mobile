import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class DrawingDialog extends StatefulWidget {
  const DrawingDialog({super.key});

  @override
  State<DrawingDialog> createState() => _DrawingDialogState();
}

class _DrawingDialogState extends State<DrawingDialog> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 4,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Viết tay / Vẽ'),
        actions: [
          TextButton(
            onPressed: () => _controller.clear(),
            child: const Text('Xóa hết', style: TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, size: 30, color: Colors.teal),
            onPressed: () async {
              if (_controller.isEmpty) {
                Navigator.pop(context);
              } else {
                final Uint8List? data = await _controller.toPngBytes();
                if (mounted) Navigator.pop(context, data);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Signature(
            controller: _controller,
            backgroundColor: Colors.white,
            height: double.infinity,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
