import 'package:flutter/foundation.dart';
import '../core/supabase_service.dart';

/// Enhanced Portfolio Service for real-time portfolio management
class PortfolioService {
  static final PortfolioService _instance = PortfolioService._internal();
  factory PortfolioService() => _instance;
  PortfolioService._internal();

  static PortfolioService get instance => _instance;

  final _client = SupabaseService.instance.client;

  /// Get comprehensive portfolio data with real-time metrics
  Future<Map<String, dynamic>> getPortfolioData(String userId) async {
    try {
      // Get portfolio summary
      final summary = await _client
          .from('portfolio_summary')
          .select('*')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .maybeSingle();

      // Get user positions with instrument details
      final positions = await _client
          .from('user_positions')
          .select('''
            *,
            instruments!inner(
              symbol,
              name,
              last_price,
              day_change,
              day_change_percent,
              sector
            )
          ''')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .gt('quantity', 0)
          .order('market_value', ascending: false);

      // Get recent transactions
      final recentTrades = await _client
          .from('trades')
          .select('''
            *,
            instruments!inner(symbol, name)
          ''')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .order('created_at', ascending: false)
          .limit(10);

      // Calculate additional metrics
      final totalInvestment = positions.fold<double>(
        0.0,
        (sum, pos) =>
            sum +
            ((pos['quantity'] as int) * (pos['avg_price'] as num).toDouble()),
      );

      final currentValue = positions.fold<double>(
        0.0,
        (sum, pos) => sum + ((pos['market_value'] as num?)?.toDouble() ?? 0.0),
      );

      final dayChange = positions.fold<double>(
        0.0,
        (sum, pos) {
          final quantity = pos['quantity'] as int;
          final dayChangePercent =
              (pos['instruments']['day_change_percent'] as num?)?.toDouble() ??
                  0.0;
          final marketValue = (pos['market_value'] as num?)?.toDouble() ?? 0.0;
          return sum + (marketValue * dayChangePercent / 100);
        },
      );

      return {
        'summary': summary ?? _createEmptyPortfolioSummary(userId),
        'positions': positions,
        'recent_trades': recentTrades,
        'metrics': {
          'total_investment': totalInvestment,
          'current_value': currentValue,
          'total_pnl': currentValue - totalInvestment,
          'total_pnl_percent': totalInvestment > 0
              ? ((currentValue - totalInvestment) / totalInvestment) * 100
              : 0.0,
          'day_change': dayChange,
          'day_change_percent':
              currentValue > 0 ? (dayChange / currentValue) * 100 : 0.0,
        },
      };
    } catch (e) {
      debugPrint('Error fetching portfolio data: $e');
      throw Exception('Failed to fetch portfolio data: $e');
    }
  }

  /// Get performance analytics for the portfolio
  Future<Map<String, dynamic>> getPortfolioAnalytics(
    String userId, {
    int daysBack = 30,
  }) async {
    try {
      // Get historical trades for performance calculation
      final trades = await _client
          .from('trades')
          .select('*')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(Duration(days: daysBack))
                  .toIso8601String())
          .order('created_at', ascending: true);

      // Calculate sector allocation
      final positions = await _client
          .from('user_positions')
          .select('''
            *,
            instruments!inner(sector)
          ''')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .gt('quantity', 0);

      // Group by sector
      final sectorAllocation = <String, double>{};
      double totalValue = 0.0;

      for (final position in positions) {
        final sector =
            position['instruments']['sector'] as String? ?? 'Unknown';
        final marketValue =
            (position['market_value'] as num?)?.toDouble() ?? 0.0;
        sectorAllocation[sector] =
            (sectorAllocation[sector] ?? 0.0) + marketValue;
        totalValue += marketValue;
      }

      // Convert to percentages
      final sectorPercentages = sectorAllocation.map(
        (sector, value) =>
            MapEntry(sector, totalValue > 0 ? (value / totalValue) * 100 : 0.0),
      );

      // Calculate trading activity
      final buyTrades = trades.where((t) => t['order_side'] == 'buy').length;
      final sellTrades = trades.where((t) => t['order_side'] == 'sell').length;
      final totalVolume = trades.fold<double>(
        0.0,
        (sum, trade) =>
            sum + ((trade['total_amount'] as num?)?.toDouble() ?? 0.0),
      );

      return {
        'sector_allocation': sectorPercentages,
        'trading_activity': {
          'total_trades': trades.length,
          'buy_trades': buyTrades,
          'sell_trades': sellTrades,
          'total_volume': totalVolume,
          'avg_trade_size':
              trades.isNotEmpty ? totalVolume / trades.length : 0.0,
        },
        'top_performers': await _getTopPerformers(userId),
        'worst_performers': await _getWorstPerformers(userId),
      };
    } catch (e) {
      debugPrint('Error fetching portfolio analytics: $e');
      throw Exception('Failed to fetch portfolio analytics: $e');
    }
  }

  /// Get top performing positions
  Future<List<Map<String, dynamic>>> _getTopPerformers(String userId) async {
    try {
      final response = await _client
          .from('user_positions')
          .select('''
            *,
            instruments!inner(symbol, name)
          ''')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .gt('quantity', 0)
          .gt('unrealized_pnl_percent', 0)
          .order('unrealized_pnl_percent', ascending: false)
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching top performers: $e');
      return [];
    }
  }

  /// Get worst performing positions
  Future<List<Map<String, dynamic>>> _getWorstPerformers(String userId) async {
    try {
      final response = await _client
          .from('user_positions')
          .select('''
            *,
            instruments!inner(symbol, name)
          ''')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .gt('quantity', 0)
          .lt('unrealized_pnl_percent', 0)
          .order('unrealized_pnl_percent', ascending: true)
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching worst performers: $e');
      return [];
    }
  }

  /// Get watchlist (mock implementation - could be extended to use actual watchlist table)
  Future<List<Map<String, dynamic>>> getWatchlist(String userId) async {
    try {
      // For now, return trending instruments
      final response = await _client
          .from('instruments')
          .select('*')
          .eq('is_active', true)
          .order('day_change_percent', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching watchlist: $e');
      return [];
    }
  }

  /// Subscribe to real-time portfolio updates
  Stream<Map<String, dynamic>> subscribeToPortfolioUpdates(String userId) {
    return _client
        .from('user_positions')
        .stream(primaryKey: ['id'])
        .where((data) => data.any((item) => 
            item['user_id'] == userId && 
            item['portfolio_type'] == 'virtual'))
        .map((data) => {'positions': data});
  }

  /// Create empty portfolio summary for new users
  Map<String, dynamic> _createEmptyPortfolioSummary(String userId) {
    return {
      'id': null,
      'user_id': userId,
      'portfolio_type': 'virtual',
      'total_value': 0.0,
      'cash_available': 50000.0, // Default virtual cash
      'cash_reserved': 0.0,
      'holdings_value': 0.0,
      'total_pnl': 0.0,
      'total_pnl_percent': 0.0,
      'day_change': 0.0,
      'day_change_percent': 0.0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}