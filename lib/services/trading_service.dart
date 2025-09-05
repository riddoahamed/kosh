import 'package:flutter/foundation.dart';
import '../core/supabase_service.dart';

/// Enhanced Trading Service with real Supabase integration
/// Handles buy/sell operations, order management, and portfolio updates
class TradingService {
  static final TradingService _instance = TradingService._internal();
  factory TradingService() => _instance;
  TradingService._internal();

  static TradingService get instance => _instance;

  final _client = SupabaseService.instance.client;

  /// Get active instruments for trading
  Future<List<Map<String, dynamic>>> getActiveInstruments({
    String? searchQuery,
    String? sector,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('instruments').select('*').eq('is_active', true);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('symbol.ilike.%${searchQuery}%,name.ilike.%${searchQuery}%');
      }

      if (sector != null && sector.isNotEmpty) {
        query = query.eq('sector', sector);
      }

      final response =
          await query.order('symbol', ascending: true).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching instruments: $e');
      throw Exception('Failed to fetch instruments: $e');
    }
  }

  /// Get instrument by symbol
  Future<Map<String, dynamic>?> getInstrumentBySymbol(String symbol) async {
    try {
      final response = await _client
          .from('instruments')
          .select('*')
          .eq('symbol', symbol)
          .eq('is_active', true)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching instrument: $e');
      throw Exception('Failed to fetch instrument: $e');
    }
  }

  /// Execute a buy order using the database function
  Future<Map<String, dynamic>> executeBuyOrder({
    required String userId,
    required String instrumentSymbol,
    required int quantity,
    required double price,
  }) async {
    try {
      // First verify user has sufficient balance
      final userProfile = await _client
          .from('user_profiles')
          .select('virtual_cash_available')
          .eq('id', userId)
          .single();

      final availableBalance =
          (userProfile['virtual_cash_available'] as num).toDouble();
      final totalCost = quantity * price;

      if (availableBalance < totalCost) {
        return {
          'success': false,
          'error':
              'Insufficient balance. Available: ৳${availableBalance.toStringAsFixed(2)}, Required: ৳${totalCost.toStringAsFixed(2)}'
        };
      }

      // Execute the trade using the database function
      final result = await _client.rpc('execute_trade_order', params: {
        'p_user_id': userId,
        'p_instrument_symbol': instrumentSymbol,
        'p_order_type': 'buy',
        'p_quantity': quantity,
        'p_exec_price': price,
      });

      // Update portfolio summary after successful trade
      if (result['success'] == true) {
        await _updatePortfolioSummary(userId);
      }

      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('Error executing buy order: $e');
      return {'success': false, 'error': 'Failed to execute buy order: $e'};
    }
  }

  /// Execute a sell order using the database function
  Future<Map<String, dynamic>> executeSellOrder({
    required String userId,
    required String instrumentSymbol,
    required int quantity,
    required double price,
  }) async {
    try {
      // First verify user has sufficient position
      final position = await getUserPosition(userId, instrumentSymbol);
      if (position == null || position['quantity'] < quantity) {
        return {
          'success': false,
          'error':
              'Insufficient position. Available: ${position?['quantity'] ?? 0}, Required: $quantity'
        };
      }

      // Execute the trade using the database function
      final result = await _client.rpc('execute_trade_order', params: {
        'p_user_id': userId,
        'p_instrument_symbol': instrumentSymbol,
        'p_order_type': 'sell',
        'p_quantity': quantity,
        'p_exec_price': price,
      });

      // Update portfolio summary after successful trade
      if (result['success'] == true) {
        await _updatePortfolioSummary(userId);
      }

      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('Error executing sell order: $e');
      return {'success': false, 'error': 'Failed to execute sell order: $e'};
    }
  }

  /// Get user's position for a specific instrument
  Future<Map<String, dynamic>?> getUserPosition(
      String userId, String instrumentSymbol) async {
    try {
      final response = await _client
          .from('user_positions')
          .select('*, instruments!inner(symbol)')
          .eq('user_id', userId)
          .eq('instruments.symbol', instrumentSymbol)
          .eq('portfolio_type', 'virtual')
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching user position: $e');
      return null;
    }
  }

  /// Get all user positions
  Future<List<Map<String, dynamic>>> getUserPositions(String userId) async {
    try {
      final response = await _client
          .from('user_positions')
          .select('*, instruments!inner(*)')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .gt('quantity', 0)
          .order('market_value', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching user positions: $e');
      throw Exception('Failed to fetch positions: $e');
    }
  }

  /// Get user's order history
  Future<List<Map<String, dynamic>>> getUserOrders({
    required String userId,
    int limit = 20,
    String? status,
  }) async {
    try {
      var query = _client
          .from('orders')
          .select('*, instruments!inner(symbol, name)')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual');

      if (status != null) {
        query = query.eq('status', status);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Get recent trades
  Future<List<Map<String, dynamic>>> getRecentTrades({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('trades')
          .select('*, instruments!inner(symbol, name)')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching recent trades: $e');
      throw Exception('Failed to fetch recent trades: $e');
    }
  }

  /// Update portfolio summary using database function
  Future<void> _updatePortfolioSummary(String userId) async {
    try {
      // Calculate portfolio metrics using the database function
      final metrics = await _client.rpc('calculate_portfolio_metrics', params: {
        'user_uuid': userId,
      });

      // Update or insert portfolio summary
      await _client.from('portfolio_summary').upsert({
        'user_id': userId,
        'portfolio_type': 'virtual',
        'total_value': metrics['total_value'],
        'cash_available': metrics['cash_available'],
        'holdings_value': metrics['holdings_value'],
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,portfolio_type');

      // Update user positions with current market values
      await _updateUserPositionsMarketValue(userId);
    } catch (e) {
      debugPrint('Error updating portfolio summary: $e');
    }
  }

  /// Update market values for all user positions
  Future<void> _updateUserPositionsMarketValue(String userId) async {
    try {
      final positions = await _client
          .from('user_positions')
          .select('*, instruments!inner(last_price)')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual');

      for (final position in positions) {
        final quantity = position['quantity'] as int;
        final lastPrice =
            (position['instruments']['last_price'] as num).toDouble();
        final avgPrice = (position['avg_price'] as num).toDouble();

        final marketValue = quantity * lastPrice;
        final unrealizedPnl = marketValue - (quantity * avgPrice);
        final unrealizedPnlPercent =
            avgPrice > 0 ? (unrealizedPnl / (quantity * avgPrice)) * 100 : 0.0;

        await _client.from('user_positions').update({
          'market_value': marketValue,
          'unrealized_pnl': unrealizedPnl,
          'unrealized_pnl_percent': unrealizedPnlPercent,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', position['id']);
      }
    } catch (e) {
      debugPrint('Error updating positions market value: $e');
    }
  }

  /// Get portfolio summary
  Future<Map<String, dynamic>?> getPortfolioSummary(String userId) async {
    try {
      final response = await _client
          .from('portfolio_summary')
          .select('*')
          .eq('user_id', userId)
          .eq('portfolio_type', 'virtual')
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching portfolio summary: $e');
      return null;
    }
  }

  /// Subscribe to real-time price updates
  Stream<Map<String, dynamic>> subscribeToPriceUpdates() {
    return _client
        .from('instruments')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .map((data) => {'instruments': data});
  }

  /// Subscribe to user's order updates
  Stream<Map<String, dynamic>> subscribeToUserOrders(String userId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => {'orders': data});
  }
}
