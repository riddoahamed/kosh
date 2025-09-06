import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/faq_card_widget.dart';
import './widgets/faq_empty_state_widget.dart';

class LearnTabFaq extends StatefulWidget {
  const LearnTabFaq({Key? key}) : super(key: key);

  @override
  State<LearnTabFaq> createState() => _LearnTabFaqState();
}

class _LearnTabFaqState extends State<LearnTabFaq>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isFeatureEnabled = true;
  List<Map<String, dynamic>> _faqData = [
    {
      'id': '1',
      'question': 'What is a stock?',
      'description':
          'Learn the basics of stock ownership and how companies raise capital',
      'learnMoreUrl': 'https://kosh.app/learn/stocks-basics',
    },
    {
      'id': '2',
      'question': 'What is a mutual fund?',
      'description':
          'Understanding pooled investment vehicles and professional management',
      'learnMoreUrl': 'https://kosh.app/learn/mutual-funds',
    },
    {
      'id': '3',
      'question': 'What is P/L?',
      'description': 'How profit and loss calculations work in your portfolio',
      'learnMoreUrl': 'https://kosh.app/learn/profit-loss',
    },
    {
      'id': '4',
      'question': 'How orders work in KOSH (fantasy)?',
      'description':
          'Understanding buy/sell orders in our fantasy trading system',
      'learnMoreUrl': 'https://kosh.app/learn/fantasy-orders',
    },
    {
      'id': '5',
      'question': 'What is a BO account?',
      'description':
          'Beneficiary Owner accounts and why you need one for real trading',
      'learnMoreUrl': 'https://kosh.app/learn/bo-account',
    },
  ];
  List<String> _bookmarkedFaqs = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Account Setup',
    'Trading Basics',
    'Portfolio Management',
    'Platform Features'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _initializeFeature();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeFeature() async {
    await _checkFeatureFlag();
    if (_isFeatureEnabled) {
      await _loadFaqData();
      await _loadBookmarks();
      _animationController.forward();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _checkFeatureFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFeatureEnabled = prefs.getBool('FEATURE_LEARN_TAB') ?? true;
    });
  }

  Future<void> _loadFaqData() async {
    // Simulating JSON load from local/Firestore
    final jsonData = _getMockFaqJson();
    setState(() {
      _faqData = List<Map<String, dynamic>>.from(jsonData['faqs']);
    });
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedFaqs = prefs.getStringList('bookmarked_faqs') ?? [];
    });
  }

  Future<void> _toggleBookmark(String faqId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedFaqs.contains(faqId)) {
        _bookmarkedFaqs.remove(faqId);
      } else {
        _bookmarkedFaqs.add(faqId);
      }
    });
    await prefs.setStringList('bookmarked_faqs', _bookmarkedFaqs);
  }

  Future<void> _provideFeedback(String faqId, bool isHelpful) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'faq_feedback_$faqId';
    await prefs.setBool(key, isHelpful);

    // Show feedback confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isHelpful
            ? 'Thanks for your feedback!'
            : 'We\'ll improve this answer'),
        backgroundColor:
            isHelpful ? AppTheme.successColor : AppTheme.warningColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareAnswer(Map<String, dynamic> faq) {
    // Implement sharing functionality
    final title = faq['question'] as String;
    final answer = faq['answer'] as String;

    // For now, just show a snackbar - in real app would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: $title'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link. Please try again later.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredFaqs() {
    var filteredFaqs = _faqData;

    // Filter by category
    if (_selectedCategory != 'All') {
      filteredFaqs = filteredFaqs
          .where((faq) => faq['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredFaqs = filteredFaqs.where((faq) {
        final question = (faq['question'] as String).toLowerCase();
        final answer = (faq['answer'] as String).toLowerCase();
        final tags = (faq['tags'] as List<String>).join(' ').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return question.contains(query) ||
            answer.contains(query) ||
            tags.contains(query);
      }).toList();
    }

    return filteredFaqs;
  }

  Map<String, dynamic> _getMockFaqJson() {
    return {
      "faqs": [
        {
          "id": "faq_1",
          "question": "How do I open a BO account?",
          "answer":
              "To open a BO (Beneficiary Owner) account, you need to visit any authorized broker with required documents: National ID, bank statement, passport-size photos, and proof of income. The process typically takes 3-5 working days for approval.",
          "category": "Account Setup",
          "tags": ["bo account", "registration", "documents"],
          "youtubeUrl": "",
          "isPopular": true
        },
        {
          "id": "faq_2",
          "question": "What is the minimum amount to start investing?",
          "answer":
              "There's no official minimum amount, but practically you need enough to buy at least one share of a stock. Most stocks trade between BDT 10-500 per share. We recommend starting with at least BDT 10,000 to diversify your portfolio effectively.",
          "category": "Trading Basics",
          "tags": ["minimum investment", "starting amount", "portfolio"],
          "youtubeUrl": "https://youtube.com/watch?v=example1",
          "isPopular": true
        },
        {
          "id": "faq_3",
          "question": "How are trading fees calculated?",
          "answer":
              "Trading fees include brokerage commission (0.5% for online, 0.6% for phone), LAGA fee (0.05%), and VAT (15% on commission). For a BDT 10,000 trade, total fees would be approximately BDT 60-70 including all charges.",
          "category": "Trading Basics",
          "tags": ["fees", "commission", "charges", "brokerage"],
          "youtubeUrl": "",
          "isPopular": false
        },
        {
          "id": "faq_4",
          "question": "How do I track my portfolio performance?",
          "answer":
              "Use the Portfolio section to view real-time values, profit/loss calculations, and performance graphs. You can track individual stock performance, overall portfolio returns, and compare with market indices. Data is updated every 15 minutes during trading hours.",
          "category": "Portfolio Management",
          "tags": ["portfolio", "tracking", "performance", "profit loss"],
          "youtubeUrl": "https://youtube.com/watch?v=example2",
          "isPopular": true
        },
        {
          "id": "faq_5",
          "question": "What is dividend and how do I receive it?",
          "answer":
              "Dividend is a portion of company profits distributed to shareholders. Cash dividends are credited directly to your bank account within 7-10 days after the dividend distribution date. Stock dividends appear as additional shares in your BO account.",
          "category": "Portfolio Management",
          "tags": ["dividend", "cash dividend", "stock dividend", "payment"],
          "youtubeUrl": "",
          "isPopular": false
        },
        {
          "id": "faq_6",
          "question": "How do I set price alerts?",
          "answer":
              "Go to any stock detail page and tap the bell icon. You can set alerts for price targets, percentage changes, volume spikes, or news updates. Alerts are sent via push notifications and email. You can manage all alerts from the Settings menu.",
          "category": "Platform Features",
          "tags": ["alerts", "price alert", "notifications", "settings"],
          "youtubeUrl": "",
          "isPopular": true
        },
        {
          "id": "faq_7",
          "question": "Can I trade after market hours?",
          "answer":
              "Regular trading hours are 10:00 AM to 2:30 PM, Sunday to Thursday. After-hours trading is not available in Bangladesh stock market. However, you can place orders after hours which will be executed when the market opens the next trading day.",
          "category": "Trading Basics",
          "tags": [
            "trading hours",
            "market hours",
            "after hours",
            "order placement"
          ],
          "youtubeUrl": "",
          "isPopular": false
        },
        {
          "id": "faq_8",
          "question": "How do I withdraw money from my trading account?",
          "answer":
              "To withdraw funds, sell your shares first, then submit a withdrawal request through the app or broker. Funds are transferred to your registered bank account within 2-3 working days. Ensure your bank details are updated in your BO account.",
          "category": "Account Setup",
          "tags": ["withdrawal", "bank transfer", "sell shares", "funds"],
          "youtubeUrl": "https://youtube.com/watch?v=example3",
          "isPopular": true
        }
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isFeatureEnabled) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 64,
                color: AppTheme.textSecondaryLight,
              ),
              SizedBox(height: 2.h),
              Text(
                'Learn Tab is currently disabled',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredFaqs = _getFilteredFaqs();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learn',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                          ),
                          Text(
                            'Quick answers to common questions',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // FAQ List
              Expanded(
                child: filteredFaqs.isEmpty
                    ? FaqEmptyStateWidget(
                        searchQuery: _searchQuery,
                        selectedCategory: _selectedCategory,
                        onResetFilters: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedCategory = 'All';
                          });
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        itemCount: filteredFaqs.length,
                        itemBuilder: (context, index) {
                          final faq = filteredFaqs[index];
                          final isBookmarked =
                              _bookmarkedFaqs.contains(faq['id']);

                          return FaqCardWidget(
                            faqData: faq,
                            isBookmarked: isBookmarked,
                            onToggleBookmark: () => _toggleBookmark(faq['id']),
                            onFeedback: (isHelpful) =>
                                _provideFeedback(faq['id'], isHelpful),
                            onShare: () => _shareAnswer(faq),
                            searchQuery: _searchQuery,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}