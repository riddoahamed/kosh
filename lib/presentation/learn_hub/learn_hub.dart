import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievement_badge_widget.dart';
import './widgets/course_card_widget.dart';
import './widgets/featured_article_widget.dart';
import './widgets/progress_header_widget.dart';
import './widgets/quiz_card_widget.dart';
import './widgets/search_bar_widget.dart';

class LearnHub extends StatefulWidget {
  const LearnHub({Key? key}) : super(key: key);

  @override
  State<LearnHub> createState() => _LearnHubState();
}

class _LearnHubState extends State<LearnHub> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  int _selectedBottomIndex = 2; // Learn tab active

  // Mock data for progress
  final Map<String, dynamic> _progressData = {
    "overallProgress": 0.65,
    "completedCourses": 8,
    "totalCourses": 12,
    "streakDays": 7,
    "currentLevel": "Intermediate"
  };

  // Mock data for courses
  final List<Map<String, dynamic>> _coursesData = [
    {
      "id": 1,
      "title": "Stock Market Fundamentals",
      "description":
          "Learn the basics of stock investing, market analysis, and building your first portfolio with confidence.",
      "progress": 0.8,
      "duration": "45 min",
      "difficulty": "Beginner",
      "imageUrl":
          "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "isCompleted": false
    },
    {
      "id": 2,
      "title": "Mutual Fund Mastery",
      "description":
          "Understand different types of mutual funds, SIP strategies, and how to choose the right funds for your goals.",
      "progress": 1.0,
      "duration": "60 min",
      "difficulty": "Intermediate",
      "imageUrl":
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "isCompleted": true
    },
    {
      "id": 3,
      "title": "Technical Analysis Basics",
      "description":
          "Master chart patterns, indicators, and technical analysis tools to make informed trading decisions.",
      "progress": 0.3,
      "duration": "90 min",
      "difficulty": "Advanced",
      "imageUrl":
          "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "isCompleted": false
    },
    {
      "id": 4,
      "title": "Risk Management Strategies",
      "description":
          "Learn how to protect your investments through proper risk assessment and portfolio diversification.",
      "progress": 0.5,
      "duration": "40 min",
      "difficulty": "Intermediate",
      "imageUrl":
          "https://images.unsplash.com/photo-1460925895917-afdab827c52f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "isCompleted": false
    },
    {
      "id": 5,
      "title": "Gold Investment Guide",
      "description":
          "Explore different ways to invest in gold, from physical gold to ETFs and digital gold platforms.",
      "progress": 0.0,
      "duration": "35 min",
      "difficulty": "Beginner",
      "imageUrl":
          "https://images.unsplash.com/photo-1610375461246-83df859d849d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "isCompleted": false
    }
  ];

  // Mock data for featured articles
  final List<Map<String, dynamic>> _articlesData = [
    {
      "id": 1,
      "title": "Market Volatility: Opportunity or Risk?",
      "author": "Sarah Ahmed",
      "readTime": "8 min read",
      "publishedDate": "Dec 15",
      "imageUrl":
          "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "isBookmarked": true,
      "isDownloaded": true
    },
    {
      "id": 2,
      "title": "Building Wealth Through SIP Investments",
      "author": "Rahul Khan",
      "readTime": "12 min read",
      "publishedDate": "Dec 12",
      "imageUrl":
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "isBookmarked": false,
      "isDownloaded": false
    },
    {
      "id": 3,
      "title": "Cryptocurrency vs Traditional Assets",
      "author": "Fatima Hassan",
      "readTime": "15 min read",
      "publishedDate": "Dec 10",
      "imageUrl":
          "https://images.unsplash.com/photo-1518546305927-5a555bb7020d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "isBookmarked": false,
      "isDownloaded": true
    }
  ];

  // Mock data for achievements
  final List<Map<String, dynamic>> _achievementsData = [
    {
      "id": 1,
      "title": "First Course",
      "description": "Complete your first course",
      "iconName": "school",
      "isEarned": true,
      "earnedDate": "Nov 28"
    },
    {
      "id": 2,
      "title": "Quiz Master",
      "description": "Score 90%+ on 5 quizzes",
      "iconName": "quiz",
      "isEarned": true,
      "earnedDate": "Dec 5"
    },
    {
      "id": 3,
      "title": "Streak Hero",
      "description": "7-day learning streak",
      "iconName": "local_fire_department",
      "isEarned": true,
      "earnedDate": "Dec 15"
    },
    {
      "id": 4,
      "title": "Expert Trader",
      "description": "Complete advanced courses",
      "iconName": "trending_up",
      "isEarned": false,
      "earnedDate": ""
    }
  ];

  // Mock data for quizzes
  final List<Map<String, dynamic>> _quizzesData = [
    {
      "id": 1,
      "title": "Stock Market Basics Quiz",
      "description":
          "Test your knowledge of fundamental stock market concepts and terminology.",
      "totalQuestions": 15,
      "completedQuestions": 15,
      "difficulty": "Beginner",
      "isCompleted": true,
      "bestScore": 87
    },
    {
      "id": 2,
      "title": "Mutual Fund Assessment",
      "description":
          "Evaluate your understanding of mutual fund types, NAV, and investment strategies.",
      "totalQuestions": 20,
      "completedQuestions": 12,
      "difficulty": "Intermediate",
      "isCompleted": false,
      "bestScore": null
    },
    {
      "id": 3,
      "title": "Risk Management Challenge",
      "description":
          "Advanced quiz on portfolio diversification and risk assessment techniques.",
      "totalQuestions": 25,
      "completedQuestions": 0,
      "difficulty": "Advanced",
      "isCompleted": false,
      "bestScore": null
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredCourses() {
    if (_searchQuery.isEmpty) return _coursesData;
    return _coursesData.where((course) {
      final title = (course['title'] as String).toLowerCase();
      final description = (course['description'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredArticles() {
    if (_searchQuery.isEmpty) return _articlesData;
    return _articlesData.where((article) {
      final title = (article['title'] as String).toLowerCase();
      final author = (article['author'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || author.contains(query);
    }).toList();
  }

  void _toggleBookmark(int articleId) {
    setState(() {
      final articleIndex =
          _articlesData.indexWhere((article) => article['id'] == articleId);
      if (articleIndex != -1) {
        _articlesData[articleIndex]['isBookmarked'] =
            !(_articlesData[articleIndex]['isBookmarked'] as bool);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
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
                          'Learn Hub',
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
                          'Expand your investing knowledge',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/user-profile-settings');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'notifications_outlined',
                        size: 24,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            SearchBarWidget(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onFilterTap: () {
                // Show filter options
              },
            ),

            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Courses'),
                  Tab(text: 'Articles'),
                  Tab(text: 'Quizzes'),
                  Tab(text: 'Achievements'),
                ],
                labelColor: AppTheme.lightTheme.colorScheme.primary,
                unselectedLabelColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                indicator: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Courses Tab
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child:
                            ProgressHeaderWidget(progressData: _progressData),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                          child: Text(
                            'Featured Courses',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final filteredCourses = _getFilteredCourses();
                            if (index >= filteredCourses.length) return null;

                            return CourseCardWidget(
                              courseData: filteredCourses[index],
                              onTap: () {
                                // Navigate to course detail
                              },
                            );
                          },
                          childCount: _getFilteredCourses().length,
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    ],
                  ),

                  // Articles Tab
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                          child: Text(
                            'Featured Articles',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final filteredArticles = _getFilteredArticles();
                            if (index >= filteredArticles.length) return null;

                            return FeaturedArticleWidget(
                              articleData: filteredArticles[index],
                              onTap: () {
                                // Navigate to article detail
                              },
                              onBookmark: () {
                                _toggleBookmark(
                                    filteredArticles[index]['id'] as int);
                              },
                            );
                          },
                          childCount: _getFilteredArticles().length,
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    ],
                  ),

                  // Quizzes Tab
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                          child: Text(
                            'Interactive Quizzes',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= _quizzesData.length) return null;

                            return QuizCardWidget(
                              quizData: _quizzesData[index],
                              onTap: () {
                                // Navigate to quiz
                              },
                            );
                          },
                          childCount: _quizzesData.length,
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    ],
                  ),

                  // Achievements Tab
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                          child: Text(
                            'Your Achievements',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ),
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 1.h,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= _achievementsData.length) return null;

                            return AchievementBadgeWidget(
                              badgeData: _achievementsData[index],
                              onTap: () {
                                // Show achievement details
                              },
                            );
                          },
                          childCount: _achievementsData.length,
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard-home');
              break;
            case 1:
              Navigator.pushNamed(context, '/markets-browse');
              break;
            case 2:
              // Already on Learn Hub
              break;
            case 3:
              Navigator.pushNamed(context, '/portfolio-holdings');
              break;
            case 4:
              Navigator.pushNamed(context, '/user-profile-settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home_outlined',
              size: 24,
              color: _selectedBottomIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'home',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'trending_up',
              size: 24,
              color: _selectedBottomIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'school_outlined',
              size: 24,
              color: _selectedBottomIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'school',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'account_balance_wallet_outlined',
              size: 24,
              color: _selectedBottomIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'account_balance_wallet',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person_outlined',
              size: 24,
              color: _selectedBottomIndex == 4
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'person',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
