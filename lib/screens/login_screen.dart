import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isButtonHovered = false;
  bool _obscurePassword = true;

  String _errorMessage = '';

  Offset _mousePosition = Offset.zero;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _errorMessage = '';
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please complete all fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password.';
        });
      }
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.response == null) {
          _errorMessage = 'Cannot connect to the server.';
        } else if (error.response?.data != null &&
            error.response!.data.toString().trim().isNotEmpty) {
          _errorMessage = error.response!.data.toString();
        } else {
          _errorMessage = 'Invalid email or password.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Invalid email or password.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isMobile = screenWidth <= 480;
    final isSmallMobile = screenWidth <= 360;
    final isShortScreen = screenHeight <= 650;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF111827),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -250,
              left: 0,
              right: 0,
              child: Container(
                height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF312E81).withOpacity(0.95),
                      const Color(0xFF312E81).withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallMobile
                      ? 12
                      : isMobile
                          ? 16
                          : 20,
                  vertical: isMobile ? 28 : 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height - 40,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: isMobile || isShortScreen
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/owlbank-logo.png',
                          width: isSmallMobile
                              ? 110
                              : isMobile
                                  ? 135
                                  : 180,
                        ),

                        SizedBox(
                          height: isMobile ? 18 : 26,
                        ),

                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxWidth: 380,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallMobile ? 18 : 32,
                            vertical: isSmallMobile ? 20 : 34,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(
                              isMobile ? 14 : 18,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: 60,
                                offset: const Offset(0, 25),
                              ),
                              BoxShadow(
                                color: const Color(0xFF7C3AED)
                                    .withOpacity(0.12),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'OwlBank',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'Log in to your account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 28),

                              const Text(
                                'Email',
                                style: TextStyle(
                                  color: Color(0xFFE5E7EB),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              _buildTextField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                hintText: 'Enter your email',
                                keyboardType:
                                    TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Password',
                                style: TextStyle(
                                  color: Color(0xFFE5E7EB),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              _buildTextField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                hintText: 'Enter your password',
                                obscureText: _obscurePassword,
                                onSubmitted: (_) => _login(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/reset-password',
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: Color(0xFFD946EF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              if (_errorMessage.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB91C1C)
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.30),
                                    ),
                                  ),
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                      color: Color(0xFFFCA5A5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              MouseRegion(
                                onEnter: (_) {
                                  setState(() {
                                    _isButtonHovered = true;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    _isButtonHovered = false;
                                  });
                                },
                                onHover: (event) {
                                  setState(() {
                                    _mousePosition =
                                        event.localPosition;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 180),
                                  transform: Matrix4.translationValues(
                                    0,
                                    _isButtonHovered ? -2 : 0,
                                    0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(9),
                                    boxShadow: _isButtonHovered
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF7C3AED,
                                              ).withOpacity(0.4),
                                              blurRadius: 22,
                                              offset:
                                                  const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: const Color(
                                                0xFFD946EF,
                                              ).withOpacity(0.25),
                                              blurRadius: 16,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _login,
                                      style:
                                          ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        backgroundColor:
                                            const Color(0xFF6D28D9),
                                        disabledBackgroundColor:
                                            const Color(0xFFC4B5FD)
                                                .withOpacity(0.7),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          gradient: _isButtonHovered
                                              ? RadialGradient(
                                                  center: Alignment(
                                                    (_mousePosition.dx /
                                                                380) *
                                                            2 -
                                                        1,
                                                    (_mousePosition.dy /
                                                                48) *
                                                            2 -
                                                        1,
                                                  ),
                                                  radius: 2.5,
                                                  colors: const [
                                                    Color(0xFFE879F9),
                                                    Color(0xFFC026D3),
                                                    Color(0xFF8B5CF6),
                                                    Color(0xFF6D28D9),
                                                  ],
                                                  stops: [
                                                    0,
                                                    0.30,
                                                    0.55,
                                                    1,
                                                  ],
                                                )
                                              : null,
                                          color: _isButtonHovered
                                              ? null
                                              : const Color(
                                                  0xFF6D28D9,
                                                ),
                                        ),
                                        child: Center(
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text(
                                                  'Log in',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/register',
                                      );
                                    },
                                    child: const Text(
                                      'Create one here',
                                      style: TextStyle(
                                        color: Color(0xFFD946EF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final hasFocus = focusNode.hasFocus;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color:
                          const Color(0xFF7C3AED).withOpacity(0.15),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFF111111),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: Color(0xFF333333),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}