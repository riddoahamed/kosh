import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  late SupabaseClient _client;
  SupabaseClient get client => _client;

  Future<void> initialize() async {
    const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  // Trading System Methods

  /// Get user portfolio positions
  Future<List<dynamic>> getUserPositions(String userId) async {
    try {
      final response = await _client.from('user_positions').select('''
            *,
            instruments (
              symbol,
              name,
              instrument_type,
              last_price,
              day_change,
              day_change_percent
            )
          ''').eq('user_id', userId);
      return response;
    } catch (error) {
      throw Exception('Failed to fetch positions: $error');
    }
  }

  /// Execute a trade order
  Future<Map<String, dynamic>> executeTrade({
    required String userId,
    required String symbol,
    required String orderType, // 'buy' or 'sell'
    required int quantity,
    required double price,
  }) async {
    try {
      final response = await _client.rpc('execute_trade_order', params: {
        'p_user_id': userId,
        'p_instrument_symbol': symbol,
        'p_order_type': orderType,
        'p_quantity': quantity,
        'p_exec_price': price,
      });
      return response;
    } catch (error) {
      throw Exception('Trade execution failed: $error');
    }
  }

  /// Get user portfolio metrics
  Future<Map<String, dynamic>> getPortfolioMetrics(String userId) async {
    try {
      final response =
          await _client.rpc('calculate_portfolio_metrics', params: {
        'user_uuid': userId,
      });
      return response;
    } catch (error) {
      throw Exception('Failed to fetch portfolio metrics: $error');
    }
  }

  /// Get user profile with cash information
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select(
              '*, virtual_cash_available, virtual_cash_reserved, virtual_starting_balance')
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  /// Get market instruments
  Future<List<dynamic>> getInstruments({int limit = 50}) async {
    try {
      final response = await _client
          .from('instruments')
          .select()
          .eq('is_active', true)
          .order('volume', ascending: false)
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to fetch instruments: $error');
    }
  }

  /// Get user order history
  Future<List<dynamic>> getUserOrders(String userId, {int limit = 20}) async {
    try {
      final response = await _client
          .from('orders')
          .select('''
            *,
            instruments (
              symbol,
              name
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to fetch orders: $error');
    }
  }

  /// Subscribe to real-time portfolio changes
  Stream<List<Map<String, dynamic>>> subscribeToPortfolioUpdates(
      String userId) {
    return _client
        .from('user_positions')
        .stream(primaryKey: ['id']).eq('user_id', userId);
  }

  /// Subscribe to real-time user profile changes
  Stream<Map<String, dynamic>?> subscribeToUserProfile(String userId) {
    return _client
        .from('user_profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  /// Subscribe to real-time price updates
  Stream<List<Map<String, dynamic>>> subscribeToInstrumentUpdates() {
    return _client
        .from('instruments')
        .stream(primaryKey: ['id']).eq('is_active', true);
  }
}
