import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PersonalDetailsStepWidget extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;
  final VoidCallback onNext;

  const PersonalDetailsStepWidget({
    Key? key,
    required this.formData,
    required this.onDataChanged,
    required this.onNext,
  }) : super(key: key);

  @override
  State<PersonalDetailsStepWidget> createState() =>
      _PersonalDetailsStepWidgetState();
}

class _PersonalDetailsStepWidgetState extends State<PersonalDetailsStepWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _occupationController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGender;
  String? _selectedMaritalStatus;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _monthlyIncomeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    _fullNameController.text = widget.formData['full_name'] ?? '';
    _fatherNameController.text = widget.formData['father_name'] ?? '';
    _motherNameController.text = widget.formData['mother_name'] ?? '';
    _dobController.text = widget.formData['date_of_birth'] ?? '';
    _occupationController.text = widget.formData['occupation'] ?? '';
    _monthlyIncomeController.text = widget.formData['monthly_income'] ?? '';
    _phoneController.text = widget.formData['phone'] ?? '';
    _selectedGender = widget.formData['gender'];
    _selectedMaritalStatus = widget.formData['marital_status'];
  }

  void _updateData() {
    widget.onDataChanged({
      'full_name': _fullNameController.text,
      'father_name': _fatherNameController.text,
      'mother_name': _motherNameController.text,
      'date_of_birth': _dobController.text,
      'occupation': _occupationController.text,
      'monthly_income': _monthlyIncomeController.text,
      'phone': _phoneController.text,
      'gender': _selectedGender,
      'marital_status': _selectedMaritalStatus,
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 100 * 365)),
      lastDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryLight),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
      _updateData();
    }
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
              'Personal Information',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Please provide your personal details as per your NID card',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name (as per NID)',
                      hint: 'Enter your full name',
                      icon: 'person',
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Full name is required';
                        }
                        if (value!.length < 2) {
                          return 'Full name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildTextField(
                      controller: _fatherNameController,
                      label: 'Father\'s Name',
                      hint: 'Enter father\'s name',
                      icon: 'person_outline',
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Father\'s name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildTextField(
                      controller: _motherNameController,
                      label: 'Mother\'s Name',
                      hint: 'Enter mother\'s name',
                      icon: 'person_outline',
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Mother\'s name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildDateField(),
                    SizedBox(height: 2.h),
                    _buildDropdown(
                      label: 'Gender',
                      value: _selectedGender,
                      items: ['Male', 'Female', 'Other'],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                        _updateData();
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildDropdown(
                      label: 'Marital Status',
                      value: _selectedMaritalStatus,
                      items: ['Single', 'Married', 'Divorced', 'Widowed'],
                      onChanged: (value) {
                        setState(() {
                          _selectedMaritalStatus = value;
                        });
                        _updateData();
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildTextField(
                      controller: _occupationController,
                      label: 'Occupation',
                      hint: 'Enter your occupation',
                      icon: 'work',
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Occupation is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildTextField(
                      controller: _monthlyIncomeController,
                      label: 'Monthly Income (BDT)',
                      hint: 'Enter monthly income',
                      icon: 'attach_money',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Monthly income is required';
                        }
                        final income = int.tryParse(value!);
                        if (income == null || income < 0) {
                          return 'Enter valid monthly income';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Mobile Number',
                      hint: 'Enter mobile number',
                      icon: 'phone',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Mobile number is required';
                        }
                        if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(value!)) {
                          return 'Enter valid Bangladesh mobile number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    _updateData();
                    widget.onNext();
                  }
                },
                child: Text('Continue to NID Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: CustomIconWidget(
              iconName: icon,
              size: 20,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          validator: validator,
          onChanged: (_) => _updateData(),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select date of birth',
            prefixIcon: CustomIconWidget(
              iconName: 'calendar_today',
              size: 20,
              color: AppTheme.textSecondaryLight,
            ),
            suffixIcon: CustomIconWidget(
              iconName: 'arrow_drop_down',
              size: 24,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty == true) {
              return 'Date of birth is required';
            }
            return null;
          },
          onTap: _selectDate,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select $label',
            prefixIcon: CustomIconWidget(
              iconName: 'arrow_drop_down',
              size: 20,
              color: AppTheme.textSecondaryLight,
            ),
          ),
          validator: (value) {
            if (value == null) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
