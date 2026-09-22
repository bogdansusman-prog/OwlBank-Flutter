import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mirrors Angular's `IdentityVerification` component
/// (`identity-verification.ts`/`.html`). Note: in the original Angular
/// app this screen exists but is not wired into any route or link
/// (`app.routes.ts` never references it) — it is reproduced here as-is
/// for parity, reachable at `/identity-verification`.
class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cnpController = TextEditingController();
  final _documentSeriesController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _addressController = TextEditingController();

  String _errorMessage = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cnpController.dispose();
    _documentSeriesController.dispose();
    _documentNumberController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  void _onSubmit() {
    setState(() {
      _errorMessage = '';
    });

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final cnp = _cnpController.text.trim();
    final documentSeries = _documentSeriesController.text.trim();
    final documentNumber = _documentNumberController.text.trim();
    final address = _addressController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        cnp.isEmpty ||
        documentSeries.isEmpty ||
        documentNumber.isEmpty ||
        address.isEmpty) {
      setState(() {
        _errorMessage = 'Please complete all fields.';
      });

      return;
    }

    if (!RegExp(r'^\d{13}$').hasMatch(cnp)) {
      setState(() {
        _errorMessage = 'CNP must contain exactly 13 digits.';
      });

      return;
    }

    if (!RegExp(r'^[A-Z]{2}$').hasMatch(documentSeries)) {
      setState(() {
        _errorMessage = 'ID series must contain exactly 2 letters.';
      });

      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(documentNumber)) {
      setState(() {
        _errorMessage = 'ID number must contain exactly 6 digits.';
      });

      return;
    }

    // Identity verification is simulated for now, mirroring the
    // Angular original's behavior (no backend call here yet).
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 480;

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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 28 : 32,
            ),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 460),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 32,
                  vertical: isMobile ? 22 : 34,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 60,
                      offset: const Offset(0, 25),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'OwlBank',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFC4B5FD),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Verify your identity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Enter the information from your identity card',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 26),

                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            label: 'First name',
                            controller: _firstNameController,
                            hint: 'First name',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: 'Last name',
                            controller: _lastNameController,
                            hint: 'Last name',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _field(
                      label: 'CNP',
                      controller: _cnpController,
                      hint: '13 digits',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                      helper: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _cnpController,
                        builder: (context, value, _) => Text(
                          '${value.text.length}/13 digits',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: _field(
                            label: 'ID series',
                            controller: _documentSeriesController,
                            hint: 'AB',
                            textCapitalization:
                                TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z]'),
                              ),
                              LengthLimitingTextInputFormatter(2),
                              _UpperCaseTextFormatter(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: 'ID number',
                            controller: _documentNumberController,
                            hint: '123456',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _fieldLabel('Home address'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      maxLines: 3,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: _decoration(
                        'Street, number, city, county',
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
                          color: const Color(0xFFB91C1C).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.30),
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

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D28D9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Verify identity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/register',
                          );
                        },
                        child: const Text(
                          'Back to account details',
                          style: TextStyle(
                            color: Color(0xFFD946EF),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFE5E7EB),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFF111111),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFF7C3AED)),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Widget? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: _decoration(hint),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          helper,
        ],
      ],
    );
  }
}

/// Forces typed text to uppercase, matching Angular's
/// `.toUpperCase()` call in `onDocumentSeriesInput()`.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
