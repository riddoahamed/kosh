import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/markets_browse/markets_browse.dart';
import '../presentation/instrument_detail/instrument_detail.dart';
import '../presentation/buy_order_ticket/buy_order_ticket.dart';
import '../presentation/sell_order_ticket/sell_order_ticket.dart';
import '../presentation/portfolio_holdings/portfolio_holdings.dart';
import '../presentation/notifications_center/notifications_center.dart';
import '../presentation/user_profile_settings/user_profile_settings.dart';
import '../presentation/learn_hub/learn_hub.dart';
import '../presentation/price_admin_panel/price_admin_panel.dart';
import '../presentation/bo_application_form/bo_application_form.dart';
import '../presentation/bo_admin_panel/bo_admin_panel.dart';
import '../presentation/bo_account_opening_wizard/bo_account_opening_wizard.dart';

class AppRoutes {
  // Core Routes
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String registration = '/registration-screen';
  static const String marketsBrowse = '/markets-browse';
  static const String instrumentDetail = '/instrument-detail';
  static const String buyOrderTicket = '/buy-order-ticket';
  static const String sellOrderTicket = '/sell-order-ticket';
  static const String portfolioHoldings = '/portfolio-holdings';
  static const String notificationsCenter = '/notifications-center';
  static const String userProfileSettings = '/user-profile-settings';

  // Learn (Simple FAQ)
  static const String learnHub = '/learn-hub';

  // Admin Routes
  static const String priceAdminPanel = '/price-admin-panel';
  static const String boApplicationForm = '/bo-application-form';
  static const String boAdminPanel = '/bo-admin-panel';
  static const String boAccountOpeningWizard = '/bo-account-opening-wizard';

  static Map<String, WidgetBuilder> routes = {
    // Core Navigation Flow
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    registration: (context) => const RegistrationScreen(),
    marketsBrowse: (context) => const MarketsBrowse(),
    instrumentDetail: (context) => const InstrumentDetail(),
    buyOrderTicket: (context) => const BuyOrderTicket(),
    sellOrderTicket: (context) => const SellOrderTicket(),
    portfolioHoldings: (context) => const PortfolioHoldings(),
    notificationsCenter: (context) => const NotificationsCenter(),
    userProfileSettings: (context) => const UserProfileSettings(),

    // Learn (Simple FAQ)
    learnHub: (context) => const LearnHub(),

    // Admin Routes
    priceAdminPanel: (context) => const PriceAdminPanel(),
    boApplicationForm: (context) => const BoApplicationForm(),
    boAdminPanel: (context) => const BoAdminPanel(),
    boAccountOpeningWizard: (context) => const BoAccountOpeningWizard(),
  };
}
