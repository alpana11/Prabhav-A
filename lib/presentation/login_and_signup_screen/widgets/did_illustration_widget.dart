import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DIDIllustrationWidget extends StatefulWidget {
  final double? size;
  final bool animate;

  const DIDIllustrationWidget({
    super.key,
    this.size,
    this.animate = true,
  });

  @override
  State<DIDIllustrationWidget> createState() => _DIDIllustrationWidgetState();
}

class _DIDIllustrationWidgetState extends State<DIDIllustrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 24.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main illustration container
          AnimatedBuilder(
            animation: widget.animate
                ? _pulseAnimation
                : const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: widget.animate ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.lightTheme.colorScheme.primary,
                        AppTheme.lightTheme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(size * 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shield icon representing security
                      Positioned(
                        top: size * 0.15,
                        left: size * 0.15,
                        child: Container(
                          width: size * 0.35,
                          height: size * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(size * 0.05),
                          ),
                          child: Icon(
                            Icons.security,
                            color: Colors.white,
                            size: size * 0.2,
                          ),
                        ),
                      ),

                      // Digital chain/blockchain representation
                      Positioned(
                        bottom: size * 0.15,
                        right: size * 0.15,
                        child: Container(
                          width: size * 0.4,
                          height: size * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(size * 0.05),
                          ),
                          child: Icon(
                            Icons.link,
                            color: Colors.white,
                            size: size * 0.2,
                          ),
                        ),
                      ),

                      // Central verification checkmark
                      Center(
                        child: Container(
                          width: size * 0.3,
                          height: size * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.verified,
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: size * 0.18,
                          ),
                        ),
                      ),

                      // Floating particles for digital effect
                      ...List.generate(3, (index) {
                        return Positioned(
                          top: size * (0.2 + index * 0.2),
                          left: size * (0.1 + index * 0.3),
                          child: Container(
                            width: size * 0.08,
                            height: size * 0.08,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

