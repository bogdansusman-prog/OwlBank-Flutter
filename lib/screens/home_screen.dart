import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
    final ScrollController _transactionsScrollController = ScrollController();
  double _balance = 0;
  bool _isBalanceLoading = true;
  String _balanceError = '';

  final List<HomeTransaction> _transactions = const [
    HomeTransaction(
      id: '1',
      type: HomeTransactionType.deposit,
      description: 'Salary',
      amount: 5000,
      date: '26 Aug 2026',
    ),
    HomeTransaction(
      id: '2',
      type: HomeTransactionType.withdrawal,
      description: 'Shopping',
      amount: -250,
      date: '25 Aug 2026',
    ),
    HomeTransaction(
      id: '3',
      type: HomeTransactionType.transfer,
      description: 'Transfer to 0722123456',
      amount: -500,
      date: '24 Aug 2026',
    ),
    HomeTransaction(
      id: '4',
      type: HomeTransactionType.deposit,
      description: 'Freelance',
      amount: 1200,
      date: '23 Aug 2026',
    ),
    HomeTransaction(
      id: '5',
      type: HomeTransactionType.withdrawal,
      description: 'ATM Withdrawal',
      amount: -100,
      date: '22 Aug 2026',
    ),
    HomeTransaction(
      id: '6',
      type: HomeTransactionType.transfer,
      description: 'Transfer to 0744556677',
      amount: -350,
      date: '21 Aug 2026',
    ),
    HomeTransaction(
      id: '7',
      type: HomeTransactionType.deposit,
      description: 'Refund',
      amount: 180,
      date: '20 Aug 2026',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _initializeHome();
  }

  @override
    void dispose() {
        _transactionsScrollController.dispose();
        super.dispose();
    }

  Future<void> _initializeHome() async {
    final token = await _authService.getToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );

      return;
    }

    await _loadBalance();
  }

  Future<void> _loadBalance() async {
    _balanceError = '';

    try {
      final balance =
          await _userService.getBalance();

      if (!mounted) return;

      setState(() {
        _balance = balance;
        _isBalanceLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isBalanceLoading = false;
        _balanceError =
            'Could not load balance.';
      });

      debugPrint(
        'Balance request failed: $error',
      );
    }
  }

  Future<void> _signOut() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    final isMobile = width <= 650;
