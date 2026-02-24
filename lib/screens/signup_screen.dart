import 'package:flutter/material.dart';

import '../const/my_const.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // ตัวแปรสำหรับเช็คความปลอดภัยของรหัสผ่าน
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasSpecialChars = false;

  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CREATE ACCOUNT",
              style: textTitle.copyWith(fontSize: 28, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              "Register to secure your device.",
              style: textLabel.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 40),

            // --- ฟอร์มกรอกข้อมูล ---
            _buildTextField(hint: "Full Name", icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(hint: "Email Address", icon: Icons.email_outlined),
            const SizedBox(height: 16),

            // ช่อง Password หลัก (ดักจับการพิมพ์ด้วย onChanged)
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

            // --- Checklist ตรวจรหัสผ่าน (จะโผล่มาเมื่อเริ่มพิมพ์) ---
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

            // ช่อง Confirm Password
            _buildTextField(
              hint: "Confirm Password",
              icon: Icons.lock_reset,
              isPassword: true,
              obscureState: _obscureConfirm,
              onObscureToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),

            const SizedBox(height: 40),

            // --- ปุ่ม SIGN UP ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // เช็คว่าผ่านเงื่อนไขรหัสผ่านครบไหมก่อนสมัคร
                  bool isPasswordValid =
                      _hasMinLength &&
                      _hasUppercase &&
                      _hasDigits &&
                      _hasSpecialChars;
                  if (!isPasswordValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please meet all password requirements"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  // TODO: ต่อ API สมัครสมาชิก
                  debugPrint("Registering User...");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: vtAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "REGISTER",
                  style: textLabel.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- กลับไปหน้า Sign In ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: textDescription.copyWith(fontSize: 12),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context), // เด้งกลับไปหน้า Sign In
                  child: Text(
                    "SIGN IN",
                    style: textLabel.copyWith(
                      color: vtAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
      style: textLabel.copyWith(fontSize: 16, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
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

  // Widget สร้างรายการ Checklist ตรวจรหัสผ่าน
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
