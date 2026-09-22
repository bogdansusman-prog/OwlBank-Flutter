import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isButtonHovered = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _errorMessage = '';

  Offset _mousePosition = Offset.zero;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  bool get _formValid {
    final email = _emailController.text.trim();

    final emailValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        emailValid &&
        _phoneController.text.trim().isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _passwordController.text.length >= 8 &&
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    final year = selectedDate.year.toString();
    final month = selectedDate.month.toString().padLeft(2, '0');
    final day = selectedDate.day.toString().padLeft(2, '0');

    setState(() {
      _dateController.text = '$year-$month-$day';
    });
  }

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final dateOfBirth = _dateController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _errorMessage = '';
    });

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        dateOfBirth.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please complete all fields.';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage =
            'Password must contain at least 8 characters.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.response == null) {
          _errorMessage = 'Cannot connect to the server.';
        } else if (error.response?.data != null &&
            error.response!.data.toString().trim().isNotEmpty) {
          _errorMessage =
              error.response!.data.toString();
        } else {
          _errorMessage =
              'Account creation failed.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Account creation failed.';
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
    final screenWidth =
        MediaQuery.of(context).size.width;

    final isMobile = screenWidth <= 480;

    return Scaffold(
      body: Container(
        width: double.infinity,
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
        ),
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
                      const Color(0xFF312E81)
                          .withOpacity(0.95),
                      const Color(0xFF312E81)
                          .withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: 28,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/owlbank-logo.png',
                        width: isMobile ? 135 : 180,
                      ),

                      SizedBox(
                        height: isMobile ? 18 : 26,
                      ),

                      Container(
                        width: double.infinity,
                        constraints:
                            const BoxConstraints(
                          maxWidth: 460,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              isMobile ? 26 : 38,
                          vertical:
                              isMobile ? 26 : 38,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF111111),
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white
                                .withOpacity(0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.45),
                              blurRadius: 60,
                              offset:
                                  const Offset(0, 25),
                            ),
                            BoxShadow(
                              color:
                                  const Color(0xFF7C3AED)
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
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color:
                                    Color(0xFF6D28D9),
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Create account',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Enter your details to get started',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color:
                                    Color(0xFF9CA3AF),
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 28),

                            _field(
                              label: 'First name',
                              controller:
                                  _firstNameController,
                              hint:
                                  'Enter your first name',
                            ),

                            _field(
                              label: 'Last name',
                              controller:
                                  _lastNameController,
                              hint:
                                  'Enter your last name',
                            ),

                            _field(
                              label: 'Email',
                              controller:
                                  _emailController,
                              hint:
                                  'example@gmail.com',
                              keyboardType:
                                  TextInputType
                                      .emailAddress,
                            ),

                            _field(
                              label: 'Phone number',
                              controller:
                                  _phoneController,
                              hint:
                                  '+40 700 000 000',
                              keyboardType:
                                  TextInputType.phone,
                            ),

                            _dateField(),

                            _field(
                              label: 'Password',
                              controller:
                                  _passwordController,
                              hint:
                                  'Minimum 8 characters',
                              obscureText: _obscurePassword,
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

                            _field(
                              label:
                                  'Confirm password',
                              controller:
                                  _confirmPasswordController,
                              hint:
                                  'Enter password again',
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),

                            if (_errorMessage
                                .isNotEmpty) ...[
                              Container(
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 16,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                        0xFFFEE2E2,
                                      ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: Text(
                                  _errorMessage,
                                  style:
                                      const TextStyle(
                                    color: Color(
                                      0xFFB91C1C,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],

                            LayoutBuilder(
                              builder:
                                  (context, constraints) {
                                final width =
                                    constraints.maxWidth;

                                return MouseRegion(
                                  onEnter: (_) {
                                    setState(() {
                                      _isButtonHovered =
                                          true;
                                    });
                                  },
                                  onExit: (_) {
                                    setState(() {
                                      _isButtonHovered =
                                          false;
                                    });
                                  },
                                  onHover: (event) {
                                    setState(() {
                                      _mousePosition =
                                          event
                                              .localPosition;
                                    });
                                  },
                                  child:
                                      AnimatedContainer(
                                    duration:
                                        const Duration(
                                      milliseconds: 180,
                                    ),
                                    transform: Matrix4
                                        .translationValues(
                                      0,
                                      _isButtonHovered
                                          ? -2
                                          : 0,
                                      0,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        9,
                                      ),
                                      boxShadow:
                                          _isButtonHovered
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF7C3AED,
                                                    ).withOpacity(
                                                      0.4,
                                                    ),
                                                    blurRadius:
                                                        22,
                                                    offset:
                                                        const Offset(
                                                      0,
                                                      10,
                                                    ),
                                                  ),
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFD946EF,
                                                    ).withOpacity(
                                                      0.25,
                                                    ),
                                                    blurRadius:
                                                        16,
                                                  ),
                                                ]
                                              : [],
                                    ),
                                    child: SizedBox(
                                      height: 48,
                                      child:
                                          ElevatedButton(
                                        onPressed:
                                            !_formValid ||
                                                    _isLoading
                                                ? null
                                                : _register,
                                        style:
                                            ElevatedButton
                                                .styleFrom(
                                          padding:
                                              EdgeInsets
                                                  .zero,
                                          elevation: 0,
                                          backgroundColor:
                                              const Color(
                                            0xFF6D28D9,
                                          ),
                                          disabledBackgroundColor:
                                              const Color(
                                            0xFFC4B5FD,
                                          ).withOpacity(
                                            0.7,
                                          ),
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              9,
                                            ),
                                          ),
                                        ),
                                        child: Ink(
                                          decoration:
                                              BoxDecoration(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              9,
                                            ),
                                            gradient:
                                                _isButtonHovered &&
                                                        _formValid
                                                    ? RadialGradient(
                                                        center:
                                                            Alignment(
                                                          (_mousePosition.dx /
                                                                      width) *
                                                                  2 -
                                                              1,
                                                          (_mousePosition.dy /
                                                                      48) *
                                                                  2 -
                                                              1,
                                                        ),
                                                        radius:
                                                            2.5,
                                                        colors: const [
                                                          Color(
                                                            0xFFE879F9,
                                                          ),
                                                          Color(
                                                            0xFFC026D3,
                                                          ),
                                                          Color(
                                                            0xFF8B5CF6,
                                                          ),
                                                          Color(
                                                            0xFF6D28D9,
                                                          ),
                                                        ],
                                                        stops: const [
                                                          0,
                                                          0.30,
                                                          0.55,
                                                          1,
                                                        ],
                                                      )
                                                    : null,
                                          ),
                                          child: Center(
                                            child:
                                                _isLoading
                                                    ? const SizedBox(
                                                        width:
                                                            20,
                                                        height:
                                                            20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth:
                                                              2,
                                                          color:
                                                              Colors.white,
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Create account',
                                                        style:
                                                            TextStyle(
                                                          color:
                                                              Colors.white,
                                                          fontSize:
                                                              16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 22),

                            Wrap(
                              alignment:
                                  WrapAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF9CA3AF),
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator
                                        .pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  },
                                  child: const Text(
                                    'Log in',
                                    style: TextStyle(
                                      color:
                                          Color(0xFFD946EF),
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w700,
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
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 17,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: (_) {
              setState(() {});
            },
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor:
                  const Color(0xFF111111),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: suffixIcon,
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(9),
                borderSide:
                    const BorderSide(
                  color: Color(0xFF333333),
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(9),
                borderSide:
                    const BorderSide(
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 17,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Date of birth',
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          TextField(
            controller: _dateController,
            readOnly: true,
            onTap: _selectDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'YYYY-MM-DD',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
              ),
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF9CA3AF),
                size: 19,
              ),
              filled: true,
              fillColor:
                  const Color(0xFF111111),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(9),
                borderSide:
                    const BorderSide(
                  color: Color(0xFF333333),
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(9),
                borderSide:
                    const BorderSide(
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}