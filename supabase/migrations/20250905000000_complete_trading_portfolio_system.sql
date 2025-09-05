-- Location: supabase/migrations/20250905000000_complete_trading_portfolio_system.sql
-- Schema Analysis: Existing schema has user_profiles, bo_applications, notifications
-- Integration Type: Addition - Adding complete trading and portfolio system
-- Dependencies: user_profiles (existing)

-- 1. Create Trading System Types
CREATE TYPE public.order_status AS ENUM ('pending', 'partial', 'filled', 'cancelled', 'rejected');
CREATE TYPE public.order_type AS ENUM ('market', 'limit');
CREATE TYPE public.order_side AS ENUM ('buy', 'sell');
CREATE TYPE public.instrument_type AS ENUM ('stock', 'mutual_fund', 'bond', 'etf', 'commodity');
CREATE TYPE public.portfolio_type AS ENUM ('real', 'virtual');

-- 2. Add fantasy trading columns to existing user_profiles table
ALTER TABLE public.user_profiles
ADD COLUMN virtual_cash_available DECIMAL(15,2) DEFAULT 50000.00,
ADD COLUMN virtual_cash_reserved DECIMAL(15,2) DEFAULT 0.00,
ADD COLUMN virtual_starting_balance DECIMAL(15,2) DEFAULT 50000.00,
ADD COLUMN trading_enabled BOOLEAN DEFAULT true,
ADD COLUMN risk_score INTEGER DEFAULT 5;

-- Create index for trading-enabled users
CREATE INDEX idx_user_profiles_trading ON public.user_profiles(trading_enabled);

-- 3. Create Instruments Table
CREATE TABLE public.instruments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    instrument_type public.instrument_type DEFAULT 'stock'::public.instrument_type,
    sector TEXT,
    last_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    day_change DECIMAL(10,2) DEFAULT 0.00,
    day_change_percent DECIMAL(5,2) DEFAULT 0.00,
    volume BIGINT DEFAULT 0,
    market_cap DECIMAL(20,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create User Positions Table (Portfolio Holdings)
CREATE TABLE public.user_positions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    instrument_id UUID REFERENCES public.instruments(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0,
    avg_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    market_value DECIMAL(15,2) DEFAULT 0.00,
    unrealized_pnl DECIMAL(15,2) DEFAULT 0.00,
    unrealized_pnl_percent DECIMAL(5,2) DEFAULT 0.00,
    portfolio_type public.portfolio_type DEFAULT 'virtual'::public.portfolio_type,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, instrument_id, portfolio_type)
);

-- 5. Create Orders Table
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    instrument_id UUID REFERENCES public.instruments(id) ON DELETE CASCADE,
    order_type public.order_type NOT NULL,
    order_side public.order_side NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2),
    filled_quantity INTEGER DEFAULT 0,
    avg_fill_price DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(15,2) NOT NULL,
    status public.order_status DEFAULT 'pending'::public.order_status,
    portfolio_type public.portfolio_type DEFAULT 'virtual'::public.portfolio_type,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    filled_at TIMESTAMPTZ
);

-- 6. Create Trades Table (Order Executions)
CREATE TABLE public.trades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    instrument_id UUID REFERENCES public.instruments(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    order_side public.order_side NOT NULL,
    portfolio_type public.portfolio_type DEFAULT 'virtual'::public.portfolio_type,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Create Portfolio Summary Table
CREATE TABLE public.portfolio_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    portfolio_type public.portfolio_type DEFAULT 'virtual'::public.portfolio_type,
    total_value DECIMAL(15,2) DEFAULT 0.00,
    cash_available DECIMAL(15,2) DEFAULT 0.00,
    cash_reserved DECIMAL(15,2) DEFAULT 0.00,
    holdings_value DECIMAL(15,2) DEFAULT 0.00,
    day_change DECIMAL(15,2) DEFAULT 0.00,
    day_change_percent DECIMAL(5,2) DEFAULT 0.00,
    total_pnl DECIMAL(15,2) DEFAULT 0.00,
    total_pnl_percent DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, portfolio_type)
);

-- 8. Create Essential Indexes
CREATE INDEX idx_instruments_symbol ON public.instruments(symbol);
CREATE INDEX idx_instruments_type ON public.instruments(instrument_type);
CREATE INDEX idx_instruments_active ON public.instruments(is_active);

CREATE INDEX idx_user_positions_user_id ON public.user_positions(user_id);
CREATE INDEX idx_user_positions_instrument_id ON public.user_positions(instrument_id);
CREATE INDEX idx_user_positions_portfolio_type ON public.user_positions(portfolio_type);

