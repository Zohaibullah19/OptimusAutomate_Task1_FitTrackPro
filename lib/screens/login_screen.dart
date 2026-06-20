import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscured = true;

  // Premium Framework Colors
  static const Color _brandColor = Color(0xFF10B981);      // Emerald Green
  static const Color _brandGradientEnd = Color(0xFF059669); 
  static const Color _bgColor = Color(0xFFF8FAFC);          // Slate 50 White
  static const Color _textPrimary = Color(0xFF0F172A);      // Slate 900
  static const Color _textSecondary = Color(0xFF64748B);    // Slate 500

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? result = await AuthService().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      // Use declarative routing go() to replace auth stack context cleanly across platforms
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(result, style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.black.withAlpha(6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Identity Icon Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_brandColor, _brandGradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _brandColor.withAlpha(40),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.analytics_rounded, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      "Welcome Back",
                      style: TextStyle(color: _textPrimary, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.6),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Sign in to your FitTrack Pro profile",
                      style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 36),

                    // Email Input Layer
                    _buildInputField(
                      controller: _emailController,
                      labelText: "Email Address",
                      hintText: "username@domain.com",
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please input an email parameter.";
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return "Please supply a valid corporate email format.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Input Layer
                    _buildInputField(
                      controller: _passwordController,
                      labelText: "Account Password",
                      hintText: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      obscureText: _isPasswordObscured,
                      keyboardType: TextInputType.visiblePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: _textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password parameter cannot remain null.";
                        }
                        if (value.length < 6) {
                          return "Security key must exceed 6 parameters.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Form Action Authentication Submission Button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: _isLoading
                            ? null
                            : const LinearGradient(
                                colors: [_brandColor, _brandGradientEnd],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: _isLoading ? Colors.grey.shade300 : null,
                        boxShadow: _isLoading ? [] : [
                          BoxShadow(color: _brandColor.withAlpha(40), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text("Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.2)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Navigational Redirection Route Linker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New to FitTrack Pro? ",
                          style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w400),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'), 
                          child: const Text(
                            "Create Account",
                            style: TextStyle(color: _brandColor, fontSize: 13, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: _textSecondary.withAlpha(100), fontSize: 13),
        labelStyle: const TextStyle(color: _textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
        floatingLabelStyle: const TextStyle(color: _brandColor, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: _textSecondary.withAlpha(180), size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _brandColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}