import 'package:flutter/material.dart';

import '../services/user_service.dart';

/// Mirrors Angular's `ChangePasswordDialog`. The Angular original only
/// validates and `console.log`s the result (it never calls a backend
/// endpoint); here it is wired to `UserService.resetPassword()`, which
/// is clearly the endpoint this dialog was meant to reach, since it is
/// already handed the signed-in user's email address.
class ChangePasswordDialog extends StatefulWidget {
  final String email;

  const ChangePasswordDialog({
    super.key,
    required this.email,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final UserService _userService = UserService();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _errorMessage = '';
  String _successMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
    });

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please complete all fields.';
      });

      return;
    }

    if (newPassword.length < 8) {
      setState(() {
        _errorMessage =
            'New password must contain at least 8 characters.';
      });

      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'New passwords do not match.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.resetPassword(
        email: widget.email,
        password: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      setState(() {
        _successMessage = 'Password changed successfully.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Could not change your password.';
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
    return Dialog(
      backgroundColor: const Color(0xFF0D1222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.09)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFF7C3AED).withOpacity(0.14),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: Color(0xFFC4B5FD),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Enter your current password and choose a new password.',
                          style: TextStyle(
                            color: Color(0xFF858DA0),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF969DB0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _label('Current Password'),
              const SizedBox(height: 6),
              _passwordField(
                controller: _currentPasswordController,
                hint: 'Enter current password',
              ),

              const SizedBox(height: 14),

              _label('New Password'),
              const SizedBox(height: 6),
              _passwordField(
                controller: _newPasswordController,
                hint: 'Enter new password',
              ),

              const SizedBox(height: 14),

              _label('Confirm New Password'),
              const SizedBox(height: 6),
              _passwordField(
                controller: _confirmPasswordController,
                hint: 'Enter new password again',
              ),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFF87171),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFF87171),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (_successMessage.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4ADE80),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage,
                        style: const TextStyle(
                          color: Color(0xFF4ADE80),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
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
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _changePassword,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.lock_reset, size: 18),
                      label: Text(
                        _isLoading ? 'Changing...' : 'Change Password',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFE5E7EB),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFF090E1B),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF30374A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }
}