CREATE INDEX idx_orders_user_id ON public.orders(user_id);
CREATE INDEX idx_orders_instrument_id ON public.orders(instrument_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_created_at ON public.orders(created_at DESC);

CREATE INDEX idx_trades_order_id ON public.trades(order_id);
CREATE INDEX idx_trades_user_id ON public.trades(user_id);
CREATE INDEX idx_trades_created_at ON public.trades(created_at DESC);

CREATE INDEX idx_portfolio_summary_user_id ON public.portfolio_summary(user_id);

-- 9. Create Functions BEFORE RLS Policies

-- Function to calculate portfolio metrics
CREATE OR REPLACE FUNCTION public.calculate_portfolio_metrics(user_uuid UUID)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
DECLARE
    cash_available DECIMAL(15,2);
    holdings_value DECIMAL(15,2);
    total_value DECIMAL(15,2);
BEGIN
    -- Get cash available
    SELECT virtual_cash_available INTO cash_available 
    FROM public.user_profiles 
    WHERE id = user_uuid;
    
    -- Calculate holdings value
    SELECT COALESCE(SUM(quantity * i.last_price), 0) INTO holdings_value
    FROM public.user_positions up
    JOIN public.instruments i ON up.instrument_id = i.id
    WHERE up.user_id = user_uuid;
    
    total_value := COALESCE(cash_available, 0) + COALESCE(holdings_value, 0);
    
    RETURN jsonb_build_object(
        'cash_available', COALESCE(cash_available, 0),
        'holdings_value', COALESCE(holdings_value, 0),
        'total_value', total_value
    );
END;
$func$;

-- Function to execute trade orders atomically
CREATE OR REPLACE FUNCTION public.execute_trade_order(
    p_user_id UUID,
    p_instrument_symbol TEXT,
    p_order_type TEXT,
    p_quantity INTEGER,
    p_exec_price DECIMAL(10,2)
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_instrument_id UUID;
    v_order_id UUID;
    v_total_amount DECIMAL(15,2);
    v_current_cash DECIMAL(15,2);
    v_current_position INTEGER := 0;
    v_current_avg_price DECIMAL(10,2) := 0.00;
    v_new_quantity INTEGER;
    v_new_avg_price DECIMAL(10,2);
BEGIN
    -- Get instrument ID
    SELECT id INTO v_instrument_id 
    FROM public.instruments 
    WHERE symbol = p_instrument_symbol AND is_active = true;
    
    IF v_instrument_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Instrument not found');
    END IF;
    
    v_total_amount := p_quantity * p_exec_price;
    
    -- Get current cash
    SELECT virtual_cash_available INTO v_current_cash
    FROM public.user_profiles
    WHERE id = p_user_id;
    
    -- Get current position
    SELECT quantity, avg_price INTO v_current_position, v_current_avg_price
    FROM public.user_positions
    WHERE user_id = p_user_id AND instrument_id = v_instrument_id;
    
    IF p_order_type = 'buy' THEN
        -- Check sufficient funds
        IF v_current_cash < v_total_amount THEN
            RETURN jsonb_build_object('success', false, 'error', 'Insufficient funds');
        END IF;
        
        -- Deduct cash
        UPDATE public.user_profiles
        SET virtual_cash_available = virtual_cash_available - v_total_amount
        WHERE id = p_user_id;
        
        -- Calculate new position
        v_new_quantity := COALESCE(v_current_position, 0) + p_quantity;
        v_new_avg_price := ((COALESCE(v_current_position, 0) * COALESCE(v_current_avg_price, 0)) + v_total_amount) / v_new_quantity;
        
        -- Update or insert position
        INSERT INTO public.user_positions (user_id, instrument_id, quantity, avg_price)
        VALUES (p_user_id, v_instrument_id, v_new_quantity, v_new_avg_price)
        ON CONFLICT (user_id, instrument_id, portfolio_type)
        DO UPDATE SET
            quantity = v_new_quantity,
            avg_price = v_new_avg_price,
            updated_at = CURRENT_TIMESTAMP;
    
    ELSIF p_order_type = 'sell' THEN
        -- Check sufficient position
        IF COALESCE(v_current_position, 0) < p_quantity THEN
            RETURN jsonb_build_object('success', false, 'error', 'Insufficient position');
        END IF;
        
        -- Add cash
        UPDATE public.user_profiles
        SET virtual_cash_available = virtual_cash_available + v_total_amount
        WHERE id = p_user_id;
        
        -- Update position
        v_new_quantity := v_current_position - p_quantity;
        
        IF v_new_quantity = 0 THEN
            DELETE FROM public.user_positions
            WHERE user_id = p_user_id AND instrument_id = v_instrument_id;
        ELSE
            UPDATE public.user_positions
            SET quantity = v_new_quantity, updated_at = CURRENT_TIMESTAMP
            WHERE user_id = p_user_id AND instrument_id = v_instrument_id;
        END IF;
    END IF;
    
    -- Create order record
    INSERT INTO public.orders (user_id, instrument_id, order_type, order_side, quantity, price, filled_quantity, avg_fill_price, total_amount, status, filled_at)
    VALUES (p_user_id, v_instrument_id, p_order_type::public.order_type, p_order_type::public.order_side, p_quantity, p_exec_price, p_quantity, p_exec_price, v_total_amount, 'filled'::public.order_status, CURRENT_TIMESTAMP)
    RETURNING id INTO v_order_id;
    
    -- Create trade record
    INSERT INTO public.trades (order_id, user_id, instrument_id, quantity, price, total_amount, order_side)
    VALUES (v_order_id, p_user_id, v_instrument_id, p_quantity, p_exec_price, v_total_amount, p_order_type::public.order_side);
    
    RETURN jsonb_build_object('success', true, 'message', 'Order executed successfully', 'order_id', v_order_id);
END;
$func$;

-- Update trigger function
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- 10. Enable RLS
ALTER TABLE public.instruments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_summary ENABLE ROW LEVEL SECURITY;

-- 11. Create RLS Policies

-- Pattern 4: Public read for instruments (market data), admin write
CREATE POLICY "public_can_read_instruments"
ON public.instruments
FOR SELECT
TO public
USING (true);

CREATE POLICY "admin_manage_instruments"
ON public.instruments
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for user_positions
CREATE POLICY "users_manage_own_user_positions"
ON public.user_positions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for orders
CREATE POLICY "users_manage_own_orders"
ON public.orders
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for trades
CREATE POLICY "users_manage_own_trades"
ON public.trades
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for portfolio_summary
CREATE POLICY "users_manage_own_portfolio_summary"
ON public.portfolio_summary
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 12. Create Triggers
CREATE TRIGGER instruments_updated_at
    BEFORE UPDATE ON public.instruments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER user_positions_updated_at
    BEFORE UPDATE ON public.user_positions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER portfolio_summary_updated_at
    BEFORE UPDATE ON public.portfolio_summary
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- 13. Insert Mock Trading Data
DO $$
DECLARE
    existing_user_id UUID;
    inst1_id UUID := gen_random_uuid();
    inst2_id UUID := gen_random_uuid();
    inst3_id UUID := gen_random_uuid();
    inst4_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Insert instruments (market data)
        INSERT INTO public.instruments (id, symbol, name, instrument_type, last_price, day_change, day_change_percent, volume, sector, is_active) VALUES
            (inst1_id, 'SQURPHARMA', 'Square Pharmaceuticals Ltd', 'stock', 268.75, 23.25, 9.49, 150000, 'Healthcare', true),
            (inst2_id, 'BRACBANK', 'BRAC Bank Limited', 'stock', 45.80, 3.50, 8.27, 320000, 'Banking', true),
            (inst3_id, 'VGBLFX', 'VANGUARD Balanced Fund', 'mutual_fund', 175.90, -4.35, -2.41, 25000, 'Investment', true),
            (inst4_id, 'GOLD', 'Gold ETF', 'etf', 535.25, 15.25, 2.93, 45000, 'Commodity', true);

        -- Create sample positions for the user
        INSERT INTO public.user_positions (user_id, instrument_id, quantity, avg_price, market_value, unrealized_pnl, unrealized_pnl_percent) VALUES
            (existing_user_id, inst1_id, 50, 245.50, 13437.50, 1162.50, 9.49),
            (existing_user_id, inst2_id, 100, 42.30, 4580.00, 350.00, 8.27),
            (existing_user_id, inst3_id, 25, 180.25, 4397.50, -108.75, -2.41),
            (existing_user_id, inst4_id, 10, 520.00, 5352.50, 152.50, 2.93);

        -- Create sample order history
        INSERT INTO public.orders (user_id, instrument_id, order_type, order_side, quantity, price, filled_quantity, avg_fill_price, total_amount, status, filled_at) VALUES
            (existing_user_id, inst1_id, 'market', 'buy', 50, 245.50, 50, 245.50, 12275.00, 'filled', CURRENT_TIMESTAMP - INTERVAL '7 days'),
            (existing_user_id, inst2_id, 'limit', 'buy', 100, 42.30, 100, 42.30, 4230.00, 'filled', CURRENT_TIMESTAMP - INTERVAL '5 days'),
            (existing_user_id, inst3_id, 'market', 'buy', 25, 180.25, 25, 180.25, 4506.25, 'filled', CURRENT_TIMESTAMP - INTERVAL '3 days'),
            (existing_user_id, inst4_id, 'limit', 'buy', 10, 520.00, 10, 520.00, 5200.00, 'filled', CURRENT_TIMESTAMP - INTERVAL '1 day');

        -- Update user cash (they spent money on stocks)
        UPDATE public.user_profiles 
        SET virtual_cash_available = 23788.75 -- 50000 - total spent on positions
        WHERE id = existing_user_id;

        -- Create portfolio summary
        INSERT INTO public.portfolio_summary (user_id, total_value, cash_available, holdings_value, day_change, total_pnl) VALUES
            (existing_user_id, 51555.50, 23788.75, 27766.75, 1556.00, 1555.50);
    END IF;
END $$;