import 'package:flutter/material.dart';
import 'package:logicore/utilities/colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 246, 246),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kColorPureWhite,
                boxShadow: [
                  BoxShadow(
                    color: kColorMediumGrey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                  left: 22.0, top: 20.0, bottom: 15.0, right: 22.0),
              child: const Text(
                "History",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 80,
                      color: kColorMediumGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'History Page',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kColorGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 14,
                        color: kColorMediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
