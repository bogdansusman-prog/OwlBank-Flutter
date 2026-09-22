import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/statement.dart';
import '../services/auth_service.dart';
import '../services/statement_service.dart';

/// Mirrors Angular's `Statements` component
/// (`statements.ts`/`.html`/`.css`): pick a date range, generate a
/// statement, filter by transaction type, and see money-in / money-out
/// totals plus the transaction list.
class StatementsScreen extends StatefulWidget {
  const StatementsScreen({super.key});

  @override
  State<StatementsScreen> createState() => _StatementsScreenState();
}

class _StatementsScreenState extends State<StatementsScreen> {
  // Each _transactionRow is pinned to exactly this height so 4 of them
  // fill the scrollable table area precisely, with nothing cut off
  // mid-row.
  static const double _transactionRowHeight = 68;

  final StatementService _statementService = StatementService();
  final AuthService _authService = AuthService();

  late DateTime _fromDate;
  late DateTime _toDate;

  late DateTime _appliedFromDate;
  late DateTime _appliedToDate;

  String _transactionTypeFilter = 'all';

  String _statementError = '';
  bool _isStatementLoading = false;

  List<StatementTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    _fromDate = DateTime(today.year, today.month, 1);
    _toDate = DateTime(today.year, today.month, today.day);
    _appliedFromDate = _fromDate;
    _appliedToDate = _toDate;

