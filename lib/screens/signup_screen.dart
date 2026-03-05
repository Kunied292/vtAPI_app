import 'package:flutter/material.dart';
import 'scan_option_screen.dart';
import '../services/auth_service.dart'; // <--- Import Auth Service
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../widgets/vt_primary_button_widget.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please fill all fields",
            style: textLabel.copyWith(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // เช็คว่ารหัสผ่านผ่านเกณฑ์ความปลอดภัยไหม
    bool isPasswordValid =
        _hasMinLength && _hasUppercase && _hasDigits && _hasSpecialChars;
    if (!isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please meet all password requirements",
            style: textLabel.copyWith(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // เช็คว่ารหัสผ่าน 2 ช่องตรงกันไหม
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Passwords do not match",
            style: textLabel.copyWith(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
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
          // ถ้าเกิด Error (เช่น อีเมลซ้ำ, พิมพ์ผิดรูปแบบ)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                failure.message,
                style: textLabel.copyWith(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
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
      backgroundColor: vtBackground,
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
            _buildTextField(
              hint: "Full Name",
              icon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              hint: "Email Address",
              icon: Icons.email_outlined,
              controller: _emailController,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              hint: "Password",
              icon: Icons.lock_outline,
              isPassword: true,
              controller: _passwordController,
              onChanged: _validatePassword,
              obscureState: _obscurePassword,
              onObscureToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),

            // --- Checklist ตรวจรหัสผ่าน ---
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPasswordCriteria("At least 8 characters", _hasMinLength),
              _buildPasswordCriteria("Contains uppercase (A-Z)", _hasUppercase),
              _buildPasswordCriteria("Contains number (0-9)", _hasDigits),
              _buildPasswordCriteria(
                "Contains special char (!@#\$)",
                _hasSpecialChars,
              ),
            ],

            const SizedBox(height: 16),

            _buildTextField(
              hint: "Confirm Password",
              icon: Icons.lock_reset,
              isPassword: true,
              controller: _confirmPasswordController,
              obscureState: _obscureConfirm,
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

  // Widget สร้าง TextField ที่ปรับแต่งให้รับ Controller และ onChanged ได้
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
    Function(String)? onChanged,
    bool obscureState = true,
    VoidCallback? onObscureToggle,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isPassword ? obscureState : false,
      style: textDescription.copyWith(color: vtTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textDescription,
        filled: true,
        fillColor: vtCard,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureState ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onObscureToggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: vtAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordCriteria(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 10.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? vtGreen : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? vtGreen : Colors.grey,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
