import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../services/user_service.dart';

/// Mirrors Angular's `DepositDialog` (`deposit-dialog.ts`/`.html`):
/// lets the user add money to their balance by entering an amount and a
/// description, then calls `UserService.deposit()`.
class DepositDialog extends StatefulWidget {
  const DepositDialog({super.key});

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final UserService _userService = UserService();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _deposit() async {
    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    final description = _descriptionController.text.trim();

    setState(() {
      _errorMessage = '';
    });

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount.';
      });

      return;
    }

    if (description.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a description.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.deposit(amount, description);

      if (!mounted) return;

      Navigator.pop(context, true);
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.response?.statusCode == 401) {
          _errorMessage =
              'Your session has expired. Please log in again.';
        } else {
          _errorMessage = 'Deposit failed. Please try again.';
        }
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
        side: BorderSide(
          color: Colors.white.withOpacity(0.09),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pop(context, false),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF969DB0),
                  ),
                ),
              ),

              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x6622C55E),
                      Color(0x33166534),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF86EFAC),
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Deposit Money',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Add money to your OwlBank account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF858DA0),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 26),

              _label('Amount'),

              const SizedBox(height: 7),

              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: '0.00',
                  prefixText: '\$ ',
                ),
              ),

              const SizedBox(height: 18),

              _label('Description'),

              const SizedBox(height: 7),

              TextField(
                controller: _descriptionController,
                maxLength: 1000,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: 'e.g. Salary',
                ).copyWith(counterText: ''),
              ),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 15),

                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Color(0xFFF87171),
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: const Color(0xFFD1D5DB),
                        side: const BorderSide(
                          color: Color(0xFF343B4F),
                        ),
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
                      onPressed: _isLoading ? null : _deposit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add, size: 18),
                      label: Text(
                        _isLoading ? 'Depositing...' : 'Deposit',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: const Color(0xFF22C55E),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: Color(0xFFC4B5FD),
        fontSize: 16,
      ),
      filled: true,
      fillColor: const Color(0xFF090E1B),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF30374A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF22C55E)),
      ),
    );
  }
}
