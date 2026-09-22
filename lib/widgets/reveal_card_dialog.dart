import 'package:flutter/material.dart';

/// Mirrors Angular's `RevealCardDialog`: asks for the account password
/// before flipping the card to show its number/CVV. Returns the typed
/// password (non-empty) from [Navigator.pop] on confirm, or `null` on
/// cancel.
class RevealCardDialog extends StatefulWidget {
  const RevealCardDialog({super.key});

  @override
  State<RevealCardDialog> createState() => _RevealCardDialogState();
}

class _RevealCardDialogState extends State<RevealCardDialog> {
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _confirm() {
    final password = _passwordController.text.trim();

    if (password.isEmpty) return;

    Navigator.pop(context, password);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D1222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.09)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C3AED).withOpacity(0.14),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Color(0xFFC4B5FD),
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Reveal card details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Enter your password to view the sensitive card information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9299AB),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 22),

              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                onSubmitted: (_) => _confirm(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: const Color(0xFF090E1B),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF9299AB),
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF30374A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, null),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: const Color(0xFFD1D5DB),
                        side: const BorderSide(color: Color(0xFF343B4F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _passwordController,
                      builder: (context, value, _) {
                        return ElevatedButton(
                          onPressed:
                              value.text.trim().isEmpty ? null : _confirm,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF7C3AED)
                                .withOpacity(0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Continue'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
