import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../widgets/vt_menu_row_widget.dart';
import '../widgets/password_criteria_widget.dart';
import '../widgets/vt_snackbar_helper.dart';
import 'signin_screen.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'MANAGE ACCOUNT', centerTitle: false),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          String userName = 'PRO USER';
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['name'] ?? 'PRO USER';
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ACCOUNT INFO", style: textDescription),
                const SizedBox(height: 15),
                _buildInfoCard(
                  context,
                  "Username",
                  userName,
                  Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  "Email",
                  user.email ?? "No Email",
                  Icons.email_outlined,
                ),

                // แสดงส่วน SECURITY เฉพาะ user ที่ login ด้วย Email/Password เท่านั้น
                // (Google Sign-In ไม่มีรหัสผ่านให้เปลี่ยน)
                if (user.providerData.any(
                  (p) => p.providerId == 'password',
                )) ...[
                  const SizedBox(height: 40),
                  Text("SECURITY", style: textDescription),
                  const SizedBox(height: 15),
                  VTMenuRow(
                    icon: FontAwesomeIcons.lock,
                    text: "CHANGE PASSWORD",
                    onTap: () {
                      _showChangePasswordSheet(context);
                    },
                  ),
                ],

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(FontAwesomeIcons.powerOff, color: vtRed),
                    label: Text(
                      "LOG OUT",
                      style: textLabel.copyWith(
                        color: vtRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: vtRed.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== แสดง Bottom Sheet สำหรับเปลี่ยนรหัสผ่าน =====
  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ChangePasswordSheet(),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textDescription.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: textLabel.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Widget สำหรับฟอร์มเปลี่ยนรหัสผ่าน (StatefulWidget แยกต่างหาก) =====
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // ตัวแปรเช็คความปลอดภัยรหัสผ่าน
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasSpecialChars = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordValid =>
      _hasMinLength && _hasUppercase && _hasDigits && _hasSpecialChars;

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // เช็คว่ากรอกข้อมูลครบ
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showVTSnackBar(context, "Please fill all fields", Colors.redAccent);
      return;
    }

    // เช็คว่ารหัสผ่านใหม่ผ่านเกณฑ์
    if (!_isPasswordValid) {
      showVTSnackBar(
        context,
        "Please meet all password requirements",
        Colors.redAccent,
      );
      return;
    }

    // เช็คว่ารหัสผ่านใหม่ 2 ช่องตรงกัน
    if (newPassword != confirmPassword) {
      showVTSnackBar(context, "New passwords do not match", Colors.redAccent);
      return;
    }

    // เช็คว่ารหัสผ่านใหม่ไม่ซ้ำกับรหัสเดิม
    if (currentPassword == newPassword) {
      showVTSnackBar(
        context,
        "New password must be different from current password",
        Colors.redAccent,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // 1. Reauthenticate ด้วยรหัสเดิมก่อน (Firebase บังคับ)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. อัปเดตรหัสผ่านใหม่
      await user.updatePassword(newPassword);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context); // ปิด Bottom Sheet
        showVTSnackBar(context, "Password changed successfully! ✓", vtGreen);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String errorMessage;
        switch (e.code) {
          case 'wrong-password':
          case 'invalid-credential':
            errorMessage = 'Current password is incorrect.';
            break;
          case 'weak-password':
            errorMessage = 'The new password is too weak.';
            break;
          case 'requires-recent-login':
            errorMessage =
                'Please log out and sign in again before changing password.';
            break;
          default:
            errorMessage = e.message ?? 'An error occurred.';
        }
        showVTSnackBar(context, errorMessage, Colors.redAccent);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showVTSnackBar(
          context,
          "An unexpected error occurred.",
          Colors.redAccent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ขีดคั่นด้านบน
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // หัวข้อ
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.shieldHalved,
                    color: vtAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "CHANGE PASSWORD",
                    style: textLabel.copyWith(fontSize: 18, letterSpacing: 1.5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your current password and choose a new one.",
                style: textDescription.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // --- ช่องรหัสผ่านเดิม ---
              _buildPasswordField(
                hint: "Current Password",
                icon: Icons.lock_outline,
                controller: _currentPasswordController,
                obscure: _obscureCurrent,
                onToggle: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 16),

              // เส้นแบ่ง
              Divider(color: Colors.grey.withValues(alpha: 0.2), thickness: 1),
              const SizedBox(height: 16),

              // --- ช่องรหัสผ่านใหม่ ---
              _buildPasswordField(
                hint: "New Password",
                icon: Icons.lock_reset,
                controller: _newPasswordController,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                onChanged: _validatePassword,
              ),

              // --- Checklist ตรวจความปลอดภัย ---
              if (_newPasswordController.text.isNotEmpty) ...[
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

              // --- ช่องยืนยันรหัสผ่านใหม่ ---
              _buildPasswordField(
                hint: "Confirm New Password",
                icon: Icons.lock_outline,
                controller: _confirmPasswordController,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 32),

              // --- ปุ่ม CONFIRM ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vtAccent,
                    disabledBackgroundColor: vtAccent.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "CHANGE PASSWORD",
                          style: textLabel.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscure,
      style: textDescription.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textDescription.copyWith(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: vtAccent, width: 2),
        ),
      ),
    );
  }
}
