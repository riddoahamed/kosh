import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricAuthWidget extends StatefulWidget {
  final VoidCallback onBiometricSuccess;
  final bool isVisible;

  const BiometricAuthWidget({
    Key? key,
    required this.onBiometricSuccess,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isBiometricAvailable = false;
  String _biometricType = 'fingerprint';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _checkBiometricAvailability();
    if (widget.isVisible) {
      _startPulseAnimation();
    }
  }

  @override
  void didUpdateWidget(BiometricAuthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startPulseAnimation();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startPulseAnimation() {
    _animationController.repeat(reverse: true);
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Simulate biometric availability check
      // In real implementation, use local_auth package
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isBiometricAvailable = true;
          // Simulate different biometric types based on platform
          _biometricType = Theme.of(context).platform == TargetPlatform.iOS
              ? 'face'
              : 'fingerprint';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      HapticFeedback.lightImpact();

      // Simulate biometric authentication
      // In real implementation, use local_auth package
      await Future.delayed(const Duration(milliseconds: 1500));

      // Simulate successful authentication
      if (mounted) {
        HapticFeedback.heavyImpact();
        widget.onBiometricSuccess();
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String get _biometricIcon {
    switch (_biometricType) {
      case 'face':
        return 'face';
      case 'fingerprint':
      default:
        return 'fingerprint';
    }
  }

  String get _biometricLabel {
    switch (_biometricType) {
      case 'face':
        return 'Use Face ID';
      case 'fingerprint':
      default:
        return 'Use Fingerprint';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || !_isBiometricAvailable) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            child: Column(
              children: [
                // Divider with "OR" text
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'OR',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Biometric Authentication Button
                InkWell(
                  onTap: _authenticateWithBiometrics,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _biometricIcon,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 8.w,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 1.h),

                // Biometric Label
                Text(
                  _biometricLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}