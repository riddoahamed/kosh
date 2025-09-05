import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/app_export.dart';
import './widgets/logout_button_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/switch_item_widget.dart';

class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({Key? key}) : super(key: key);

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkModeEnabled = false;
  bool _isLoading = false;

  // Add missing member variables
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  XFile? _capturedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isBengaliLanguage = false;
  String _selectedCurrency = 'BDT';
  bool _priceAlertsEnabled = true;
  bool _portfolioUpdatesEnabled = true;
  bool _educationalContentEnabled = true;
  bool _systemAnnouncementsEnabled = true;

  // Mock user data - in real app this would come from auth.uid
  Map<String, dynamic> _currentUserProfile = {
    'id': 'current_auth_uid_123',
    'name':
        'Current Signed-In User', // This will be replaced with actual user data
    'email': 'user@example.com',
    'phone': '+8801712345678',
    'hasInvestedBefore': false,
    'isRealTester': false,
    'createdAt': '2025-09-04T10:30:00Z',
    'lastActive': '2025-09-04T14:30:00Z',
    'virtualCashAvailable': 45000.0,
    'virtualStartingBalance': 50000.0,
  };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading current user profile by auth.uid
    await Future.delayed(Duration(milliseconds: 800));

    // In real implementation, fetch user data by auth.uid only
    // Example: final userData = await supabase.from('users').select().eq('id', auth.currentUser.id).single();

    setState(() {
      // Use the exact name from registration - never use seeded placeholder names
      _currentUserProfile = {
        'id': 'auth_uid_real_user',
        'name': 'Sheikh Riddo', // This would come from actual registration
        'email': 'sheikh.riddo@example.com',
        'phone': '+8801712345678',
        'hasInvestedBefore': false,
        'isRealTester': false,
        'createdAt': '2025-09-04T10:30:00Z',
        'lastActive': DateTime.now().toIso8601String(),
        'virtualCashAvailable': 45000.0,
        'virtualStartingBalance': 50000.0,
      };
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final hasPermission = await _requestCameraPermission();
        if (!hasPermission) return;
      }

      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first)
            : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first);

        _cameraController = CameraController(
            camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

        await _cameraController!.initialize();
        await _applySettings();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      debugPrint('Camera settings error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
        _currentUserProfile["avatar"] = photo.path;
      });

      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: "Profile photo updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      debugPrint('Photo capture error: $e');
      Fluttertoast.showToast(
        msg: "Failed to capture photo",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _currentUserProfile["avatar"] = image.path;
        });

        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: "Profile photo updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      Fluttertoast.showToast(
        msg: "Failed to select photo",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Update Profile Photo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(
                  'Camera',
                  'camera_alt',
                  () => _showCameraPreview(),
                ),
                _buildAvatarOption(
                  'Gallery',
                  'photo_library',
                  _pickFromGallery,
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 7.w,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _showCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Fluttertoast.showToast(
        msg: "Camera not available",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          width: 90.w,
          height: 70.h,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CameraPreview(_cameraController!),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      iconSize: 8.w,
                    ),
                    GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _pickFromGallery,
                      icon:
                          const Icon(Icons.photo_library, color: Colors.white),
                      iconSize: 8.w,
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

  void _showPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Privacy Policy'),
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadHtmlString('''
                <html>
                <head>
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <style>
                    body { font-family: Arial, sans-serif; padding: 20px; line-height: 1.6; }
                    h1 { color: #1B365D; }
                    h2 { color: #2A4A6B; margin-top: 30px; }
                    p { margin-bottom: 15px; }
                  </style>
                </head>
                <body>
                  <h1>KOSH Privacy Policy</h1>
                  <p><strong>Last updated:</strong> September 4, 2025</p>
                  
                  <h2>Information We Collect</h2>
                  <p>We collect information you provide directly to us, such as when you create an account, make transactions, or contact us for support.</p>
                  
                  <h2>How We Use Your Information</h2>
                  <p>We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.</p>
                  
                  <h2>Information Sharing</h2>
                  <p>We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.</p>
                  
                  <h2>Data Security</h2>
                  <p>We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.</p>
                  
                  <h2>Contact Us</h2>
                  <p>If you have any questions about this Privacy Policy, please contact us at privacy@kosh.com.bd</p>
                </body>
                </html>
              '''),
          ),
        ),
      ),
    );
  }

  void _showTermsOfService() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Terms of Service'),
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadHtmlString('''
                <html>
                <head>
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <style>
                    body { font-family: Arial, sans-serif; padding: 20px; line-height: 1.6; }
                    h1 { color: #1B365D; }
                    h2 { color: #2A4A6B; margin-top: 30px; }
                    p { margin-bottom: 15px; }
                  </style>
                </head>
                <body>
                  <h1>KOSH Terms of Service</h1>
                  <p><strong>Last updated:</strong> September 4, 2025</p>
                  
                  <h2>Acceptance of Terms</h2>
                  <p>By accessing and using KOSH, you accept and agree to be bound by the terms and provision of this agreement.</p>
                  
                  <h2>Use License</h2>
                  <p>Permission is granted to temporarily use KOSH for personal, non-commercial transitory viewing only.</p>
                  
                  <h2>Investment Disclaimer</h2>
                  <p>KOSH provides educational content and simulation tools. All investment decisions are made at your own risk. Past performance does not guarantee future results.</p>
                  
                  <h2>Account Responsibilities</h2>
                  <p>You are responsible for maintaining the confidentiality of your account and password and for restricting access to your device.</p>
                  
                  <h2>Prohibited Uses</h2>
                  <p>You may not use KOSH for any unlawful purpose or to solicit others to perform unlawful acts.</p>
                  
                  <h2>Contact Information</h2>
                  <p>Questions about the Terms of Service should be sent to us at legal@kosh.com.bd</p>
                </body>
                </html>
              '''),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Language',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('English'),
              value: false,
              groupValue: _isBengaliLanguage,
              onChanged: (value) {
                setState(() => _isBengaliLanguage = value!);
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "Language changed to English",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
            RadioListTile<bool>(
              title: const Text('বাংলা (Bengali)'),
              value: true,
              groupValue: _isBengaliLanguage,
              onChanged: (value) {
                setState(() => _isBengaliLanguage = value!);
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "ভাষা বাংলায় পরিবর্তিত হয়েছে",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Currency',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('BDT (৳) - Bangladeshi Taka'),
              value: 'BDT',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() => _selectedCurrency = value!);
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "Currency changed to BDT",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('USD (\$) - US Dollar'),
              value: 'USD',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() => _selectedCurrency = value!);
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "Currency changed to USD",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController =
        TextEditingController(text: _currentUserProfile["name"] as String);
    final emailController =
        TextEditingController(text: _currentUserProfile["email"] as String);
    final phoneController =
        TextEditingController(text: _currentUserProfile["phone"] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentUserProfile["name"] = nameController.text;
                _currentUserProfile["email"] = emailController.text;
                _currentUserProfile["phone"] = phoneController.text;
              });
              Navigator.of(context).pop();
              Fluttertoast.showToast(
                msg: "Profile updated successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Change Password',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "Password changed successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Passwords do not match",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showFantasyCashDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'account_balance_wallet',
              color: AppTheme.successColor,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Fantasy Cash',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Starting Balance',
                '৳${_currentUserProfile['virtualStartingBalance'].toStringAsFixed(0)}'),
            SizedBox(height: 1.h),
            _buildInfoRow('Available Cash',
                '৳${_currentUserProfile['virtualCashAvailable'].toStringAsFixed(0)}'),
            SizedBox(height: 1.h),
            _buildInfoRow('Invested Amount',
                '৳${(_currentUserProfile['virtualStartingBalance'] - _currentUserProfile['virtualCashAvailable']).toStringAsFixed(0)}'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                'Fantasy cash is virtual money used for practice trading. No real money is involved.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showPersonalInfoDialog() {
    final nameController =
        TextEditingController(text: _currentUserProfile["name"] as String);
    final emailController =
        TextEditingController(text: _currentUserProfile["email"] as String);
    final phoneController =
        TextEditingController(text: _currentUserProfile["phone"] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentUserProfile["name"] = nameController.text;
                _currentUserProfile["email"] = emailController.text;
                _currentUserProfile["phone"] = phoneController.text;
              });
              Navigator.of(context).pop();
              Fluttertoast.showToast(
                msg: "Profile updated successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTradingPreferencesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Trading Preferences',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchItemWidget(
                title: 'Enable Biometric Login',
                subtitle: 'Use fingerprint or face ID for login',
                iconName: 'fingerprint',
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() => _biometricEnabled = value);
                  Fluttertoast.showToast(
                    msg: value ? "Biometric enabled" : "Biometric disabled",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
              ),
              SwitchItemWidget(
                title: 'Enable Price Alerts',
                subtitle: 'Get notified about price changes',
                iconName: 'notifications',
                value: _priceAlertsEnabled,
                onChanged: (value) =>
                    setState(() => _priceAlertsEnabled = value),
              ),
              SwitchItemWidget(
                title: 'Enable Portfolio Updates',
                subtitle: 'Daily portfolio performance summary',
                iconName: 'trending_up',
                value: _portfolioUpdatesEnabled,
                onChanged: (value) =>
                    setState(() => _portfolioUpdatesEnabled = value),
              ),
              SwitchItemWidget(
                title: 'Enable Educational Content',
                subtitle: 'Learning tips and market insights',
                iconName: 'school',
                value: _educationalContentEnabled,
                onChanged: (value) =>
                    setState(() => _educationalContentEnabled = value),
              ),
              SwitchItemWidget(
                title: 'Enable System Announcements',
                subtitle: 'App updates and maintenance notices',
                iconName: 'campaign',
                value: _systemAnnouncementsEnabled,
                onChanged: (value) =>
                    setState(() => _systemAnnouncementsEnabled = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Fluttertoast.showToast(
                msg: "Preferences updated successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications(bool value) {
    setState(() => _notificationsEnabled = value);
    Fluttertoast.showToast(
      msg: value ? "Push notifications enabled" : "Push notifications disabled",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _toggleBiometric(bool value) {
    setState(() => _biometricEnabled = value);
    Fluttertoast.showToast(
      msg: value ? "Biometric enabled" : "Biometric disabled",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _toggleDarkMode(bool value) {
    setState(() => _darkModeEnabled = value);
    Fluttertoast.showToast(
      msg: value ? "Dark mode enabled" : "Dark mode disabled",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _navigateToHelp() {
    Navigator.pushNamed(context, '/learn-hub');
  }

  void _navigateToContact() {
    Navigator.pushNamed(context, '/contact-us');
  }

  void _handleLogout() {
    // Clear user session and navigate to login
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );

    Fluttertoast.showToast(
      msg: "Logged out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _handleLogout();
              Navigator.of(context).pop();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Profile & Settings',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              ProfileHeaderWidget(
                userName: 'John Doe',
                userEmail: 'john.doe@example.com',
                avatarUrl:
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
                onEditAvatar: () {
                  // TODO: Navigate to edit profile
                },
              ),

              SizedBox(height: 3.h),

              // BO Account Status Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BO Account',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildBoAccountStatus(),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              SettingsSectionWidget(
                title: 'Account',
                children: [
                  SettingsItemWidget(
                    title: 'Trading Account',
                    subtitle: 'Manage your trading preferences',
                    iconName: 'account_balance_wallet',
                    onTap: () {
                      // TODO: Navigate to trading account settings
                    },
                  ),
                  SettingsItemWidget(
                    title: 'Notifications',
                    subtitle: 'Push, Email & SMS preferences',
                    iconName: 'notifications',
                    onTap: () {
                      Navigator.pushNamed(context, '/notifications-screen');
                    },
                  ),
                  SettingsItemWidget(
                    title: 'Security',
                    subtitle: 'Password, 2FA & Login settings',
                    iconName: 'security',
                    onTap: () {
                      // TODO: Navigate to security settings
                    },
                    showDivider: false,
                  ),
                ],
              ),

              // Security Section
              SettingsSectionWidget(
                title: 'Security',
                children: [
                  SwitchItemWidget(
                    title: 'Biometric Login',
                    subtitle: 'Use fingerprint or face ID',
                    iconName: 'fingerprint',
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                  SettingsItemWidget(
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    iconName: 'lock_outline',
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  SettingsItemWidget(
                    title: 'Active Sessions',
                    subtitle: 'Manage your logged-in devices',
                    iconName: 'devices',
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: "1 active session found",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),

              // Notifications Section
              SettingsSectionWidget(
                title: 'Notifications',
                children: [
                  SwitchItemWidget(
                    title: 'Push Notifications',
                    subtitle: 'Get updates on your investments',
                    iconName: 'notifications_outlined',
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                  SettingsItemWidget(
                    title: 'Notifications',
                    subtitle: 'View all your notifications',
                    iconName: 'notifications',
                    onTap: () =>
                        Navigator.pushNamed(context, '/notifications-screen'),
                    showDivider: false,
                  ),
                ],
              ),

              // App Preferences Section
              SettingsSectionWidget(
                title: 'App Preferences',
                children: [
                  SwitchItemWidget(
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    iconName: 'dark_mode_outlined',
                    value: _darkModeEnabled,
                    onChanged: _toggleDarkMode,
                  ),
                ],
              ),

              // Support Section
              SettingsSectionWidget(
                title: 'Support',
                children: [
                  SettingsItemWidget(
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    iconName: 'help_outline',
                    onTap: () => _navigateToHelp(),
                  ),
                  SettingsItemWidget(
                    title: 'Contact Us',
                    subtitle: 'Reach out to our team',
                    iconName: 'contact_support_outlined',
                    onTap: () => _navigateToContact(),
                  ),
                ],
              ),

              // Admin Section (only visible to admins)
              SettingsSectionWidget(
                title: 'Admin',
                children: [
                  SettingsItemWidget(
                    title: 'BO Applications',
                    subtitle: 'Manage brokerage account applications',
                    iconName: 'admin_panel_settings',
                    onTap: () =>
                        Navigator.pushNamed(context, '/bo-admin-panel'),
                    showDivider: false,
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Logout Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                width: double.infinity,
                child: LogoutButtonWidget(
                  onLogout: () {
                    _showLogoutDialog();
                  },
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoAccountStatus() {
    // Mock BO account status - replace with actual data from Supabase
    final hasBoAccount = false; // TODO: Check from bo_applications table
    final boStatus = 'not_applied'; // submitted, in_review, approved, rejected

    if (!hasBoAccount) {
      return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open BO Account',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Start investing in stocks with BSEC compliant account opening',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bo-account-opening-wizard');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
              child: Text('Open Now'),
            ),
          ],
        ),
      );
    }

    // Show BO account details for users with accounts
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _getStatusColor(boStatus).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(boStatus).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: _getStatusColor(boStatus),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _getStatusText(boStatus),
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: _getStatusColor(boStatus),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'BO ID: BO123456789', // TODO: Get from database
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Opened: Jan 15, 2025', // TODO: Get from database
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return AppTheme.warningColor;
      case 'in_review':
        return AppTheme.primaryLight;
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryLight;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'submitted':
        return 'Application Submitted';
      case 'in_review':
        return 'Under Review';
      case 'approved':
        return 'Account Active';
      case 'rejected':
        return 'Application Rejected';
      default:
        return 'Unknown Status';
    }
  }
}