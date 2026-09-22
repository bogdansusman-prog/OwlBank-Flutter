import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/deposit_dialog.dart';
import '../widgets/send_money_dialog.dart';
import '../widgets/withdraw_dialog.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() =>
      _TransferScreenState();
}

class _TransferScreenState
    extends State<TransferScreen> {
  final AuthService _authService =
      AuthService();

  String _successMessage = '';

  Future<void> _signOut() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Future<void> _openSendMoney() async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor:
          Colors.black.withOpacity(0.72),
      builder: (_) =>
          const SendMoneyDialog(),
    );

    if (result == true && mounted) {
      setState(() {
        _successMessage =
            'Money sent successfully.';
      });
    }
  }

  Future<void> _openDeposit() async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (_) => const DepositDialog(),
    );

    if (result == true && mounted) {
      setState(() {
        _successMessage = 'Deposit successful.';
      });
    }
  }

  Future<void> _openWithdraw() async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (_) => const WithdrawDialog(),
    );

    if (result == true && mounted) {
      setState(() {
        _successMessage = 'Withdrawal successful.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    final isMobile = width <= 650;
    final compactNavbar = width <= 900;

    return Scaffold(
      backgroundColor:
          const Color(0xFF060B18),
      body: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height,
        ),
        decoration: BoxDecoration(
          color:
              const Color(0xFF060B18),
          gradient: RadialGradient(
            center:
                const Alignment(0, -0.8),
            radius: 0.9,
            colors: [
              const Color(0xFF7C3AED)
                  .withOpacity(0.13),
              const Color(0xFF060B18),
            ],
            stops: const [
              0,
              0.58,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 24,
              isMobile ? 12 : 18,
              isMobile ? 12 : 24,
              50,
            ),
            child: Column(
              children: [
                _buildNavbar(
                  compact:
                      compactNavbar,
                ),

                SizedBox(
                  height:
                      isMobile ? 40 : 68,
                ),

                ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 1150,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Transfer & Payments',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 34,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        'Move your money quickly and securely',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: Color(
                            0xFF9299AB,
                          ),
                          fontSize: 16,
                        ),
                      ),

                      if (_successMessage
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 22,
                        ),
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFF22C55E,
                            ).withOpacity(
                              0.08,
                            ),
                            border:
                                Border.all(
                              color:
                                  const Color(
                                    0xFF4ADE80,
                                  ).withOpacity(
                                    0.25,
                                  ),
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                          child:
                              Text(
                            _successMessage,
                            style:
                                const TextStyle(
                              color: Color(
                                0xFF4ADE80,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 45,
                      ),

                      LayoutBuilder(
                        builder:
                            (context,
                                constraints) {
                          if (constraints
                                  .maxWidth <=
                              650) {
                            return Column(
                              children: [
                                _actionCard(
                                  icon:
                                      Icons.send,
                                  title:
                                      'Send Money',
                                  description:
                                      'Transfer money instantly to another OwlBank user.',
                                  buttonText:
                                      'Send Money',
                                  onTap:
                                      _openSendMoney,
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                _actionCard(
                                  icon: Icons
                                      .add_circle_outline,
                                  title:
                                      'Deposit Money',
                                  description:
                                      'Add money to your OwlBank balance.',
                                  buttonText:
                                      'Deposit',
                                  onTap:
                                      _openDeposit,
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                _actionCard(
                                  icon: Icons
                                      .remove_circle_outline,
                                  title:
                                      'Withdraw Money',
                                  description:
                                      'Withdraw funds from your available balance.',
                                  buttonText:
                                      'Withdraw',
                                  onTap:
                                      _openWithdraw,
                                ),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .stretch,
                            children: [
                              Expanded(
                                child:
                                    _actionCard(
                                  icon:
                                      Icons.send,
                                  title:
                                      'Send Money',
                                  description:
                                      'Transfer money instantly to another OwlBank user.',
                                  buttonText:
                                      'Send Money',
                                  onTap:
                                      _openSendMoney,
                                ),
                              ),

                              const SizedBox(
                                width: 20,
                              ),

                              Expanded(
                                child:
                                    _actionCard(
                                  icon: Icons
                                      .add_circle_outline,
                                  title:
                                      'Deposit Money',
                                  description:
                                      'Add money to your OwlBank balance.',
                                  buttonText:
                                      'Deposit',
                                  onTap:
                                      _openDeposit,
                                ),
                              ),

                              const SizedBox(
                                width: 20,
                              ),

                              Expanded(
                                child:
                                    _actionCard(
                                  icon: Icons
                                      .remove_circle_outline,
                                  title:
                                      'Withdraw Money',
                                  description:
                                      'Withdraw funds from your available balance.',
                                  buttonText:
                                      'Withdraw',
                                  onTap:
                                      _openWithdraw,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return _TransferActionCard(
      icon: icon,
      title: title,
      description: description,
      buttonText: buttonText,
      onTap: onTap,
    );
  }

  Widget _buildNavbar({
    required bool compact,
  }) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(
        maxWidth: 1450,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(
                  sigmaX: 16,
                  sigmaY: 16,
                ),
                child: Container(
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFF0D1222,
                    ).withOpacity(0.85),
                    border:
                        Border.all(
                      color: Colors.white
                          .withOpacity(
                        0.08,
                      ),
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Container(
            constraints:
                const BoxConstraints(
              minHeight: 72,
            ),
            padding:
                EdgeInsets.symmetric(
              horizontal:
                  compact ? 15 : 28,
            ),
            child: Row(
              children: [
                const Text(
                  'OwlBank',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                if (!compact) ...[
                  const SizedBox(
                    width: 36,
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        _navButton(
                          Icons.home,
                          'Home',
                          '/home',
                        ),
                        _navButton(
                          Icons.person,
                          'Account',
                          '/account',
                        ),
                        _navButton(
                          Icons.swap_horiz,
                          'Transfer',
                          '/transfer',
                          active: true,
                        ),
                        _navButton(
                          Icons.description,
                          'Statements',
                          '/statements',
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Spacer(),

                  IconButton(
                    tooltip: 'Home',
                    onPressed: () {
                      Navigator
                          .pushReplacementNamed(
                        context,
                        '/home',
                      );
                    },
                    icon:
                        const Icon(
                      Icons.home,
                      color: Color(
                        0xFFC4B5FD,
                      ),
                    ),
                  ),

                  const Spacer(),
                ],

                PopupMenuButton<String>(
                  tooltip: '',
                  offset:
                      const Offset(
                    0,
                    52,
                  ),
                  color: const Color(
                    0xFF0D1222,
                  ),
                  onSelected: (value) {
                    if (value ==
                        'logout') {
                      _signOut();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Color(
                              0xFFFCA5A5,
                            ),
                          ),
                          SizedBox(
                            width: 9,
                          ),
                          Text(
                            'Sign Out',
                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFFFCA5A5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      border:
                          Border.all(
                        color: Colors
                            .white
                            .withOpacity(
                          0.13,
                        ),
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .account_circle,
                      color: Color(
                        0xFFA5ADBD,
                      ),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(
    IconData icon,
    String text,
    String route, {
    bool active = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(10),
        onTap: () {
          if (!active) {
            Navigator
                .pushReplacementNamed(
              context,
              route,
            );
          }
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: active
                ? const Color(
                    0xFF7C3AED,
                  ).withOpacity(0.18)
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: active
                    ? const Color(
                        0xFFC4B5FD,
                      )
                    : const Color(
                        0xFF969DB0,
                      ),
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                text,
                style: TextStyle(
                  color: active
                      ? const Color(
                          0xFFC4B5FD,
                        )
                      : const Color(
                          0xFF969DB0,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferActionCard
    extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const _TransferActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  State<_TransferActionCard>
      createState() =>
          _TransferActionCardState();
}

class _TransferActionCardState
    extends State<_TransferActionCard> {
  bool _hovered = false;
  Offset _position =
      Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      onHover: (event) {
        setState(() {
          _position =
              event.localPosition;
        });
      },
      child: LayoutBuilder(
        builder:
            (context, constraints) {
          final width =
              constraints.maxWidth;

          return AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 160,
            ),
            constraints:
                const BoxConstraints(
              minHeight: 330,
            ),
            transform:
                Matrix4.translationValues(
              0,
              _hovered ? -5 : 0,
              0,
            ),
            padding:
                const EdgeInsets.all(
              28,
            ),
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              border: Border.all(
                color: _hovered
                    ? const Color(
                        0xFF8B5CF6,
                      ).withOpacity(0.45)
                    : Colors.white
                        .withOpacity(
                        0.08,
                      ),
              ),
              gradient: _hovered
                  ? RadialGradient(
                      center: Alignment(
                        (_position.dx /
                                        width) *
                                    2 -
                                1,
                        (_position.dy /
                                        330) *
                                    2 -
                                1,
                      ),
                      radius: 1.4,
                      colors: [
                        const Color(
                          0xFF7C3AED,
                        ).withOpacity(
                          0.18,
                        ),
                        const Color(
                          0xFF0D1222,
                        ).withOpacity(
                          0.96,
                        ),
                      ],
                    )
                  : null,
              color: _hovered
                  ? null
                  : const Color(
                      0xFF0D1222,
                    ).withOpacity(
                      0.94,
                    ),
              boxShadow: [
                if (_hovered)
                  BoxShadow(
                    color:
                        const Color(
                          0xFF7C3AED,
                        ).withOpacity(
                          0.18,
                        ),
                    blurRadius: 35,
                    offset:
                        const Offset(
                      0,
                      15,
                    ),
                  ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                    gradient:
                        LinearGradient(
                      begin: Alignment
                          .topLeft,
                      end: Alignment
                          .bottomRight,
                      colors: [
                        const Color(
                          0xFF7C3AED,
                        ).withOpacity(
                          0.42,
                        ),
                        const Color(
                          0xFF5B21B6,
                        ).withOpacity(
                          0.18,
                        ),
                      ],
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 32,
                    color:
                        const Color(
                      0xFFC4B5FD,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                Text(
                  widget.title,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  widget.description,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color: Color(
                      0xFF858DA0,
                    ),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width:
                      double.infinity,
                  height: 48,
                  child:
                      ElevatedButton(
                    onPressed:
                        widget.onTap,
                    style:
                        ElevatedButton
                            .styleFrom(
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
                    child: Text(
                      widget
                          .buttonText,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}