import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OtpVerificationWidget extends StatefulWidget {
  final String phoneNumber;
  final Function(String) onOtpVerified;
  final VoidCallback onResendOtp;
  final bool isLoading;

  const OtpVerificationWidget({
    Key? key,
    required this.phoneNumber,
    required this.onOtpVerified,
    required this.onResendOtp,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;

  int _resendTimer = 60;
  bool _canResend = false;
  String _currentOtp = '';

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    );
    _timerAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_timerController);

    _startResendTimer();

    // Add listeners to OTP controllers
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() => _onOtpChanged(i));
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timerController.reset();
    _timerController.forward();

    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    // Update timer every second
    _timerController.addListener(() {
      if (mounted) {
        setState(() {
          _resendTimer = (60 * (1 - _timerController.value)).round();
          if (_resendTimer <= 0) {
            _canResend = true;
          }
        });
      }
    });
  }

  void _onOtpChanged(int index) {
    final value = _otpControllers[index].text;

    if (value.isNotEmpty) {
      // Move to next field
      if (index < _otpControllers.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    // Update current OTP
    _currentOtp = _otpControllers.map((controller) => controller.text).join();

    // Auto-verify when all digits are entered
    if (_currentOtp.length == 6) {
      widget.onOtpVerified(_currentOtp);
    }
  }

  void _onBackspace(int index) {
    if (_otpControllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _otpControllers[index - 1].clear();
    }
  }

  void _resendOtp() {
    if (_canResend) {
      widget.onResendOtp();
      _startResendTimer();

      // Clear all OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  String _formatPhoneNumber(String phone) {
    // Format Bangladesh phone number for display
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('880')) {
      return '+880 ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    } else if (cleanPhone.startsWith('0')) {
      return '+880 ${cleanPhone.substring(1, 4)} ${cleanPhone.substring(4)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'sms',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Title and Description
          Text(
            'Verify Your Phone',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              children: [
                TextSpan(text: 'We sent a 6-digit code to\n'),
                TextSpan(
                  text: _formatPhoneNumber(widget.phoneNumber),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // OTP Input Fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildOtpField(index)),
          ),
          SizedBox(height: 4.h),

          // Auto-detection hint with demo code
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Demo code: 123456',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'SMS will be auto-detected and filled automatically',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // Resend Timer and Button
          AnimatedBuilder(
            animation: _timerAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  if (!_canResend) ...[
                    // Timer Progress
                    Container(
                      width: 60.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _timerAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Resend code in ${_resendTimer}s',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    // Resend Button
                    TextButton.icon(
                      onPressed: _resendOtp,
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        'Resend Code',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: 4.h),

          // Manual Verify Button (if needed)
          if (_currentOtp.length == 6 && !widget.isLoading)
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () => widget.onOtpVerified(_currentOtp),
                child: Text(
                  'Verify Code',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Loading Indicator
          if (widget.isLoading) ...[
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Verifying...',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 12.w,
      height: 6.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline,
          width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            _onOtpChanged(index);
          }
        },
        onTap: () {
          // Clear field when tapped
          _otpControllers[index].clear();
        },
        onEditingComplete: () {
          if (_otpControllers[index].text.isEmpty && index > 0) {
            _onBackspace(index);
          }
        },
      ),
    );
  }
}
