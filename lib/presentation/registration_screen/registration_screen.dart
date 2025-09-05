import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/otp_verification_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 2;
  bool _isLoading = false;

  // Form data
  Map<String, dynamic> _formData = {};

  // Mock credentials for demonstration
  final Map<String, String> _mockCredentials = {
    'admin_email': 'admin@kosh.com.bd',
    'admin_password': 'Admin@123',
    'test_email': 'test@example.com',
    'test_password': 'Test@123',
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFormChanged(Map<String, dynamic> formData) {
    setState(() {
      _formData = formData;
    });
  }

  Future<void> _submitRegistration() async {
    if (!_formData['isValid']) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate user creation with exact submitted fields
      await Future.delayed(Duration(seconds: 2));

      // Check for duplicate email (mock validation)
      if (_formData['email'] == _mockCredentials['admin_email'] ||
          _formData['email'] == _mockCredentials['test_email']) {
        _showErrorDialog('Account Already Exists',
            'An account with this email already exists. Please use a different email or try logging in.');
        return;
      }

      // Create user record with exact submitted fields
      final userData = {
        'id': 'mock_auth_uid_${DateTime.now().millisecondsSinceEpoch}',
        'name':
            _formData['name'], // Exact submitted name - never use placeholder
        'phoneOrEmail': _formData['phoneOrEmail'], // Exact submitted contact
        'hasInvestedBefore': false,
        'isRealTester': false,
        'createdAt': DateTime.now().toIso8601String(),
        'lastActive': DateTime.now().toIso8601String(),
        // Fantasy cash fields
        'virtualStartingBalance': 50000,
        'virtualCashAvailable': 50000,
        'virtualCashReserved': 0,
      };

      // Store user data for session (mock implementation)
      // In real app, this would be stored in Supabase users table
      print('Created user with exact fields: $userData');

      // Move to OTP verification step
      _nextStep();
    } catch (e) {
      _showErrorDialog('Registration Failed',
          'Unable to create account. Please check your internet connection and try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate OTP verification with temporary disable of real checks
      await Future.delayed(Duration(seconds: 2));

      // TEMPORARY: Always accept '123456' for demo
      if (otp == '123456') {
        // Initialize user session with fantasy cash
        final userData = {
          'id': 'mock_auth_uid_${DateTime.now().millisecondsSinceEpoch}',
          'name': _formData['name'], // Exact name from form
          'phoneOrEmail': _formData['phoneOrEmail'],
          'hasInvestedBefore': false,
          'isRealTester': false,
          'createdAt': DateTime.now().toIso8601String(),
          'lastActive': DateTime.now().toIso8601String(),
          'virtualStartingBalance': 50000,
          'virtualCashAvailable': 50000,
          'virtualCashReserved': 0,
        };

        // Store user session data
        print('User registered successfully with fantasy cash: $userData');

        _showSuccessDialog();
      } else {
        _showErrorDialog('Invalid OTP',
            'The verification code you entered is incorrect. Please try again or request a new code.');
      }
    } catch (e) {
      _showErrorDialog('Verification Failed',
          'Unable to verify your phone number. Please check your internet connection and try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resendOtp() {
    // Simulate OTP resend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent to ${_formData['phone']}'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.errorColor,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successColor,
                  size: 32,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Account Created!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Welcome to KOSH! Your account has been created successfully. You\'ll start with fantasy mode to learn investing risk-free.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'account_balance_wallet',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Fantasy Cash Initialized',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Start with ৳50,000 virtual money to practice trading',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Real trading mode available by invitation only',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/dashboard-home');
              },
              child: Text(
                'Start Investing',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentStep > 1) {
      _previousStep();
      return false;
    }

    // Show confirmation dialog for exit
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Text(
          'Exit Registration?',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Exit',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header with progress
              RegistrationHeaderWidget(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),

              // Main Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    // Step 1: Registration Form
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: RegistrationFormWidget(
                        onFormChanged: _onFormChanged,
                        onSubmit: _submitRegistration,
                        isLoading: _isLoading,
                      ),
                    ),

                    // Step 2: OTP Verification
                    SingleChildScrollView(
                      child: OtpVerificationWidget(
                        phoneNumber: _formData['phone'] ?? '',
                        onOtpVerified: _verifyOtp,
                        onResendOtp: _resendOtp,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Navigation
              if (_currentStep > 1)
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          child: Text('Back'),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Already have an account?',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, '/login-screen'),
                        child: Text(
                          'Sign In',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Login Link (Step 1 only)
              if (_currentStep == 1)
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, '/login-screen'),
                        child: Text(
                          'Sign In',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
