import 'package:flutter/material.dart';

/// Mirrors Angular's `DeleteCardDialog`. Returns `true` from
/// [Navigator.pop] when the user confirms the deletion, `false`
/// (or nothing) when they cancel.
class DeleteCardDialog extends StatelessWidget {
  final String lastFourDigits;

  const DeleteCardDialog({
    super.key,
    required this.lastFourDigits,
  });

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
                  color: const Color(0xFFEF4444).withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFF87171),
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Delete card?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Are you sure you want to delete the card ending in',
                textAlign: TextAlign.center,
                style: TextStyle(
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

              const Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF87171),
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
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Delete'),
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
