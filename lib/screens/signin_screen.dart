import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'scan_option_screen.dart'; // เตรียมไว้สำหรับกด Login แล้วไปหน้าหลัก

import '../const/my_const.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;

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
                  style: textDescription.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 40),

                // --- ฟอร์มล็อกอิน ---
                _buildTextField(
                  hint: "Email Address",
                  icon: Icons.email_outlined,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  hint: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: textDescription.copyWith(
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- ปุ่ม SIGN IN ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // สมมติว่า Login สำเร็จ ให้วิ่งไปหน้า Scanner หลัก
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanOptionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vtAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "SIGN IN",
                      style: textLabel.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
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
                    _buildSocialButton(Icons.g_mobiledata, "Google"),
                    const SizedBox(width: 10),
                    _buildSocialButton(Icons.facebook, "Facebook"),
                    const SizedBox(width: 10),
                    _buildSocialButton(Icons.code, "GitHub"),
                  ],
                ),

                const SizedBox(height: 40),

                // --- ไปหน้า Sign Up ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: textDescription.copyWith(fontSize: 12),
                    ),
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
  }) {
    return TextField(
      obscureText: isPassword ? _obscurePassword : false,
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
  Widget _buildSocialButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // กดแล้วทำอะไร...
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: vtCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            Text(label, style: textLabel.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
