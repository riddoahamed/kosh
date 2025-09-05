import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NidVerificationStepWidget extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final CameraController? cameraController;
  final Future<XFile?> Function() onCapturePhoto;
  final Future<bool> Function() onRequestPermission;

  const NidVerificationStepWidget({
    Key? key,
    required this.formData,
    required this.onDataChanged,
    required this.onNext,
    required this.onPrevious,
    required this.cameraController,
    required this.onCapturePhoto,
    required this.onRequestPermission,
  }) : super(key: key);

  @override
  State<NidVerificationStepWidget> createState() =>
      _NidVerificationStepWidgetState();
}

class _NidVerificationStepWidgetState extends State<NidVerificationStepWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nidNumberController = TextEditingController();

  XFile? _frontImage;
  XFile? _backImage;
  bool _isCapturing = false;
  bool _hasPermission = false;
  String _captureMode = 'front'; // 'front' or 'back'

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _checkPermissions();
  }

  @override
  void dispose() {
    _nidNumberController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    _nidNumberController.text = widget.formData['nid_number'] ?? '';
  }

  Future<void> _checkPermissions() async {
    if (kIsWeb) {
      setState(() {
        _hasPermission = true;
      });
      return;
    }

    final hasPermission = await widget.onRequestPermission();
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  void _updateData() {
    widget.onDataChanged({
      'nid_number': _nidNumberController.text,
      'front_image_path': _frontImage?.path,
      'back_image_path': _backImage?.path,
    });
  }

  Future<void> _captureNidImage(String side) async {
    if (!_hasPermission) {
      final granted = await widget.onRequestPermission();
      if (!granted) {
        _showPermissionDialog();
        return;
      }
      setState(() {
        _hasPermission = true;
      });
    }

    setState(() {
      _isCapturing = true;
      _captureMode = side;
    });

    try {
      final image = await widget.onCapturePhoto();
      if (image != null) {
        setState(() {
          if (side == 'front') {
            _frontImage = image;
          } else {
            _backImage = image;
          }
        });
        _updateData();
        _showSuccessMessage(
            '${side == 'front' ? 'Front' : 'Back'} side captured successfully');
      }
    } catch (e) {
      _showErrorMessage('Failed to capture image: $e');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery(String side) async {
    try {
      final ImagePicker picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          if (side == 'front') {
            _frontImage = image;
          } else {
            _backImage = image;
          }
        });
        _updateData();
        _showSuccessMessage(
            '${side == 'front' ? 'Front' : 'Back'} side selected successfully');
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text('Please grant camera permission to capture NID photos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.onRequestPermission();
              _checkPermissions();
            },
            child: Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  String? _validateNid(String? value) {
    if (value?.isEmpty == true) {
      return 'NID number is required';
    }

    // Remove spaces and special characters
    final cleanValue = value!.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's 10, 13, or 17 digits (old and new NID formats)
    if (cleanValue.length == 10 ||
        cleanValue.length == 13 ||
        cleanValue.length == 17) {
      return null;
    }

    return 'Enter valid NID number (10, 13, or 17 digits)';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NID Verification',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Please provide your National ID card number and capture both sides',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // NID Number Input
                    _buildNidNumberField(),

                    SizedBox(height: 3.h),

                    // NID Front Side
                    _buildImageCaptureSection(
                      title: 'NID Front Side',
                      description: 'Capture the front side of your NID card',
                      image: _frontImage,
                      onCapture: () => _captureNidImage('front'),
                      onPickFromGallery: () => _pickImageFromGallery('front'),
                    ),

                    SizedBox(height: 3.h),

                    // NID Back Side
                    _buildImageCaptureSection(
                      title: 'NID Back Side',
                      description: 'Capture the back side of your NID card',
                      image: _backImage,
                      onCapture: () => _captureNidImage('back'),
                      onPickFromGallery: () => _pickImageFromGallery('back'),
                    ),

                    if (_isCapturing) ...[
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryLight,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Capturing ${_captureMode} side...',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 3.h),
                    _buildTips(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                    child: Text('Previous'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _canProceed()
                        ? () {
                            if (_formKey.currentState?.validate() == true) {
                              _updateData();
                              widget.onNext();
                            }
                          }
                        : null,
                    child: Text('Continue to Bank Account'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNidNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NID Number',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _nidNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your NID number',
            prefixIcon: CustomIconWidget(
              iconName: 'credit_card',
              size: 20,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          validator: _validateNid,
          onChanged: (_) => _updateData(),
        ),
      ],
    );
  }

  Widget _buildImageCaptureSection({
    required String title,
    required String description,
    required XFile? image,
    required VoidCallback onCapture,
    required VoidCallback onPickFromGallery,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 2.h),
          if (image != null) ...[
            Container(
              width: double.infinity,
              height: 25.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: kIsWeb
                      ? NetworkImage(image.path)
                      : FileImage(File(image.path)) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCapture,
                    icon: CustomIconWidget(
                      iconName: 'camera_alt',
                      size: 16,
                      color: AppTheme.primaryLight,
                    ),
                    label: Text('Retake'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickFromGallery,
                    icon: CustomIconWidget(
                      iconName: 'photo_library',
                      size: 16,
                      color: AppTheme.primaryLight,
                    ),
                    label: Text('Gallery'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              height: 25.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderLight,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'credit_card',
                    size: 48,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No image captured',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCapture,
                    icon: CustomIconWidget(
                      iconName: 'camera_alt',
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text('Capture'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickFromGallery,
                    icon: CustomIconWidget(
                      iconName: 'photo_library',
                      size: 16,
                      color: AppTheme.primaryLight,
                    ),
                    label: Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                size: 20,
                color: AppTheme.warningColor,
              ),
              SizedBox(width: 2.w),
              Text(
                'Tips for better NID capture:',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '• Ensure good lighting\n• Keep the card flat and within frame\n• Make sure all text is clearly visible\n• Avoid shadows and glare',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    return _nidNumberController.text.isNotEmpty &&
        _frontImage != null &&
        _backImage != null;
  }
}