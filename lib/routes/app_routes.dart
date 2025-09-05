import 'package:flutter/material.dart';
import '../presentation/learn_hub/learn_hub.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/markets_browse/markets_browse.dart';
import '../presentation/buy_order_ticket/buy_order_ticket.dart';
import '../presentation/enhanced_order_ticket/enhanced_order_ticket.dart';
import '../presentation/sell_order_ticket/sell_order_ticket.dart';
import '../presentation/portfolio_holdings/portfolio_holdings.dart';
import '../presentation/user_profile_settings/user_profile_settings.dart';
import '../presentation/instrument_detail/instrument_detail.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/education_onboarding_slides/education_onboarding_slides.dart';
import '../presentation/learn_tab_faq/learn_tab_faq.dart';
import '../presentation/price_admin_panel/price_admin_panel.dart';
import '../presentation/bo_application_form/bo_application_form.dart';
import '../presentation/bo_admin_panel/bo_admin_panel.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/bo_account_opening_wizard/bo_account_opening_wizard.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String learnHub = '/learn-hub';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String marketsBrowse = '/markets-browse';
  static const String buyOrderTicket = '/buy-order-ticket';
  static const String enhancedOrderTicket = '/enhanced-order-ticket';
  static const String sellOrderTicket = '/sell-order-ticket';
  static const String portfolioHoldings = '/portfolio-holdings';
  static const String userProfileSettings = '/user-profile-settings';
  static const String instrumentDetail = '/instrument-detail';
  static const String registration = '/registration-screen';
  static const String dashboardHome = '/dashboard-home';
  static const String educationOnboardingSlides =
      '/education-onboarding-slides';
  static const String learnTabFaq = '/learn-tab-faq';
  static const String priceAdminPanel = '/price-admin-panel';
  static const String boApplicationForm = '/bo-application-form';
  static const String boAdminPanel = '/bo-admin-panel';
  static const String notificationsScreen = '/notifications-screen';
  static const String boAccountOpeningWizard = '/bo-account-opening-wizard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    learnHub: (context) => const LearnHub(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    marketsBrowse: (context) => const MarketsBrowse(),
    buyOrderTicket: (context) => const BuyOrderTicket(),
    enhancedOrderTicket: (context) => const EnhancedOrderTicket(),
    sellOrderTicket: (context) => const SellOrderTicket(),
    portfolioHoldings: (context) => const PortfolioHoldings(),
    userProfileSettings: (context) => const UserProfileSettings(),
    instrumentDetail: (context) => const InstrumentDetail(),
    registration: (context) => const RegistrationScreen(),
    dashboardHome: (context) => const DashboardHome(),
    educationOnboardingSlides: (context) => const EducationOnboardingSlides(),
    learnTabFaq: (context) => const LearnTabFaq(),
    priceAdminPanel: (context) => const PriceAdminPanel(),
    boApplicationForm: (context) => const BoApplicationForm(),
    boAdminPanel: (context) => const BoAdminPanel(),
    notificationsScreen: (context) => const NotificationsScreen(),
    boAccountOpeningWizard: (context) => const BoAccountOpeningWizard(),
    // TODO: Add your other routes here
  };
}
