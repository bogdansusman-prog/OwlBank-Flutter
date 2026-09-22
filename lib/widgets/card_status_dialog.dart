import 'package:flutter/material.dart';

/// Mirrors Angular's `CardStatusDialog`: confirms blocking or
/// activating the selected card, depending on [isBlockAction]. Returns
/// `true` from [Navigator.pop] on confirm.
class CardStatusDialog extends StatelessWidget {
  final bool isBlockAction;
  final String lastFourDigits;

  const CardStatusDialog({
    super.key,
    required this.isBlockAction,
    required this.lastFourDigits,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isBlockAction
        ? const Color(0xFFF87171)
        : const Color(0xFF4ADE80);

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
                  color: accentColor.withOpacity(0.12),
                ),
                child: Icon(
                  isBlockAction ? Icons.block : Icons.check_circle,
                  color: accentColor,
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                isBlockAction ? 'Block card?' : 'Activate card?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Are you sure you want to ${isBlockAction ? 'block' : 'activate'} the card ending in',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9299AB),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '•••• $lastFourDigits',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isBlockAction
                    ? 'You can activate this card again later.'
                    : 'The card will become available for use again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF858DA0),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
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
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: isBlockAction
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(isBlockAction ? 'Block' : 'Activate'),
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
