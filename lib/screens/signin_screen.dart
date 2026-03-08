import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'signup_screen.dart';
import 'scan_option_screen.dart';

import '../services/auth_service.dart';
import '../const/my_const.dart';
import '../widgets/vt_primary_button_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  bool get _isAnyLoading => _isLoading || _isGoogleLoading;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isAnyLoading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ดักไว้ก่อนว่ากรอกครบไหม
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter both email and password",
            style: textLabel.copyWith(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // เปิดตัวหมุน

    // เรียกใช้ Firebase
    final authService = AuthService();
    final resultOrFailure = await authService.signInWithEmail(email, password);

    if (mounted) {
      setState(() => _isLoading = false); // ปิดตัวหมุน

      resultOrFailure.fold(
        (failure) {
          // แจ้งเตือน Error
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
          // ล็อกอินสำเร็จ ล้างประวัติหน้า Login แล้วไปหน้า Scanner
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ScanOptionScreen()),
            (route) => false,
          );
        },
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isAnyLoading) return;
    setState(() => _isGoogleLoading = true);

    final authService = AuthService();
    final errorMessage = await authService.signInWithGoogle();

    if (mounted) {
      setState(() => _isGoogleLoading = false);

      if (errorMessage == null) {
        // สำเร็จ พาเข้าแอปเลย
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ScanOptionScreen()),
          (route) => false,
        );
      } else if (errorMessage != 'cancelled') {
        // โชว์ Error (ยกเว้นกรณีที่ผู้ใช้กดยกเลิกเอง)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- โลโก้ / หัวข้อ ---
                Icon(Icons.security, size: 80, color: vtAccent),
                const SizedBox(height: 20),
                Text(
                  "WELCOME BACK",
                  style: textTitle.copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  "Authenticate to continue to VT Scanner",
                  style: textDescription,
                ),
                const SizedBox(height: 40),

                // --- ฟอร์มล็อกอิน ---
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
                ),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanOptionScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Guest Account",
                      style: textDescription.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- ปุ่ม SIGN IN ---
                VTPrimaryButton(
                  text: "SIGN IN",
                  isLoading: _isLoading,
                  onPressed: _handleSignIn,
                ),
                const SizedBox(height: 40),

                // --- ตัวคั่น (Divider) ---
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR CONTINUE WITH",
                        style: textDescription.copyWith(fontSize: 12),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 30),

                // --- ปุ่ม Social Login ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      FontAwesomeIcons.google,
                      " Google",
                      onTap: _handleGoogleSignIn,
                      isLoading: _isGoogleLoading,
                    ),
                    const SizedBox(width: 10),
                    _buildSocialButton(
                      FontAwesomeIcons.facebook,
                      " Facebook",
                      onTap: _handleGoogleSignIn,
                    ),
                    const SizedBox(width: 10),
                    _buildSocialButton(
                      FontAwesomeIcons.github,
                      " GitHub",
                      onTap: _handleGoogleSignIn,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- ไปหน้า Sign Up ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: textDescription),
                    TextButton(
                      onPressed: () {
                        // กดแล้วไปหน้า Sign Up
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "SIGN UP",
                        style: textDescription.copyWith(
                          color: vtAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget สร้าง TextField
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
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
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
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

  // Widget สร้างปุ่ม Social
  Widget _buildSocialButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: _isAnyLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: vtCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 30,
                height: 30,
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 30),
            Text(label, style: textLabel.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
