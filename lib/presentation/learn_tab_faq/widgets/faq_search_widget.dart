import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FaqSearchWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String searchQuery;

  const FaqSearchWidget({
    Key? key,
    required this.onSearchChanged,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<FaqSearchWidget> createState() => _FaqSearchWidgetState();
}

class _FaqSearchWidgetState extends State<FaqSearchWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNode.hasFocus
              ? AppTheme.primaryLight.withAlpha(77)
              : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withAlpha(128),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search FAQs, answers, or topics...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
          prefixIcon: Container(
            padding: EdgeInsets.all(3.w),
            child: Icon(
              Icons.search,
              color: AppTheme.textSecondaryLight,
              size: 5.w,
            ),
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? InkWell(
                  onTap: _clearSearch,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    child: Icon(
                      Icons.close,
                      color: AppTheme.textSecondaryLight,
                      size: 5.w,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
            ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _focusNode.unfocus();
        },
      ),
    );
  }
}
