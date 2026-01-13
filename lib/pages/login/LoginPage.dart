import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth/auth_controller.dart';

class Loginpage extends StatelessWidget {
  Loginpage({super.key});

  final controller = Get.put(AuthController());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _obscurePassword = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A50E8),
              Color(0xFF7B5FD6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with back arrow and "Get Started" button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D3266),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Logicore title
              const SizedBox(height: 20),
              const Text(
                'Logicore',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),
              // White card section
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Welcome Back title
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your details below',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Email field
                          _buildTextField(
                            controller: emailController,
                            label: 'Email Address',
                            hintText: 'nicholas@ergemla.com',
                            obscureText: false,
                          ),
                          const SizedBox(height: 20),
                          // Password field
                          Obx(() => _buildTextField(
                                controller: passwordController,
                                label: 'Email Address',
                                hintText: '••••••••••••••••••••',
                                obscureText: _obscurePassword.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[400],
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    _obscurePassword.value =
                                        !_obscurePassword.value;
                                  },
                                ),
                              )),
                          const SizedBox(height: 32),
                          // Sign in button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: Obx(() => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF4A50E8),
                                        Color(0xFFB06CCF),
                                      ],
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () {
                                            controller.login(
                                              emailController.text.trim(),
                                              passwordController.text.trim(),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: controller.isLoading.value
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            'Sign in',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                )),
                          ),
                          const SizedBox(height: 24),
                          // Forgot password
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot your password?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Divider with "Or sign in with"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Or sign in with',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Social login buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  onPressed: () {},
                                  icon: 'G',
                                  label: 'Google',
                                  isGoogle: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSocialButton(
                                  onPressed: () {},
                                  icon: 'f',
                                  label: 'Facebook',
                                  isGoogle: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 16, right: 16, bottom: 8),
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: suffixIcon,
                    suffixIconConstraints: const BoxConstraints(
                      minHeight: 20,
                      minWidth: 20,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 8,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
    required bool isGoogle,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGoogle)
            Text(
              'G',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [
                      Color(0xFF4285F4),
                      Color(0xFFEA4335),
                      Color(0xFFFBBC05),
                      Color(0xFF34A853),
                    ],
                  ).createShader(const Rect.fromLTWH(0, 0, 20, 20)),
              ),
            )
          else
            const Text(
              'f',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1877F2),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isGoogle ? Colors.grey[700] : const Color(0xFF1877F2),
            ),
          ),
        ],
      ),
    );
  }
}
