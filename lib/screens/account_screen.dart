import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/card.dart';
import '../models/user_details.dart';
import '../services/auth_service.dart';
import '../services/card_service.dart';
import '../services/user_service.dart';
import '../widgets/card_status_dialog.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/delete_card_dialog.dart';
import '../widgets/reveal_card_dialog.dart';

/// Mirrors Angular's `Account` component (`account.ts`/`.html`/`.css`):
/// a two-section page (a bank-card carousel and an editable account
/// details panel), reachable at `/account`.
///
/// The Angular original drives the section switch with mouse-wheel,
/// touch-swipe and scroll-snap physics tied to the desktop web layout.
/// Here that is simplified to an explicit "Card" / "Details" toggle
/// that works identically on touch and desktop, while every backend
/// interaction (loading the profile and cards, editing fields, adding /
/// deleting / blocking / activating a card, revealing the card back)
/// is preserved.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

enum _AccountSection { card, details }

enum _EditableField { email, firstName, lastName, phoneNumber }

class _AccountScreenState extends State<AccountScreen> {
  final UserService _userService = UserService();
  final CardService _cardService = CardService();
  final AuthService _authService = AuthService();

  final PageController _cardPageController = PageController(
    viewportFraction: 0.86,
  );

  _AccountSection _activeSection = _AccountSection.card;

  UserDetails? _userDetails;
  bool _isUserDetailsLoading = true;
  String _userDetailsError = '';

  _EditableField? _editingField;
  final _editController = TextEditingController();
  bool _isSavingField = false;
  String _editFieldError = '';

  List<CardResponse> _cards = [];
  bool _isCardsLoading = true;
  String _cardsError = '';
  int _activeCardIndex = 0;
  bool _isCardFlipped = false;
  bool _isCardOptionsOpen = false;

  @override
  void initState() {
    super.initState();

    _loadUserDetails();
    _loadCards();
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    _editController.dispose();

    super.dispose();
  }

  /* ================= USER DETAILS ================= */

  Future<void> _loadUserDetails() async {
    setState(() {
      _isUserDetailsLoading = true;
      _userDetailsError = '';
    });

    try {
      final details = await _userService.getUserDetails();

      if (!mounted) return;

      setState(() {
        _userDetails = details;
        _isUserDetailsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _userDetailsError = 'Could not load account details.';
        _isUserDetailsLoading = false;
      });

      debugPrint('User details request failed: $error');
    }
  }

  /* ================= CARDS ================= */

