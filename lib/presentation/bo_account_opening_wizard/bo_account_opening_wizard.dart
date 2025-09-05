import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/bo_wizard_header_widget.dart';
import './widgets/bo_wizard_step_indicator_widget.dart';
import './widgets/nid_verification_step_widget.dart';
import './widgets/personal_details_step_widget.dart';

class BoAccountOpeningWizard extends StatefulWidget {
  const BoAccountOpeningWizard({Key? key}) : super(key: key);

  @override
  State<BoAccountOpeningWizard> createState() => _BoAccountOpeningWizardState();
}

class _BoAccountOpeningWizardState extends State<BoAccountOpeningWizard>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  final int _totalSteps = 8;
  bool _isSubmitting = false;

  // Form data storage
  final Map<String, dynamic> _formData = {
    'personal_details': {},
    'nid_verification': {},
    'bank_account': {},
    'photo_verification': {},
    'address_proof': {},
    'nominee_information': {},
    'risk_assessment': {},
  };

  // Camera related
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _initializeCamera();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (kIsWeb) return; // Skip camera initialization on web

      _cameras = await availableCameras();
      if (_cameras?.isNotEmpty == true) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<XFile?> _capturePhoto() async {
    try {
      if (kIsWeb) {
        // Use image picker for web
        return await _imagePicker.pickImage(source: ImageSource.camera);
      }

      if (_cameraController?.value.isInitialized == true) {
        return await _cameraController!.takePicture();
      }

      // Fallback to image picker
      return await _imagePicker.pickImage(source: ImageSource.camera);
    } catch (e) {
      print('Photo capture error: $e');
      return null;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateFormData(String section, Map<String, dynamic> data) {
    setState(() {
      _formData[section] = {..._formData[section], ...data};
    });
  }

  Future<void> _submitApplication() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Mock API call - replace with actual Supabase integration
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('BO Account application submitted successfully!'),
            backgroundColor: AppTheme.successColor,
            action: SnackBarAction(
              label: 'View Status',
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/user-profile-settings');
              },
            ),
          ),
        );

        // Navigate back to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard-home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<String> get _stepTitles => [
        'Personal Details',
        'NID Verification',
        'Bank Account',
        'Photo Verification',
        'Address Proof',
        'Nominee Info',
        'Risk Assessment',
        'Review & Submit',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              BoWizardHeaderWidget(
                currentStep: _currentStep + 1,
                totalSteps: _totalSteps,
                title: _stepTitles[_currentStep],
                onClose: () => Navigator.pop(context),
              ),
              BoWizardStepIndicatorWidget(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                stepTitles: _stepTitles,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    PersonalDetailsStepWidget(
                      formData: _formData['personal_details'],
                      onDataChanged: (data) =>
                          _updateFormData('personal_details', data),
                      onNext: _nextStep,
                    ),
                    NidVerificationStepWidget(
                      formData: _formData['nid_verification'],
                      onDataChanged: (data) =>
                          _updateFormData('nid_verification', data),
                      onNext: _nextStep,
                      onPrevious: _previousStep,
                      cameraController: _cameraController,
                      onCapturePhoto: _capturePhoto,
                      onRequestPermission: _requestCameraPermission,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Bank Account Step', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _previousStep,
                                child: Text('Previous'),
                              ),
                              ElevatedButton(
                                onPressed: _nextStep,
                                child: Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Photo Verification Step', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _previousStep,
                                child: Text('Previous'),
                              ),
                              ElevatedButton(
                                onPressed: _nextStep,
                                child: Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Address Proof Step', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _previousStep,
                                child: Text('Previous'),
                              ),
                              ElevatedButton(
                                onPressed: _nextStep,
                                child: Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Nominee Information Step', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _previousStep,
                                child: Text('Previous'),
                              ),
                              ElevatedButton(
                                onPressed: _nextStep,
                                child: Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Risk Assessment Step', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _previousStep,
                                child: Text('Previous'),
                              ),
                              ElevatedButton(
                                onPressed: _nextStep,
                                child: Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Application Review', style: TextStyle(fontSize: 24)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _previousStep,
                                child: Text('Previous'),
                              ),
                              ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitApplication,
                                child: _isSubmitting 
                                  ? CircularProgressIndicator()
                                  : Text('Submit'),
                              ),
                            ],
                          ),
                        ],
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