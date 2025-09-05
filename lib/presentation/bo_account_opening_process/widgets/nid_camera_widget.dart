import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class NidCameraWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isCameraReady;
  final XFile? nidImage;
  final XFile? selfieImage;
  final Map<String, dynamic>? nidData;
  final bool isProcessing;
  final VoidCallback onCaptureNid;
  final VoidCallback onCaptureSelfie;
  final VoidCallback onPickFromGallery;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const NidCameraWidget({
    Key? key,
    required this.cameraController,
    required this.isCameraReady,
    required this.nidImage,
    required this.selfieImage,
    required this.nidData,
    required this.isProcessing,
    required this.onCaptureNid,
    required this.onCaptureSelfie,
    required this.onPickFromGallery,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  Widget _buildImagePreview(XFile? imageFile, String title) {
    return Container(
      height: 20.h,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: imageFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: kIsWeb
                  ? Image.network(
                      imageFile.path,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(imageFile.path),
                      fit: BoxFit.cover,
                    ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 40,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: 1.h),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNidDataDisplay() {
    if (nidData == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                "NID Information Extracted",
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...[
            _buildInfoRow("NID Number", nidData!['nidNumber']),
            _buildInfoRow("Name", nidData!['name']),
            _buildInfoRow("Father's Name", nidData!['fatherName']),
            _buildInfoRow("Mother's Name", nidData!['motherName']),
            _buildInfoRow("Date of Birth", nidData!['dateOfBirth']),
            _buildInfoRow("Address", nidData!['address']),
          ],
          SizedBox(height: 1.h),
          Text(
            "Confidence: ${((nidData!['confidence'] as double) * 100).toInt()}%",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Please verify the information above is correct. You can edit any incorrect details in the next step.",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              "$label:",
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "NID & Photo Verification",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Take clear photos of your National ID card and a selfie for verification",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 3.h),

          // Camera preview or capture area
          if (isCameraReady && cameraController != null) ...[
            Container(
              height: 30.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: CameraPreview(cameraController!),
              ),
            ),

            SizedBox(height: 2.h),

            // Camera controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: nidImage == null ? onCaptureNid : null,
                  icon: Icon(Icons.camera_alt),
                  label: Text("Capture NID"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: nidImage != null
                        ? AppTheme.successColor
                        : AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: selfieImage == null && nidImage != null
                      ? onCaptureSelfie
                      : null,
                  icon: Icon(Icons.face),
                  label: Text("Take Selfie"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selfieImage != null
                        ? AppTheme.successColor
                        : AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.h),

            // Gallery option
            Center(
              child: TextButton.icon(
                onPressed: onPickFromGallery,
                icon: Icon(Icons.photo_library),
                label: Text("Choose from Gallery"),
              ),
            ),
          ] else ...[
            // Camera not ready or not available
            Container(
              height: 30.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 50,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Initializing Camera...",
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  CircularProgressIndicator(),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Fallback gallery option
            Center(
              child: ElevatedButton.icon(
                onPressed: onPickFromGallery,
                icon: Icon(Icons.photo_library),
                label: Text("Choose NID from Gallery"),
              ),
            ),
          ],

          SizedBox(height: 3.h),

          // Image previews
          Text(
            "Captured Images",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          _buildImagePreview(nidImage, "NID Card Photo"),
          _buildImagePreview(selfieImage, "Selfie Photo"),

          // Processing indicator
          if (isProcessing) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 2.h),
                  Text(
                    "Processing NID Information...",
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "This may take a few moments",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // NID data display
          _buildNidDataDisplay(),

          SizedBox(height: 4.h),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrevious,
                  child: Text("Previous"),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: (nidImage != null &&
                          selfieImage != null &&
                          nidData != null &&
                          !isProcessing)
                      ? onNext
                      : null,
                  child: Text("Continue"),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Guidelines
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Photo Guidelines:",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                ...[
                  "• Ensure good lighting and clear visibility",
                  "• Place NID card on a flat surface",
                  "• Avoid shadows and reflections",
                  "• Make sure all text is readable",
                  "• Take selfie in well-lit area with neutral expression",
                ].map((guideline) => Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Text(
                        guideline,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