  Future<void> _loadCards({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isCardsLoading = true;
      });
    }

    setState(() {
      _cardsError = '';
    });

    try {
      final cards = await _cardService.getAllCards();

      for (final card in cards) {
        card.cardNumber = _formatCardNumber(card.cardNumber);
        card.expirationDate = _formatExpirationDate(card.expirationDate);
      }

      if (!mounted) return;

      setState(() {
        _cards = cards;

        if (_activeCardIndex >= cards.length) {
          _activeCardIndex = 0;
        }

        _isCardsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cardsError = 'Could not load cards.';
        _isCardsLoading = false;
      });

      debugPrint('Cards request failed: $error');
    }
  }

  String _formatCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i += 4) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(
        digits.substring(i, i + 4 > digits.length ? digits.length : i + 4),
      );
    }

    return buffer.toString();
  }

  String _formatExpirationDate(String expirationDate) {
    final date = DateTime.tryParse(expirationDate);

    if (date == null) return expirationDate;

    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');

    return '$month/$year';
  }

  String _maskedNumber(String number) {
    final digits = number.replaceAll(RegExp(r'\s+'), '');
    final lastFour = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;

    return '.... .... .... $lastFour';
  }

  CardResponse? get _activeCard {
    if (_cards.isEmpty) return null;
    if (_activeCardIndex >= _cards.length) return null;

    return _cards[_activeCardIndex];
  }

  Future<void> _addNewCard() async {
    setState(() {
      _isCardOptionsOpen = false;
    });

    try {
      await _cardService.addCard();

      await _loadCards(showLoading: false);
    } catch (error) {
      debugPrint('Add card failed: $error');
    }
  }

  Future<void> _deleteCard(String cardId) async {
    try {
      await _cardService.deleteCard(cardId);

      await _loadCards(showLoading: false);
    } catch (error) {
      debugPrint('Delete card failed: $error');
    }
  }

  Future<void> _deleteSelectedCard() async {
    final card = _activeCard;

    if (card == null) return;

    setState(() {
      _isCardOptionsOpen = false;
    });

    final digits = card.cardNumber.replaceAll(RegExp(r'\s+'), '');
    final lastFour = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (_) => DeleteCardDialog(lastFourDigits: lastFour),
    );

    if (confirmed == true) {
      await _deleteCard(card.id);
    }
  }

  Future<void> _toggleSelectedCardStatus() async {
    final card = _activeCard;

    if (card == null) return;

    setState(() {
      _isCardOptionsOpen = false;
    });

    final digits = card.cardNumber.replaceAll(RegExp(r'\s+'), '');
    final lastFour = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;

    final isBlockAction = !card.isBlocked;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (_) => CardStatusDialog(
        isBlockAction: isBlockAction,
        lastFourDigits: lastFour,
      ),
    );

    if (confirmed != true) return;

    try {
      if (isBlockAction) {
        await _cardService.blockCard(card.id);
      } else {
        await _cardService.activateCard(card.id);
      }

      if (!mounted) return;

      setState(() {
        for (final c in _cards) {
          if (c.id == card.id) {
            c.isBlocked = isBlockAction;
          }
        }
      });
    } catch (error) {
      debugPrint('Card status change failed: $error');
    }
  }

  Future<void> _toggleCard() async {
    if (_isCardFlipped) {
      setState(() {
        _isCardFlipped = false;
      });

      return;
    }

    final password = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (_) => const RevealCardDialog(),
    );

    if (password == null || password.isEmpty) return;

    // Password verification against the backend is not wired up yet,
    // mirroring the Angular original's TODO in `toggleCard()`.
    if (!mounted) return;

    setState(() {
      _isCardFlipped = true;
    });
  }

  void _goToCard(int index) {
    if (index < 0 || index >= _cards.length) return;

    setState(() {
      _isCardFlipped = false;
      _activeCardIndex = index;
    });

    _cardPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  /* ================= EDITABLE FIELDS ================= */

  String _fieldKey(_EditableField field) {
    switch (field) {
      case _EditableField.email:
        return 'email';
      case _EditableField.firstName:
        return 'firstName';
      case _EditableField.lastName:
        return 'lastName';
      case _EditableField.phoneNumber:
        return 'phoneNumber';
    }
  }

  String _fieldLabel(_EditableField field) {
    switch (field) {
      case _EditableField.email:
        return 'Email';
      case _EditableField.firstName:
        return 'First Name';
      case _EditableField.lastName:
        return 'Last Name';
      case _EditableField.phoneNumber:
        return 'Phone Number';
    }
  }

  void _startEditing(_EditableField field) {
    if (_userDetails == null || _isSavingField) return;

    setState(() {
      _editingField = field;
      _editController.text = _userDetails!.fieldValue(_fieldKey(field));
      _editFieldError = '';
    });
  }

  void _cancelEditing() {
    if (_isSavingField) return;

    setState(() {
      _editingField = null;
      _editController.clear();
      _editFieldError = '';
    });
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  bool _isValidPhoneNumber(String value) {
    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(value);
  }

  Future<void> _saveEditing(_EditableField field) async {
    if (_userDetails == null ||
        _editingField != field ||
        _isSavingField) {
      return;
    }

    final value = _editController.text.trim();

    if (value.isEmpty) {
      setState(() {
        _editFieldError = 'This field cannot be empty.';
      });

      return;
    }

    if (field == _EditableField.email && !_isValidEmail(value)) {
      setState(() {
        _editFieldError = 'Please enter a valid email address.';
      });

      return;
    }

    if (field == _EditableField.phoneNumber &&
        !_isValidPhoneNumber(value)) {
      setState(() {
        _editFieldError = 'Please enter a valid phone number.';
      });

      return;
    }

    if (value == _userDetails!.fieldValue(_fieldKey(field))) {
      _cancelEditing();
      return;
    }

    setState(() {
      _isSavingField = true;
      _editFieldError = '';
    });

    try {
      switch (field) {
        case _EditableField.email:
          await _userService.updateUserDetails(email: value);
          break;
        case _EditableField.firstName:
          await _userService.updateUserDetails(firstName: value);
          break;
        case _EditableField.lastName:
          await _userService.updateUserDetails(lastName: value);
          break;
        case _EditableField.phoneNumber:
          await _userService.updateUserDetails(phoneNumber: value);
          break;
      }

      if (!mounted) return;

      setState(() {
        switch (field) {
          case _EditableField.email:
            _userDetails = _userDetails!.copyWith(email: value);
            break;
          case _EditableField.firstName:
            _userDetails = _userDetails!.copyWith(firstName: value);
            break;
          case _EditableField.lastName:
            _userDetails = _userDetails!.copyWith(lastName: value);
            break;
          case _EditableField.phoneNumber:
            _userDetails = _userDetails!.copyWith(phoneNumber: value);
            break;
        }

        _editingField = null;
        _editController.clear();
        _isSavingField = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSavingField = false;
        _editFieldError = 'Could not update this field.';
      });

      debugPrint('User details update failed: $error');
    }
  }

  String _formatDateOfBirth(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) return '—';

    final datePart = dateOfBirth.length >= 10
        ? dateOfBirth.substring(0, 10)
        : dateOfBirth;

    final parts = datePart.split('-');

    if (parts.length != 3) return dateOfBirth;

    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  /* ================= PROFILE / SIGN OUT ================= */

  Future<void> _signOut() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  void _openChangePasswordDialog() {
    final details = _userDetails;

    if (details == null) return;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (_) => ChangePasswordDialog(email: details.email),
    );
  }

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 650;
    final isCompactNavbar = width <= 760;

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
                  child: _buildSectionToggle(),
                ),

                const SizedBox(height: 22),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: _activeSection == _AccountSection.card
                      ? _buildCardSection(isMobile: isMobile)
                      : _buildDetailsSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1222).withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton(
              icon: Icons.credit_card,
              label: 'Card',
              active: _activeSection == _AccountSection.card,
              onTap: () {
                setState(() => _activeSection = _AccountSection.card);
              },
            ),
          ),
          Expanded(
            child: _toggleButton(
              icon: Icons.person,
              label: 'Account Details',
              active: _activeSection == _AccountSection.details,
              onTap: () {
                setState(() => _activeSection = _AccountSection.details);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF7C3AED).withOpacity(0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active
                  ? const Color(0xFFC4B5FD)
                  : const Color(0xFF969DB0),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? const Color(0xFFC4B5FD)
                    : const Color(0xFF969DB0),
                fontWeight: FontWeight.w600,
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
                          active: true,
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

  /* ================= CARD SECTION ================= */

  Widget _buildCardSection({required bool isMobile}) {
    if (_isCardsLoading) {
      return _statusPanel(
        icon: Icons.sync,
        text: 'Loading cards...',
      );
    }

    if (_cardsError.isNotEmpty) {
      return _statusPanel(
        icon: Icons.error_outline,
        text: _cardsError,
        color: const Color(0xFFF87171),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _buildCardOptions(),
        ),

        const SizedBox(height: 6),

        if (_cards.isEmpty)
          _statusPanel(
            icon: Icons.credit_card_off,
            text: 'No cards yet. Add one to get started.',
          )
        else ...[
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _cardPageController,
              itemCount: _cards.length,
              onPageChanged: (index) {
                setState(() {
                  _activeCardIndex = index;
                  _isCardFlipped = false;
                });
              },
              itemBuilder: (context, index) {
                final card = _cards[index];
                final isActive = index == _activeCardIndex;

                return AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  scale: isActive ? 1.0 : 0.9,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: isActive ? 1.0 : 0.55,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () => _goToCard(index),
                        child: _TiltCard(
                          enabled: isActive && !_isCardFlipped,
                          child: _BankCard(
                            card: card,
                            isFlipped: isActive && _isCardFlipped,
                            maskedNumber: _maskedNumber(card.cardNumber),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          if (_activeCard != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _activeCard!.isBlocked
                    ? const Color(0xFFF87171).withOpacity(0.12)
                    : const Color(0xFF4ADE80).withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _activeCard!.isBlocked
                      ? const Color(0xFFF87171).withOpacity(0.4)
                      : const Color(0xFF4ADE80).withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _activeCard!.isBlocked
                          ? const Color(0xFFF87171)
                          : const Color(0xFF4ADE80),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _activeCard!.isBlocked ? 'Blocked' : 'Active',
                    style: TextStyle(
                      color: _activeCard!.isBlocked
                          ? const Color(0xFFF87171)
                          : const Color(0xFF4ADE80),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _toggleCard,
                icon: Icon(
                  _isCardFlipped
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFFC4B5FD),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1222),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _activeCardIndex == 0
                    ? null
                    : () => _goToCard(_activeCardIndex - 1),
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFFC4B5FD),
                disabledColor: const Color(0xFF3A4157),
              ),
              const SizedBox(width: 6),
              Row(
                children: List.generate(_cards.length, (index) {
                  final active = index == _activeCardIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF8B5CF6)
                          : Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: _activeCardIndex >= _cards.length - 1
                    ? null
                    : () => _goToCard(_activeCardIndex + 1),
                icon: const Icon(Icons.arrow_forward),
                color: const Color(0xFFC4B5FD),
                disabledColor: const Color(0xFF3A4157),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCardOptions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isCardOptionsOpen && _activeCard != null) ...[
          _cardOptionButton(
            icon: _activeCard!.isBlocked ? Icons.check : Icons.block,
            color: _activeCard!.isBlocked
                ? const Color(0xFF4ADE80)
                : const Color(0xFFF87171),
            onTap: _toggleSelectedCardStatus,
          ),
          const SizedBox(width: 8),
          _cardOptionButton(
            icon: Icons.delete,
            color: const Color(0xFFF87171),
            onTap: _deleteSelectedCard,
          ),
          const SizedBox(width: 8),
        ],
        if (_isCardOptionsOpen) ...[
          _cardOptionButton(
            icon: Icons.add,
            color: const Color(0xFFC4B5FD),
            onTap: _addNewCard,
          ),
          const SizedBox(width: 8),
        ],
        _cardOptionButton(
          icon: _isCardOptionsOpen ? Icons.close : Icons.more_vert,
          color: const Color(0xFFC4B5FD),
          onTap: () {
            setState(() {
              _isCardOptionsOpen = !_isCardOptionsOpen;
            });
          },
        ),
      ],
    );
  }

  Widget _cardOptionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF0D1222),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        minimumSize: const Size(38, 38),
      ),
    );
  }

  Widget _statusPanel({
    required IconData icon,
    required String text,
    Color color = const Color(0xFF9299AB),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1222).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  /* ================= DETAILS SECTION ================= */

  Widget _buildDetailsSection() {
    if (_isUserDetailsLoading) {
      return _statusPanel(icon: Icons.sync, text: 'Loading account details...');
    }

    if (_userDetailsError.isNotEmpty) {
      return _statusPanel(
        icon: Icons.error_outline,
        text: _userDetailsError,
        color: const Color(0xFFF87171),
      );
    }

    final details = _userDetails;

    if (details == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1222).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF7C3AED).withOpacity(0.16),
                ),
                child: const Icon(Icons.person, color: Color(0xFFC4B5FD)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your personal account information',
                      style: TextStyle(
                        color: Color(0xFF858DA0),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _editableDetailRow(_EditableField.email, details.email),
          _divider(),
          _editableDetailRow(_EditableField.firstName, details.firstName),
          _divider(),
          _editableDetailRow(_EditableField.lastName, details.lastName),
          _divider(),
          _editableDetailRow(
            _EditableField.phoneNumber,
            details.phoneNumber,
          ),
          _divider(),

          _staticDetailRow(
            'Date of Birth',
            _formatDateOfBirth(details.dateOfBirth),
          ),
          _divider(),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          color: Color(0xFF858DA0),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '••••••••••••',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _openChangePasswordDialog,
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Color(0xFF9299AB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.white.withOpacity(0.07), height: 1);
  }

  Widget _staticDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF858DA0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _editableDetailRow(_EditableField field, String value) {
    final isEditing = _editingField == field;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fieldLabel(field).toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF858DA0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          if (!isEditing)
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _startEditing(field),
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Color(0xFF9299AB),
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _editController,
                    enabled: !_isSavingField,
                    autofocus: true,
                    onSubmitted: (_) => _saveEditing(field),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFF090E1B),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF30374A),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed:
                      _isSavingField ? null : () => _saveEditing(field),
                  icon: const Icon(
                    Icons.check,
                    color: Color(0xFF4ADE80),
                  ),
                ),
                IconButton(
                  onPressed: _isSavingField ? null : _cancelEditing,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFF87171),
                  ),
                ),
              ],
            ),
            if (_editFieldError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _editFieldError,
                  style: const TextStyle(
                    color: Color(0xFFF87171),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// The flippable bank card visual: front shows the masked number and
/// holder/expiry, back shows the full number/expiry/CVV. Mirrors the
/// gradient values from Angular's `account.css` (`.bank-card-front` /
/// `.bank-card-back`).
class _BankCard extends StatelessWidget {
  final CardResponse card;
  final bool isFlipped;
  final String maskedNumber;

  const _BankCard({
    required this.card,
    required this.isFlipped,
    required this.maskedNumber,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isFlipped ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      builder: (context, value, _) {
        final angle = value * 3.14159265;
        final showBack = value > 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(3.14159265),
                  child: _cardBack(),
                )
              : _cardFront(),
        );
      },
    );
  }

  BoxDecoration _cardDecoration(List<Color> colors) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 30,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }

  Widget _cardFront() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(const [
        Color(0xFF21183F),
        Color(0xFF12152D),
        Color(0xFF25184A),
        Color(0xFF151127),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'OwlBank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.white.withOpacity(0.35),
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: 42,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [Color(0xFFE0C88A), Color(0xFFBFA05E)],
              ),
            ),
          ),

          const Spacer(),

          Text(
            maskedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CARD HOLDER',
                      style: TextStyle(
                        color: Color(0xFF9299AB),
                        fontSize: 9,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${card.firstName} ${card.lastName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Color(0xFF9299AB),
                      fontSize: 9,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.expirationDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBack() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(const [
        Color(0xFF0C1023),
        Color(0xFF18102F),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Card Number',
            style: TextStyle(
              color: Color(0xFF9299AB),
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expiry Date',
                      style: TextStyle(
                        color: Color(0xFF9299AB),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.expirationDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CVV',
                    style: TextStyle(
                      color: Color(0xFF9299AB),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.cvv,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'OwlBank',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The pointer-driven "3D" physics wrapper around the card, mirroring
/// Angular's `.bank-card-hover` handlers (`onCardPointerDown/Move/Up/
/// Leave/Cancel` + `applyCardTilt` / `triggerTurbulence` in
/// `account.ts`):
///
/// - Mouse: the card tilts continuously to follow the cursor while it
///   hovers over the card (no need to click/drag), and a click gives a
///   quick "turbulence" pulse.
/// - Touch: holding a finger on the card for ~250ms and dragging tilts
///   it toward the touch point; a quick tap (released before the hold
///   fires) triggers the turbulence pulse instead.
///
/// The tilt strength follows the same math as the original: a small
/// dead zone near the center, an eased falloff (`strength^0.72`) out to
/// the edges, an 11° max tilt, and a light "glare" that moves opposite
/// the tilt direction.
class _TiltCard extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const _TiltCard({
    required this.enabled,
    required this.child,
  });

  @override
  State<_TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<_TiltCard>
    with SingleTickerProviderStateMixin {
  static const double _maxTiltDeg = 11;
  static const double _deadZone = 0.05;

  double _tiltXDeg = 0;
  double _tiltYDeg = 0;
  double _lightX = 50;
  double _lightY = 50;
  double _lightingOpacity = 0;

  Timer? _holdTimer;
  bool _touchHoldActive = false;
  int? _activePointer;

  late final AnimationController _turbulenceController;

  @override
  void initState() {
    super.initState();

    _turbulenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant _TiltCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled && oldWidget.enabled) {
      _holdTimer?.cancel();
      _touchHoldActive = false;
      _activePointer = null;
      _resetTilt();
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _turbulenceController.dispose();

    super.dispose();
  }

  void _applyTilt(Offset localPosition, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final rawX = (localPosition.dx - centerX) / centerX;
    final rawY = (localPosition.dy - centerY) / centerY;

    final distance = math.sqrt(rawX * rawX + rawY * rawY);

    double rotateX = 0;
    double rotateY = 0;
    double lightX = 50;
    double lightY = 50;
    double lightingOpacity = 0;

    if (distance > _deadZone) {
      final directionX = rawX / distance;
      final directionY = rawY / distance;

      double strength =
          (math.min(distance, 1) - _deadZone) / (1 - _deadZone);
      strength = strength.clamp(0, 1);
      strength = math.pow(strength, 0.72).toDouble();

      rotateX = -directionY * _maxTiltDeg * strength;
      rotateY = directionX * _maxTiltDeg * strength;

      final normalizedTiltX = rotateX / _maxTiltDeg;
      final normalizedTiltY = rotateY / _maxTiltDeg;

      lightX = 50 - normalizedTiltY * 45;
      lightY = 50 + normalizedTiltX * 45;
      lightingOpacity = 0.18 + strength * 0.68;
    }

    setState(() {
      _tiltXDeg = rotateX;
      _tiltYDeg = rotateY;
      _lightX = lightX;
      _lightY = lightY;
      _lightingOpacity = lightingOpacity;
    });
  }

  void _resetTilt() {
    if (!mounted) return;

    setState(() {
      _tiltXDeg = 0;
      _tiltYDeg = 0;
      _lightX = 50;
      _lightY = 50;
      _lightingOpacity = 0;
    });
  }

  void _triggerTurbulence() {
    _turbulenceController.forward(from: 0);
  }

  void _onPointerHover(PointerEvent event) {
    if (!widget.enabled) return;
    if (event.kind != PointerDeviceKind.mouse) return;

    _applyTilt(event.localPosition, context.size ?? Size.zero);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled) return;

    if (event.kind == PointerDeviceKind.mouse) {
      _triggerTurbulence();
      return;
    }

    _activePointer = event.pointer;
    _touchHoldActive = false;

    final size = context.size ?? Size.zero;
    final position = event.localPosition;

    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;

      _touchHoldActive = true;
      _applyTilt(position, size);
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!widget.enabled) return;

    if (event.kind == PointerDeviceKind.mouse) {
      _applyTilt(event.localPosition, context.size ?? Size.zero);
      return;
    }

    if (_touchHoldActive && event.pointer == _activePointer) {
      _applyTilt(event.localPosition, context.size ?? Size.zero);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.kind == PointerDeviceKind.mouse) return;
    if (event.pointer != _activePointer) return;

    _holdTimer?.cancel();

    if (!_touchHoldActive) {
      _triggerTurbulence();
    }

    _resetTilt();
    _touchHoldActive = false;
    _activePointer = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _holdTimer?.cancel();
    _touchHoldActive = false;
    _activePointer = null;

    _resetTilt();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _turbulenceController,
      builder: (context, child) {
        final pulse =
            1 + math.sin(_turbulenceController.value * math.pi) * 0.035;

        return Transform.scale(scale: pulse, child: child);
      },
      child: MouseRegion(
        onExit: (_) => _resetTilt(),
        child: Listener(
          onPointerHover: _onPointerHover,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..rotateX(_tiltXDeg * math.pi / 180)
              ..rotateY(_tiltYDeg * math.pi / 180),
            child: Stack(
              children: [
                widget.child,
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          center: Alignment(
                            (_lightX / 100) * 2 - 1,
                            (_lightY / 100) * 2 - 1,
                          ),
                          radius: 1.15,
                          colors: [
                            Colors.white.withOpacity(
                              0.30 * _lightingOpacity,
                            ),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
