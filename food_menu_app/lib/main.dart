import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseService().seedFoodData();
  runApp(const FoodMenuApp());
}

class FoodMenuApp extends StatelessWidget {
  const FoodMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Menu App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(), // Áp dụng font chữ cho toàn app
      ),
      home: const MainEntryGate(),
    );
  }
}

class MainEntryGate extends StatefulWidget {
  const MainEntryGate({super.key});

  @override
  State<MainEntryGate> createState() => _MainEntryGateState();
}

class _MainEntryGateState extends State<MainEntryGate> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isChecking = false;

  void _showAdminLogin(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Center(child: Text('Admin Login', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              if (_isChecking) const Padding(padding: EdgeInsets.only(top: 16.0), child: LinearProgressIndicator(color: Colors.orange)),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _isChecking ? null : () async {
                setDialogState(() => _isChecking = true);
                bool success = await _firebaseService.signInAdmin(emailController.text.trim(), passwordController.text.trim());
                setDialogState(() => _isChecking = false);

                if (success && mounted) {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AdminScreen()));
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tài khoản hoặc mật khẩu không đúng!'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Lớp nền: Ảnh món ăn mờ ảo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Lớp phủ tối để chữ nổi bật
          Container(color: Colors.black.withOpacity(0.55)),
          
          // Nội dung chính
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    'Chào mừng đến với',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 22, color: Colors.white70),
                  ),
                  Text(
                    'TLU Food Center',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const HomeScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.4),
                    ),
                    child: Text('KHÁM PHÁ THỰC ĐƠN', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () => _showAdminLogin(context),
                    child: Center(
                      child: Text(
                        'Bạn là Quản lý nhà hàng?',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.6),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
