import 'package:flutter/material.dart';
import 'scan_option_screen.dart';
import '../services/auth_service.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../widgets/vt_primary_button_widget.dart';
import '../widgets/vt_text_field_widget.dart';
import '../widgets/password_criteria_widget.dart';
import '../widgets/vt_snackbar_helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. เพิ่ม Controllers ให้ครบทุกช่อง
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false; // <--- ตัวแปรสำหรับคุมปุ่มและวงแหวน Loading

  // ตัวแปรสำหรับเช็คความปลอดภัยของรหัสผ่าน
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasSpecialChars = false;

  @override
  void dispose() {
    // อย่าลืมเคลียร์หน่วยความจำตอนปิดหน้าจอ
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ฟังก์ชันเช็คเงื่อนไขรหัสผ่าน (ทำงานทุกครั้งที่พิมพ์)
  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // 2. ฟังก์ชันหลักสำหรับกดสมัครสมาชิก
  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // เช็คว่ากรอกข้อมูลครบทุกช่องไหม
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showVTSnackBar(context, "Please fill all fields", Colors.redAccent);
      return;
    }

    // เช็คว่ารหัสผ่านผ่านเกณฑ์ความปลอดภัยไหม
    bool isPasswordValid =
        _hasMinLength && _hasUppercase && _hasDigits && _hasSpecialChars;
    if (!isPasswordValid) {
      showVTSnackBar(
        context,
        "Please meet all password requirements",
        Colors.redAccent,
      );
      return;
    }

    // เช็คว่ารหัสผ่าน 2 ช่องตรงกันไหม
    if (password != confirmPassword) {
      showVTSnackBar(context, "Passwords do not match", Colors.redAccent);
      return;
    }

    // ทุกอย่างผ่าน! เริ่มกระบวนการสมัคร
    setState(() => _isLoading = true);

    final authService = AuthService();
    final resultOrFailure = await authService.signUpWithEmail(
      name,
      email,
      password,
    );

    if (mounted) {
      setState(() => _isLoading = false); // ปิดตัวโหลด

      resultOrFailure.fold(
        (failure) {
          showVTSnackBar(context, failure.message, Colors.redAccent);
        },
        (user) {
          // สำเร็จ! พาไปหน้าสแกนไวรัส และลบประวัติการย้อนกลับ
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ScanOptionScreen()),
            (route) => false,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: ''),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("CREATE ACCOUNT", style: textTitle.copyWith(letterSpacing: 2)),
            const SizedBox(height: 8),
            Text("Register to secure your device.", style: textDescription),
            const SizedBox(height: 40),

            // --- ฟอร์มกรอกข้อมูล (ผูก Controller ให้ครบ) ---
            VTTextField(
              hint: "Full Name",
              icon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            VTTextField(
              hint: "Email Address",
              icon: Icons.email_outlined,
              controller: _emailController,
            ),
            const SizedBox(height: 16),

            VTTextField(
              hint: "Password",
              icon: Icons.lock_outline,
              isPassword: true,
              controller: _passwordController,
              onChanged: _validatePassword,
              obscureText: _obscurePassword,
              onObscureToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),

            // --- Checklist ตรวจรหัสผ่าน ---
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              PasswordCriteriaWidget(
                text: "At least 8 characters",
                isMet: _hasMinLength,
              ),
              PasswordCriteriaWidget(
                text: "Contains uppercase (A-Z)",
                isMet: _hasUppercase,
              ),
              PasswordCriteriaWidget(
                text: "Contains number (0-9)",
                isMet: _hasDigits,
              ),
              PasswordCriteriaWidget(
                text: "Contains special char (!@#\$)",
                isMet: _hasSpecialChars,
              ),
            ],

            const SizedBox(height: 16),

            VTTextField(
              hint: "Confirm Password",
              icon: Icons.lock_reset,
              isPassword: true,
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              onObscureToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),

            const SizedBox(height: 40),

            // --- ปุ่ม SIGN UP ---
            VTPrimaryButton(
              text: "REGISTER",
              isLoading: _isLoading,
              onPressed: _handleSignUp,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?", style: textDescription),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "SIGN IN",
                    style: textDescription.copyWith(
                      color: vtAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
