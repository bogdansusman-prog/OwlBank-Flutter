import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../services/user_service.dart';

class SendMoneyDialog extends StatefulWidget {
  const SendMoneyDialog({
    super.key,
  });

  @override
  State<SendMoneyDialog> createState() =>
      _SendMoneyDialogState();
}

class _SendMoneyDialogState
    extends State<SendMoneyDialog> {
  final UserService _userService =
      UserService();

  final _phoneController =
      TextEditingController();

  final _amountController =
      TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  Future<void> _sendMoney() async {
    final phone =
        _phoneController.text.trim();

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    setState(() {
      _errorMessage = '';
    });

    if (phone.isEmpty) {
      setState(() {
        _errorMessage =
            'Please enter a phone number.';
      });

      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage =
            'Please enter a valid amount.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.transferMoney(
        phone,
        amount,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.response?.statusCode == 401) {
          _errorMessage =
              'Your session has expired. Please log in again.';
        } else if (error.response?.statusCode ==
            404) {
          _errorMessage =
              'No OwlBank user was found with this phone number.';
        } else if (error.response?.statusCode ==
            400) {
          _errorMessage =
              'Transfer failed. Check your balance and the transfer amount.';
        } else {
          _errorMessage =
              'Transfer failed. Please try again.';
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
      backgroundColor:
          const Color(0xFF0D1222),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
        side: BorderSide(
          color:
              Colors.white.withOpacity(0.09),
        ),
      ),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 430,
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(28),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Align(
                alignment:
                    Alignment.topRight,
                child: IconButton(
                  onPressed: _isLoading
                      ? null
                      : () =>
                          Navigator.pop(
                            context,
                            false,
                          ),
                  icon: const Icon(
                    Icons.close,
                    color:
                        Color(0xFF969DB0),
                  ),
                ),
              ),

              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end: Alignment
                        .bottomRight,
                    colors: [
                      Color(0x667C3AED),
                      Color(0x335B21B6),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.send,
                  color:
                      Color(0xFFC4B5FD),
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Send Money',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Transfer money to another OwlBank user',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Color(0xFF858DA0),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 26),

              _label('Phone Number'),

              const SizedBox(height: 7),

              TextField(
                controller:
                    _phoneController,
                keyboardType:
                    TextInputType.phone,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    _inputDecoration(
                  hint:
                      'e.g. 0712345678',
                  prefixIcon:
                      Icons.phone,
                ),
              ),

              const SizedBox(height: 18),

              _label('Amount'),

              const SizedBox(height: 7),

              TextField(
                controller:
                    _amountController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    _inputDecoration(
                  hint: '0.00',
                  prefixText: '\$ ',
                ),
              ),

              if (_errorMessage
                  .isNotEmpty) ...[
                const SizedBox(height: 15),

                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color:
                        Color(0xFFF87171),
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () =>
                              Navigator.pop(
                                context,
                                false,
                              ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        minimumSize:
                            const Size(
                          0,
                          48,
                        ),
                        foregroundColor:
                            const Color(
                          0xFFD1D5DB,
                        ),
                        side:
                            const BorderSide(
                          color: Color(
                            0xFF343B4F,
                          ),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'Cancel',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : _sendMoney,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              size: 18,
                            ),
                      label: Text(
                        _isLoading
                            ? 'Sending...'
                            : 'Send Money',
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        minimumSize:
                            const Size(
                          0,
                          48,
                        ),
                        backgroundColor:
                            const Color(
                          0xFF7C3AED,
                        ),
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
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
      alignment:
          Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontSize: 14,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF6B7280),
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(
              prefixIcon,
              color:
                  const Color(
                    0xFF8B5CF6,
                  ),
            ),
      prefixText: prefixText,
      prefixStyle:
          const TextStyle(
        color: Color(0xFFC4B5FD),
        fontSize: 16,
      ),
      filled: true,
      fillColor:
          const Color(0xFF090E1B),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color: Color(0xFF30374A),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color: Color(0xFF8B5CF6),
        ),
      ),
    );
  }
}