    _generateStatement();
  }

  List<StatementTransaction> get _periodTransactions {
    if (_transactionTypeFilter == 'all') return _transactions;

    return _transactions.where((transaction) {
      switch (_transactionTypeFilter) {
        case 'deposit':
          return transaction.type == StatementTransactionType.deposit;
        case 'withdrawal':
          return transaction.type == StatementTransactionType.withdrawal;
        case 'transfer':
          return transaction.type == StatementTransactionType.transfer;
        default:
          return true;
      }
    }).toList();
  }

  double get _moneyIn {
    return _transactions
        .where((t) => t.amount > 0)
        .fold(0.0, (total, t) => total + t.amount);
  }

  double get _moneyOut {
    return _transactions
        .where((t) => t.amount < 0)
        .fold(0.0, (total, t) => total + t.amount)
        .abs();
  }

  String _dateInputValue(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _generateStatement() async {
    setState(() {
      _statementError = '';
    });

    if (_fromDate.isAfter(_toDate)) {
      setState(() {
        _statementError = 'Start date cannot be after end date.';
      });

      return;
    }

    setState(() {
      _isStatementLoading = true;
    });

    try {
      final response = await _statementService.getStatement(
        _dateInputValue(_fromDate),
        _dateInputValue(_toDate),
      );

      final transactions = response
          .map(StatementTransaction.fromResponse)
          .toList();

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _appliedFromDate = _fromDate;
        _appliedToDate = _toDate;
        _isStatementLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _statementError = 'Could not load statement.';
        _transactions = [];
        _isStatementLoading = false;
      });

      debugPrint('Statement request failed: $error');
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C3AED),
              surface: Color(0xFF0D1222),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  String _formatCurrency(double amount) {
    return NumberFormat('#,##0.00', 'en_US').format(amount);
  }

  String _formatDate(String date) {
    DateTime? parsed = DateTime.tryParse(date);

    parsed ??= DateTime.tryParse('${date}T00:00:00');

    if (parsed == null) return date;

    return DateFormat('dd MMM yyyy').format(parsed);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 650;
    final isCompactNavbar = width <= 760;
    // Angular's `.summary-grid` drops from 4 columns to 2 at 1050px,
    // well before the mobile breakpoint - a plain isMobile check left
    // 4 cramped columns all the way down to 650px.
    final isTablet = width <= 1050;

    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF060B18),
          gradient: RadialGradient(
            center: const Alignment(0, -0.9),
            radius: 0.9,
            colors: [
              const Color(0xFF7C3AED).withOpacity(0.14),
              const Color(0xFF060B18),
            ],
            stops: const [0, 0.55],
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
                _buildNavbar(isMobile: isCompactNavbar),

                SizedBox(height: isMobile ? 24 : 36),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              color: const Color(0xFF7C3AED)
                                  .withOpacity(0.16),
                            ),
                            child: const Icon(
                              Icons.description,
                              color: Color(0xFFC4B5FD),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Statements',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'View your account activity for a selected period.',
                                style: TextStyle(
                                  color: Color(0xFF9299AB),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      _buildPeriodPanel(isMobile: isMobile),

                      const SizedBox(height: 22),

                      _buildStatementCard(isMobile: isMobile, isTablet: isTablet),
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

  Widget _buildPeriodPanel({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1222).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATEMENT PERIOD',
                    style: TextStyle(
                      color: Color(0xFF858DA0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Select a date range',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.date_range, color: Color(0xFF9299AB)),
            ],
          ),

          const SizedBox(height: 18),

          isMobile
              ? Column(
                  children: [
                    _dateField(
                      label: 'From',
                      date: _fromDate,
                      onTap: () => _pickDate(isFrom: true),
                    ),
                    const SizedBox(height: 12),
                    _dateField(
                      label: 'To',
                      date: _toDate,
                      onTap: () => _pickDate(isFrom: false),
                    ),
                    const SizedBox(height: 12),
                    _generateButton(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _dateField(
                        label: 'From',
                        date: _fromDate,
                        onTap: () => _pickDate(isFrom: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dateField(
                        label: 'To',
                        date: _toDate,
                        onTap: () => _pickDate(isFrom: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _generateButton(),
                  ],
                ),

          if (_statementError.isNotEmpty) ...[
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
                    _statementError,
                    style: const TextStyle(
                      color: Color(0xFFF87171),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF858DA0),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF090E1B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF30374A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateTime(date),
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _generateButton() {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: _isStatementLoading ? null : _generateStatement,
        icon: _isStatementLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.receipt_long, size: 18),
        label: Text(_isStatementLoading ? 'Loading...' : 'Generate'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildStatementCard({required bool isMobile, required bool isTablet}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1222).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OWLBANK',
                    style: TextStyle(
                      color: Color(0xFF858DA0),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Account Statement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDateTime(_appliedFromDate)} — ${_formatDateTime(_appliedToDate)}',
                    style: const TextStyle(
                      color: Color(0xFF858DA0),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF7C3AED).withOpacity(0.16),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Color(0xFFC4B5FD),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          GridView.count(
            // Matches Angular's `.summary-grid` breakpoints: 4 columns
            // above 1050px, 2 columns from there down to mobile.
            crossAxisCount: isTablet ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isTablet ? 1.5 : 1.3,
            children: [
              _summaryCard(
                icon: Icons.account_balance_wallet,
                label: 'Opening Balance',
                value: '—',
                color: const Color(0xFF9299AB),
              ),
              _summaryCard(
                icon: Icons.south_west,
                label: 'Money In',
                value: '+${_formatCurrency(_moneyIn)} RON',
                color: const Color(0xFF4ADE80),
              ),
              _summaryCard(
                icon: Icons.north_east,
                label: 'Money Out',
                value: '-${_formatCurrency(_moneyOut)} RON',
                color: const Color(0xFFF87171),
              ),
              _summaryCard(
                icon: Icons.payments,
                label: 'Closing Balance',
                value: '—',
                color: const Color(0xFF9299AB),
              ),
            ],
          ),

          const SizedBox(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaction History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF090E1B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF30374A)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _transactionTypeFilter,
                    dropdownColor: const Color(0xFF0D1222),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    icon: const Icon(
                      Icons.filter_list,
                      size: 16,
                      color: Color(0xFF9299AB),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All transactions'),
                      ),
                      DropdownMenuItem(
                        value: 'deposit',
                        child: Text('Deposits'),
                      ),
                      DropdownMenuItem(
                        value: 'withdrawal',
                        child: Text('Withdrawals'),
                      ),
                      DropdownMenuItem(
                        value: 'transfer',
                        child: Text('Transfers'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _transactionTypeFilter = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _periodTransactions.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Color(0xFF9299AB),
                        size: 30,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'There are no transactions for this period.',
                        style: TextStyle(
                          color: Color(0xFF858DA0),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ConstrainedBox(
                  // Fixed at exactly 4 rows tall - not a rough guess -
                  // so at most 4 transactions ever show at once and
                  // the rest live behind the table's own scrollbar,
                  // while the page around it stays a single page.
                  constraints: const BoxConstraints(
                    maxHeight: _transactionRowHeight * 4,
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _periodTransactions.length,
                      itemBuilder: (context, index) =>
                          _transactionRow(_periodTransactions[index]),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF090E1B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF858DA0),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color == const Color(0xFF9299AB)
                  ? Colors.white
                  : color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionRow(StatementTransaction transaction) {
    final isIncome = transaction.amount > 0;

    String typeLabel;

    switch (transaction.type) {
      case StatementTransactionType.deposit:
        typeLabel = 'deposit';
        break;
      case StatementTransactionType.withdrawal:
        typeLabel = 'withdrawal';
        break;
      case StatementTransactionType.transfer:
        typeLabel = 'transfer';
        break;
    }

    return SizedBox(
      height: _transactionRowHeight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0x0EFFFFFF)),
          ),
        ),
        child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isIncome
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444))
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.south_west : Icons.north_east,
              size: 17,
              color: isIncome
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFFF87171),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(
                    color: Color(0xFF858DA0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              typeLabel,
              style: const TextStyle(
                color: Color(0xFF9299AB),
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${isIncome ? '+' : '-'}${_formatCurrency(transaction.amount.abs())} RON',
            style: TextStyle(
              color: isIncome
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFFF87171),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
        ),
      ),
    );
  }

  /* ================= NAVBAR (shared look) ================= */

  Widget _buildNavbar({required bool isMobile}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1450),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1222).withOpacity(0.85),
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
            constraints: const BoxConstraints(minHeight: 72),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 28),
            child: Row(
              children: [
                const Text(
                  'OwlBank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
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
                          active: true,
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
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (!active) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF7C3AED).withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: active
                    ? const Color(0xFFC4B5FD)
                    : const Color(0xFF969DB0),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: active
                      ? const Color(0xFFC4B5FD)
                      : const Color(0xFF969DB0),
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
        side: BorderSide(color: Colors.white.withOpacity(0.09)),
      ),
      onSelected: (value) {
        if (value == 'logout') _signOut();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'logout',
          height: 42,
          child: const Row(
            children: [
              Icon(Icons.logout, size: 19, color: Color(0xFFFCA5A5)),
              SizedBox(width: 9),
              Text(
                'Sign Out',
                style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 14),
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
          border: Border.all(color: Colors.white.withOpacity(0.13)),
        ),
        child: const Icon(
          Icons.account_circle,
          size: 28,
          color: Color(0xFFA5ADBD),
        ),
      ),
    );
  }
}