final isCompactNavbar = width <= 760;
final isTablet = width <= 900;

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
          color: const Color(0xFF060B18),
          gradient: RadialGradient(
            center: const Alignment(0, -0.9),
            radius: 0.9,
            colors: [
              const Color(0xFF7C3AED)
                  .withOpacity(0.14),
              const Color(0xFF060B18),
            ],
            stops: const [
              0,
              0.55,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 24,
              isMobile ? 12 : 18,
              isMobile ? 12 : 24,
              40,
            ),
            child: Column(
              children: [
                _buildNavbar(
                  isMobile: isCompactNavbar,
                ),

                SizedBox(
                  height: isMobile ? 28 : 42,
                ),

                ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  child: Column(
                    children: [
                      _buildBalanceSection(
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),

                      const SizedBox(height: 34),

                      _buildTransactionsCard(
                        isMobile: isMobile,
                        
        ),
                      if (isMobile) ...[
                        const SizedBox(
                          height: 20,
                        ),
                        _buildQuickActions(),
                      ],
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

  Widget _buildNavbar({
  required bool isMobile,
}) {
  return ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: 1450,
    ),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 16,
                sigmaY: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1222)
                      .withOpacity(0.85),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 35,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 72,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 15 : 28,
          ),
          child: Row(
            children: [
              Text(
                'OwlBank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 19 : 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),

              if (!isMobile) ...[
                const SizedBox(width: 36),

                Expanded(
                  child: Row(
                    children: [
                      _navButton(
                        icon: Icons.home,
                        text: 'Home',
                        route: '/home',
                        active: true,
                      ),
                      _navButton(
                        icon: Icons.person,
                        text: 'Account',
                        route: '/account',
                      ),
                      _navButton(
                        icon: Icons.swap_horiz,
                        text: 'Transfer',
                        route: '/transfer',
                      ),
                      _navButton(
                        icon: Icons.description,
                        text: 'Statements',
                        route: '/statements',
                      ),
                    ],
                  ),
                ),
              ] else
                const Spacer(),

              _buildProfileMenu(),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _navButton({
    required IconData icon,
    required String text,
    required String route,
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
            Navigator.pushReplacementNamed(
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
                ? const Color(0xFF7C3AED)
                    .withOpacity(0.18)
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(10),
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

              const SizedBox(width: 8),

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

  Widget _buildProfileMenu() {
  return PopupMenuButton<String>(
    tooltip: '',
    offset: const Offset(0, 52),
    color: const Color(0xFF0D1222),
    elevation: 18,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: Colors.white.withOpacity(0.09),
      ),
    ),
    onSelected: (value) {
      if (value == 'logout') {
        _signOut();
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem<String>(
        value: 'logout',
        height: 42,
        child: const Row(
          children: [
            Icon(
              Icons.logout,
              size: 19,
              color: Color(0xFFFCA5A5),
            ),
            SizedBox(width: 9),
            Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ],
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.02),
        border: Border.all(
          color: Colors.white.withOpacity(0.13),
        ),
      ),
      child: const Icon(
        Icons.account_circle,
        size: 28,
        color: Color(0xFFA5ADBD),
      ),
    ),
  );
}

  Widget _buildBalanceSection({
    required bool isMobile,
    required bool isTablet,
  }) {
    if (isMobile) {
      return Column(
        children: [
          Image.asset(
            'assets/images/owlbank-logo.png',
            width: 95,
          ),

          const SizedBox(height: 12),

          _buildBalanceCard(),
        ],
      );
    }

    final logoWidth =
        isTablet ? 95.0 : 210.0;

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        SizedBox(
          width: isTablet ? 100 : 230,
          child: Center(
            child: Image.asset(
              'assets/images/owlbank-logo.png',
              width: logoWidth,
            ),
          ),
        ),

        SizedBox(
          width:
              isTablet ? 20 : 40,
        ),

        Flexible(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              minWidth: 320,
              maxWidth: 660,
            ),
            child: _buildBalanceCard(),
          ),
        ),

        SizedBox(
          width:
              isTablet ? 20 : 40,
        ),

        SizedBox(
          width: isTablet ? 100 : 230,
          child: Center(
            child: Image.asset(
              'assets/images/owlbank-logo.png',
              width: logoWidth,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    String displayValue;

    if (_isBalanceLoading) {
      displayValue = '...';
    } else if (_balanceError.isNotEmpty) {
      displayValue = '--';
    } else {
      displayValue =
          '\$${_formatNumber(_balance)}';
    }

    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color:
            const Color(0xFF11172B)
                .withOpacity(0.9),
        borderRadius:
            BorderRadius.circular(999),
        border: Border.all(
          color: const Color(
            0xFF8B5CF6,
          ).withOpacity(0.22),
        ),
        gradient: RadialGradient(
          colors: [
            const Color(0xFF7C3AED)
                .withOpacity(0.16),
            const Color(0xFF11172B)
                .withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF7C3AED)
                    .withOpacity(0.10),
            blurRadius: 35,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(
                  color:
                      Color(0xFF9299AB),
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                displayValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight:
                      FontWeight.w600,
                  height: 1,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 12,
            child: Container(
              width: 130,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF8B5CF6,
                ),
                borderRadius:
                    BorderRadius.circular(
                  999,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(
                          0xFF8B5CF6,
                        ).withOpacity(
                          0.8,
                        ),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard({
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal:
            isMobile ? 16 : 25,
        vertical:
            isMobile ? 20 : 25,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFF0D1222)
                .withOpacity(0.90),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              Colors.white.withOpacity(
            0.08,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.22,
            ),
            blurRadius: 40,
            offset:
                const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      isMobile ? 18 : 20,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const Spacer(),

              InkWell(
                onTap: () {
                  Navigator
                      .pushReplacementNamed(
                    context,
                    '/statements',
                  );
                },
                child: const Padding(
                  padding:
                      EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          color: Color(
                            0xFFA78BFA,
                          ),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(
                          0xFFA78BFA,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            height: 380,
            decoration:
                const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color:
                      Color(0x12FFFFFF),
                ),
              ),
            ),
            child: _transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions yet.',
                      style: TextStyle(
                        color: Color(
                          0xFF7F879B,
                        ),
                      ),
                    ),
                  )
                : ScrollConfiguration(
  behavior: const MaterialScrollBehavior().copyWith(
    dragDevices: {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.trackpad,
    },
    scrollbars: false,
  ),
  child: RawScrollbar(
    controller: _transactionsScrollController,
    thumbVisibility: true,
    trackVisibility: false,
    interactive: true,
    thickness: 6,
    radius: const Radius.circular(999),
    thumbColor: const Color(0xFF8B5CF6).withOpacity(0.55),
    child: Padding(
      padding: const EdgeInsets.only(
        right: 20,
      ),
      child: ListView.builder(
        controller: _transactionsScrollController,
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        padding: EdgeInsets.zero,
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          return _transactionRow(
            _transactions[index],
          );
        },
      ),
    ),
  ),
),
          ),
        ],
      ),
    );
  }

  Widget _transactionRow(
    HomeTransaction transaction,
  ) {
    final isMoneyIn =
        transaction.amount > 0;

    IconData icon;
    Color color;
    Color background;

    switch (transaction.type) {
      case HomeTransactionType.deposit:
        icon = Icons.south;
        color =
            const Color(0xFF4ADE80);
        background =
            const Color(0xFF22C55E)
                .withOpacity(0.08);
        break;

      case HomeTransactionType.withdrawal:
        icon = Icons.north;
        color =
            const Color(0xFFF87171);
        background =
            const Color(0xFFEF4444)
                .withOpacity(0.08);
        break;

      case HomeTransactionType.transfer:
        icon = Icons.swap_horiz;
        color =
            const Color(0xFFC4B5FD);
        background =
            const Color(0xFF7C3AED)
                .withOpacity(0.12);
        break;
    }

    String title;

    switch (transaction.type) {
      case HomeTransactionType.deposit:
        title = 'Deposit';
        break;
      case HomeTransactionType.withdrawal:
        title = 'Withdrawal';
        break;
      case HomeTransactionType.transfer:
        title = 'Transfer';
        break;
    }

    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 76,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration:
          const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0x0EFFFFFF),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: background,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color:
                    color.withOpacity(
                  0.18,
                ),
              ),
            ),
            child: Icon(
              icon,
              size: 21,
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF858DA0),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          SizedBox(
            width: 135,
            child: Text(
              transaction.date,
              textAlign:
                  TextAlign.right,
              style: const TextStyle(
                color:
                    Color(0xFF858DA0),
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(width: 14),

          SizedBox(
            width: 120,
            child: Text(
              '${isMoneyIn ? '+' : '-'}\$${_formatNumber(transaction.amount.abs())}',
              textAlign:
                  TextAlign.right,
              style: TextStyle(
                color: isMoneyIn
                    ? const Color(
                        0xFF4ADE80,
                      )
                    : const Color(
                        0xFFF87171,
                      ),
                fontSize: 15,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _quickAction(
          icon: Icons.swap_horiz,
          title: 'Transfer Money',
          subtitle:
              'Send money to anyone',
          route: '/transfer',
        ),

        const SizedBox(height: 16),

        _quickAction(
          icon: Icons.person,
          title: 'My Account',
          subtitle:
              'View and manage account',
          route: '/account',
        ),

        const SizedBox(height: 16),

        _quickAction(
          icon: Icons.description,
          title: 'Statements',
          subtitle:
              'View your statements',
          route: '/statements',
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(16),
      onTap: () {
        Navigator.pushReplacementNamed(
          context,
          route,
        );
      },
      child: Container(
        width: double.infinity,
        constraints:
            const BoxConstraints(
          minHeight: 105,
        ),
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              const Color(0xFF0D1222)
                  .withOpacity(0.9),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color:
                Colors.white.withOpacity(
              0.08,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
                  colors: [
                    const Color(
                      0xFF7C3AED,
                    ).withOpacity(0.4),
                    const Color(
                      0xFF5B21B6,
                    ).withOpacity(0.22),
                  ],
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: const Color(
                  0xFFC4B5FD,
                ),
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      color: Color(
                        0xFF858DA0,
                      ),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}