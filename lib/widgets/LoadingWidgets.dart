import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:logicore/utilities/colors.dart';

class CreatePRLoadingOverlay extends StatelessWidget {
  const CreatePRLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              _buildAnimatedIcon(),
              const SizedBox(height: 24),
              // Shimmer text
              Shimmer.fromColors(
                baseColor: kColorPrimary,
                highlightColor: kColorPrimary.withValues(alpha: 0.3),
                child: const Text(
                  'Creating Purchase Request',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Loading bars animation
              _buildLoadingBars(),
              const SizedBox(height: 20),
              Text(
                'Please wait...',
                style: TextStyle(
                  fontSize: 14,
                  color: kColorGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
      onEnd: () {},
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kColorPrimary,
              kColorPrimary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kColorPrimary.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.receipt_long_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildLoadingBars() {
    return Column(
      children: [
        _buildAnimatedBar(0.8, 0),
        const SizedBox(height: 8),
        _buildAnimatedBar(0.6, 100),
        const SizedBox(height: 8),
        _buildAnimatedBar(0.9, 200),
      ],
    );
  }

  Widget _buildAnimatedBar(double widthFactor, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widthFactor),
      duration: Duration(milliseconds: 800 + delayMs),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          height: 8,
          width: 200 * value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                kColorPrimary,
                kColorPrimary.withValues(alpha: 0.4),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom Refresh Indicator with animated Logicore logo
class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: kColorPrimary,
      color: Colors.white,
      displacement: 60,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }
}

/// Animated refresh header widget
class AnimatedRefreshHeader extends StatefulWidget {
  final double progress;

  const AnimatedRefreshHeader({super.key, required this.progress});

  @override
  State<AnimatedRefreshHeader> createState() => _AnimatedRefreshHeaderState();
}

class _AnimatedRefreshHeaderState extends State<AnimatedRefreshHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kColorPrimary.withValues(alpha: 0.1),
            kColorPrimary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kColorPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sync,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Refreshing...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kColorPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
