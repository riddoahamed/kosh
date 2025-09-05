import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FaqCardWidget extends StatefulWidget {
  final Map<String, dynamic> faqData;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final Function(bool) onFeedback;
  final VoidCallback onShare;
  final String searchQuery;

  const FaqCardWidget({
    Key? key,
    required this.faqData,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.onFeedback,
    required this.onShare,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  State<FaqCardWidget> createState() => _FaqCardWidgetState();
}

class _FaqCardWidgetState extends State<FaqCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              height: 1.5,
            ),
      );
    }

    final regex = RegExp(RegExp.escape(query), caseSensitive: false);
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              height: 1.5,
            ),
      );
    }

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add text before match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryLight,
              ),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryLight,
              backgroundColor: AppTheme.primaryLight.withAlpha(51),
              fontWeight: FontWeight.w600,
            ),
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
            ),
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.faqData['question'] as String;
    final answer = widget.faqData['answer'] as String;
    final category = widget.faqData['category'] as String;
    final isPopular = widget.faqData['isPopular'] as bool? ?? false;
    final youtubeUrl = widget.faqData['youtubeUrl'] as String? ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded
              ? AppTheme.primaryLight.withAlpha(77)
              : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: _isExpanded ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question Header
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Category Badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withAlpha(26),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                    ),
                  ),

                  if (isPopular) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 3.w,
                            color: AppTheme.warningColor,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Popular',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.warningColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10.sp,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Bookmark Button
                  InkWell(
                    onTap: widget.onToggleBookmark,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      child: Icon(
                        widget.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: widget.isBookmarked
                            ? AppTheme.accentColor
                            : AppTheme.textSecondaryLight,
                        size: 5.w,
                      ),
                    ),
                  ),

                  // Expand Icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondaryLight,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Question Title
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _highlightText(question, widget.searchQuery),
            ),
          ),

          // Expandable Answer
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                // Divider
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                  height: 1,
                  color: AppTheme.borderLight,
                ),

                // Answer Content
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _highlightText(answer, widget.searchQuery),

                      // YouTube Link if available
                      if (youtubeUrl.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        InkWell(
                          onTap: () {
                            // Open YouTube video - would implement with url_launcher
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening video tutorial...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withAlpha(77),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.red,
                                  size: 5.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Watch Video Tutorial',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Buttons
                Container(
                  margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Was this helpful?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),

                      const Spacer(),

                      // Helpful Button
                      InkWell(
                        onTap: () => widget.onFeedback(true),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.thumb_up_outlined,
                                size: 4.w,
                                color: AppTheme.successColor,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Yes',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 2.w),

                      // Not Helpful Button
                      InkWell(
                        onTap: () => widget.onFeedback(false),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.thumb_down_outlined,
                                size: 4.w,
                                color: AppTheme.errorColor,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'No',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.errorColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 2.w),

                      // Share Button
                      InkWell(
                        onTap: widget.onShare,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          child: Icon(
                            Icons.share_outlined,
                            size: 4.w,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
