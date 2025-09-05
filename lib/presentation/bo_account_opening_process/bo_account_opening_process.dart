
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../onboarding_flow/widgets/progress_indicator_widget.dart';
import './widgets/bank_details_form_widget.dart';
import './widgets/completion_widget.dart';
import './widgets/nid_camera_widget.dart';
import './widgets/personal_info_form_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/review_info_widget.dart';

enum BoOpeningStep {
  personalInfo,
  nidVerification,
  bankDetails,
  review,
  completion,
}

class BoAccountOpeningProcess extends StatefulWidget {
  const BoAccountOpeningProcess({Key? key}) : super(key: key);

  @override
  State<BoAccountOpeningProcess> createState() =>
      _BoAccountOpeningProcessState();
}

class _BoAccountOpeningProcessState extends State<BoAccountOpeningProcess> {
  BoOpeningStep _currentStep = BoOpeningStep.personalInfo;
  PageController _pageController = PageController();

  // Form data
  final Map<String, String> _personalInfo = {};
  final Map<String, String> _bankDetails = {};
  Map<String, dynamic>? _nidData;
  XFile? _nidImage;
  XFile? _selfieImage;

  // Validation state
  bool _isProcessing = false;
  bool _canSkip = true; // Allow exploring app without BO account

  // Camera state
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _checkExistingProgress();
    _initializeCamera();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkExistingProgress() async {
    // Check if user has partially completed BO process
    final prefs = await SharedPreferences.getInstance();
    final savedStep = prefs.getInt('bo_opening_step') ?? 0;
    final savedPersonalInfo = prefs.getString('bo_personal_info');

    if (savedPersonalInfo != null) {
      // Resume from saved progress
      setState(() {
        _currentStep = BoOpeningStep.values[savedStep];
        // Load saved data
      });
    }
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      // Web camera initialization
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraReady = true;
        });
      }
    } else {
      // Mobile camera initialization
      final hasPermission = await _requestCameraPermission();
      if (hasPermission) {
        _cameras = await availableCameras();
        if (_cameras!.isNotEmpty) {
          final backCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras!.first,
          );
          _cameraController = CameraController(
            backCamera,
            ResolutionPreset.high,
          );
          await _cameraController!.initialize();

          // Mobile-specific camera settings
          try {
            await _cameraController!.setFocusMode(FocusMode.auto);
            await _cameraController!.setFlashMode(FlashMode.auto);
          } catch (e) {
            // Ignore unsupported features
          }

          setState(() {
            _isCameraReady = true;
          });
        }
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true; // Browser handles permissions

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _captureNidImage() async {
    if (_cameraController == null || !_isCameraReady) return;

    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _nidImage = image;
      });

      // Simulate OCR processing
      await _processNidImage(image);

      HapticFeedback.lightImpact();
    } catch (e) {
      _showError("Failed to capture image. Please try again.");
    }
  }

  Future<void> _captureSelfie() async {
    if (_cameraController == null || !_isCameraReady) return;

    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _selfieImage = image;
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      _showError("Failed to capture selfie. Please try again.");
    }
  }

  Future<void> _processNidImage(XFile image) async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate OCR processing with mock data
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _nidData = {
        'nidNumber': '1234567890123',
        'name': 'John Doe',
        'fatherName': 'Father Name',
        'motherName': 'Mother Name',
        'dateOfBirth': '01/01/1990',
        'address': '123 Main Street, Dhaka',
        'confidence': 0.95, // OCR confidence score
      };
      _isProcessing = false;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _nidImage = image;
      });
      await _processNidImage(image);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bo_opening_step', _currentStep.index);
    // Save form data as needed
  }

  void _nextStep() {
    if (_currentStep.index < BoOpeningStep.values.length - 1) {
      setState(() {
        _currentStep = BoOpeningStep.values[_currentStep.index + 1];
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveProgress();
    }
  }

  void _previousStep() {
    if (_currentStep.index > 0) {
      setState(() {
        _currentStep = BoOpeningStep.values[_currentStep.index - 1];
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipForNow() {
    // Allow user to explore app without BO account
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboardHome,
      (route) => false,
    );
    _showSuccess("You can open a BO account anytime from Settings");
  }

  Future<void> _submitApplication() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate API submission
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _isProcessing = false;
      _currentStep = BoOpeningStep.completion;
    });

    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Clear saved progress
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bo_opening_step');
    await prefs.remove('bo_personal_info');

    _showSuccess("BO account application submitted successfully!");
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case BoOpeningStep.personalInfo:
        return PersonalInfoFormWidget(
          personalInfo: _personalInfo,
          onInfoChanged: (info) {
            setState(() {
              _personalInfo.addAll(info);
            });
          },
          onNext: _nextStep,
        );
      case BoOpeningStep.nidVerification:
        return NidCameraWidget(
          cameraController: _cameraController,
          isCameraReady: _isCameraReady,
          nidImage: _nidImage,
          selfieImage: _selfieImage,
          nidData: _nidData,
          isProcessing: _isProcessing,
          onCaptureNid: _captureNidImage,
          onCaptureSelfie: _captureSelfie,
          onPickFromGallery: _pickImageFromGallery,
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case BoOpeningStep.bankDetails:
        return BankDetailsFormWidget(
          bankDetails: _bankDetails,
          onDetailsChanged: (details) {
            setState(() {
              _bankDetails.addAll(details);
            });
          },
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case BoOpeningStep.review:
        return ReviewInfoWidget(
          personalInfo: _personalInfo,
          bankDetails: _bankDetails,
          nidData: _nidData,
          nidImage: _nidImage,
          selfieImage: _selfieImage,
          onSubmit: _submitApplication,
          onPrevious: _previousStep,
          isProcessing: _isProcessing,
        );
      case BoOpeningStep.completion:
        return CompletionWidget(
          onContinue: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboardHome,
              (route) => false,
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip option
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Open BO Account",
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_canSkip && _currentStep != BoOpeningStep.completion)
                    TextButton(
                      onPressed: _skipForNow,
                      child: Text(
                        "Skip for Now",
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Progress indicator
            if (_currentStep != BoOpeningStep.completion)
              ProgressIndicatorWidget(
                currentStep: _currentStep.index,
                totalSteps:
                    BoOpeningStep.values.length - 1, // Exclude completion
                stepTitles: [
                  'Personal Info',
                  'NID Verification',
                  'Bank Details',
                  'Review',
                ],
              ),

            // Step content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(), // Disable swipe
                itemCount: BoOpeningStep.values.length,
                itemBuilder: (context, index) => _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
