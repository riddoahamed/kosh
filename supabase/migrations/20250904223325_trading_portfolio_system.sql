-- Location: supabase/migrations/20250904223325_trading_portfolio_system.sql
        -- Schema Analysis: Existing user_profiles table with proper structure
        -- Integration Type: Addition - Trading and Portfolio functionality
        -- Dependencies: user_profiles (existing table)

        -- 1. Create custom types for trading system
        CREATE TYPE public.order_status AS ENUM ('pending', 'filled', 'cancelled', 'rejected');
        CREATE TYPE public.order_type AS ENUM ('buy', 'sell');
        CREATE TYPE public.instrument_type AS ENUM ('stock', 'mutual_fund', 'gold', 'bond');

        -- 2. Add virtual cash fields to existing user_profiles table
        ALTER TABLE public.user_profiles 
        ADD COLUMN virtual_cash_available DECIMAL(15,2) DEFAULT 50000.00,
        ADD COLUMN virtual_cash_reserved DECIMAL(15,2) DEFAULT 0.00,
        ADD COLUMN virtual_starting_balance DECIMAL(15,2) DEFAULT 50000.00;

        -- 3. Create instruments table for trading data
        CREATE TABLE public.instruments (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            symbol TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            instrument_type public.instrument_type NOT NULL,
            sector TEXT,
            last_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            day_change DECIMAL(10,2) DEFAULT 0.00,
            day_change_percent DECIMAL(5,2) DEFAULT 0.00,
            day_high DECIMAL(10,2),
            day_low DECIMAL(10,2),
            year_high DECIMAL(10,2),
            year_low DECIMAL(10,2),
            market_cap TEXT,
            pe_ratio DECIMAL(8,2),
            dividend_yield DECIMAL(5,2),
            bid_price DECIMAL(10,2),
            ask_price DECIMAL(10,2),
            volume BIGINT DEFAULT 0,
            avg_volume BIGINT DEFAULT 0,
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
        );

        -- 4. Create orders table for trade execution
        CREATE TABLE public.trading_orders (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
            instrument_id UUID REFERENCES public.instruments(id) ON DELETE CASCADE,
            order_type public.order_type NOT NULL,
            quantity INTEGER NOT NULL CHECK (quantity > 0),
            order_price DECIMAL(10,2),
            exec_price DECIMAL(10,2),
            status public.order_status DEFAULT 'pending'::public.order_status,
            total_amount DECIMAL(15,2),
            created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
            executed_at TIMESTAMPTZ,
            updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
        );

        -- 5. Create positions table for portfolio management with VWAP
        CREATE TABLE public.user_positions (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
            instrument_id UUID REFERENCES public.instruments(id) ON DELETE CASCADE,
            quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
            avg_price DECIMAL(10,2) NOT NULL DEFAULT 0.00, -- VWAP calculation
            total_invested DECIMAL(15,2) NOT NULL DEFAULT 0.00,
            unrealized_pl DECIMAL(15,2) DEFAULT 0.00,
            realized_pl DECIMAL(15,2) DEFAULT 0.00,
            created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user_id, instrument_id)
        );

        -- 6. Create indexes for performance
        CREATE INDEX idx_instruments_symbol ON public.instruments(symbol);
        CREATE INDEX idx_instruments_type ON public.instruments(instrument_type);
        CREATE INDEX idx_trading_orders_user_id ON public.trading_orders(user_id);
        CREATE INDEX idx_trading_orders_instrument_id ON public.trading_orders(instrument_id);
        CREATE INDEX idx_trading_orders_status ON public.trading_orders(status);
        CREATE INDEX idx_user_positions_user_id ON public.user_positions(user_id);
        CREATE INDEX idx_user_positions_instrument_id ON public.user_positions(instrument_id);

        -- 7. Create atomic order execution function with VWAP and cash updates
        CREATE OR REPLACE FUNCTION public.execute_trade_order(
            p_user_id UUID,
            p_instrument_symbol TEXT,
            p_order_type public.order_type,
            p_quantity INTEGER,
            p_exec_price DECIMAL(10,2)
        )
        RETURNS JSON
        LANGUAGE plpgsql
        SECURITY DEFINER
        AS $func$
        DECLARE
            v_instrument_id UUID;
            v_total_amount DECIMAL(15,2);
            v_user_cash DECIMAL(15,2);
            v_order_id UUID;
            v_existing_position RECORD;
            v_new_avg_price DECIMAL(10,2);
            v_new_quantity INTEGER;
            v_result JSON;
        BEGIN
            -- Get instrument ID
            SELECT id INTO v_instrument_id 
            FROM public.instruments 
            WHERE symbol = p_instrument_symbol AND is_active = true;
            
            IF v_instrument_id IS NULL THEN
                RETURN json_build_object('success', false, 'error', 'Instrument not found');
            END IF;

            v_total_amount := p_quantity * p_exec_price;

            -- Start atomic transaction
            BEGIN
                IF p_order_type = 'buy' THEN
                    -- Check available cash
                    SELECT virtual_cash_available INTO v_user_cash
                    FROM public.user_profiles
                    WHERE id = p_user_id;
                    
                    IF v_user_cash < v_total_amount THEN
                        RETURN json_build_object('success', false, 'error', 'Insufficient cash');
                    END IF;

                    -- Update cash (reduce available, increase reserved)
                    UPDATE public.user_profiles
                    SET virtual_cash_available = virtual_cash_available - v_total_amount,
                        virtual_cash_reserved = virtual_cash_reserved + v_total_amount,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = p_user_id;

                    -- Get existing position for VWAP calculation
                    SELECT * INTO v_existing_position
                    FROM public.user_positions
                    WHERE user_id = p_user_id AND instrument_id = v_instrument_id;

                    IF v_existing_position.id IS NOT NULL THEN
                        -- Calculate new VWAP: (old_qty * old_avg + buy_qty * exec_price) / (old_qty + buy_qty)
                        v_new_quantity := v_existing_position.quantity + p_quantity;
                        v_new_avg_price := (
                            (v_existing_position.quantity * v_existing_position.avg_price) + 
                            (p_quantity * p_exec_price)
                        ) / v_new_quantity;

                        -- Update position with new VWAP
                        UPDATE public.user_positions
                        SET quantity = v_new_quantity,
                            avg_price = v_new_avg_price,
                            total_invested = total_invested + v_total_amount,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE id = v_existing_position.id;
                    ELSE
                        -- Create new position
                        INSERT INTO public.user_positions (user_id, instrument_id, quantity, avg_price, total_invested)
                        VALUES (p_user_id, v_instrument_id, p_quantity, p_exec_price, v_total_amount);
                    END IF;

                ELSE -- SELL order
                    -- Get existing position
                    SELECT * INTO v_existing_position
                    FROM public.user_positions
                    WHERE user_id = p_user_id AND instrument_id = v_instrument_id;

                    IF v_existing_position.id IS NULL OR v_existing_position.quantity < p_quantity THEN
                        RETURN json_build_object('success', false, 'error', 'Insufficient shares');
                    END IF;

                    -- Update cash (increase available)
                    UPDATE public.user_profiles
                    SET virtual_cash_available = virtual_cash_available + v_total_amount,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = p_user_id;

                    v_new_quantity := v_existing_position.quantity - p_quantity;
                    
                    IF v_new_quantity = 0 THEN
                        -- Delete position if quantity becomes 0
                        DELETE FROM public.user_positions WHERE id = v_existing_position.id;
                    ELSE
                        -- Update position quantity (VWAP remains same for sells)
                        UPDATE public.user_positions
                        SET quantity = v_new_quantity,
                            total_invested = total_invested - (p_quantity * v_existing_position.avg_price),
                            updated_at = CURRENT_TIMESTAMP
                        WHERE id = v_existing_position.id;
                    END IF;
                END IF;

                -- Create order record with filled status
                INSERT INTO public.trading_orders (
                    user_id, instrument_id, order_type, quantity, 
                    order_price, exec_price, status, total_amount, executed_at
                )
                VALUES (
                    p_user_id, v_instrument_id, p_order_type, p_quantity,
                    p_exec_price, p_exec_price, 'filled'::public.order_status, 
                    v_total_amount, CURRENT_TIMESTAMP
                )
                RETURNING id INTO v_order_id;

                -- Return success result
                v_result := json_build_object(
                    'success', true,
                    'order_id', v_order_id,
                    'message', format('%s order executed: %s shares of %s at ৳%s', 
                        UPPER(p_order_type::TEXT), p_quantity, p_instrument_symbol, p_exec_price)
                );

                RETURN v_result;

            EXCEPTION
                WHEN OTHERS THEN
                    RETURN json_build_object('success', false, 'error', SQLERRM);
            END;
        END;
        $func$;

        -- 8. Enable RLS on all new tables
        ALTER TABLE public.instruments ENABLE ROW LEVEL SECURITY;
        ALTER TABLE public.trading_orders ENABLE ROW LEVEL SECURITY;
        ALTER TABLE public.user_positions ENABLE ROW LEVEL SECURITY;

        -- 9. Create RLS policies using Pattern 2 and Pattern 4
        -- Instruments: Public read, no write for regular users
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

        -- Trading orders: Pattern 2 - Simple user ownership
        CREATE POLICY "users_manage_own_trading_orders"
        ON public.trading_orders
        FOR ALL
        TO authenticated
        USING (user_id = auth.uid())
        WITH CHECK (user_id = auth.uid());

        -- User positions: Pattern 2 - Simple user ownership
        CREATE POLICY "users_manage_own_user_positions"
        ON public.user_positions
        FOR ALL
        TO authenticated
        USING (user_id = auth.uid())
        WITH CHECK (user_id = auth.uid());

        -- 10. Create update triggers
        CREATE TRIGGER instruments_updated_at
            BEFORE UPDATE ON public.instruments
            FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

        CREATE TRIGGER trading_orders_updated_at
            BEFORE UPDATE ON public.trading_orders
            FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

        CREATE TRIGGER user_positions_updated_at
            BEFORE UPDATE ON public.user_positions
            FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

        -- 11. Insert mock instrument data
        DO $$
        DECLARE
            instrument_batbc UUID := gen_random_uuid();
            instrument_gp UUID := gen_random_uuid();
            instrument_sqrpharma UUID := gen_random_uuid();
            instrument_uttarafund UUID := gen_random_uuid();
            instrument_gold22k UUID := gen_random_uuid();
        BEGIN
            INSERT INTO public.instruments (
                id, symbol, name, instrument_type, sector, last_price, day_change, 
                day_change_percent, day_high, day_low, year_high, year_low, 
                market_cap, pe_ratio, dividend_yield, bid_price, ask_price, 
                volume, avg_volume
            ) VALUES
                (instrument_batbc, 'BATBC', 'British American Tobacco Bangladesh', 
                 'stock'::public.instrument_type, 'Consumer Goods', 485.20, 15.80, 3.37,
                 490.00, 478.50, 520.00, 420.00, '৳76,218 Cr', 22.1, 3.8, 
                 484.90, 485.50, 950000, 800000),
                 
                (instrument_gp, 'GP', 'GrameenPhone Ltd.', 
                 'stock'::public.instrument_type, 'Telecommunications', 312.80, 8.90, 2.93,
                 318.50, 308.20, 365.00, 280.00, '৳98,742 Cr', 15.2, 4.1,
                 312.50, 313.10, 1800000, 1500000),
                 
                (instrument_sqrpharma, 'SQRPHARMA', 'Square Pharmaceuticals Ltd.',
                 'stock'::public.instrument_type, 'Pharmaceuticals', 460.20, 12.50, 2.79,
                 465.00, 448.50, 520.00, 380.00, '৳43,218 Cr', 18.5, 3.2,
                 459.50, 460.70, 2500000, 1800000),
                 
                (instrument_uttarafund, 'UTTARAFUND', 'Uttra Finance & Investments Limited',
                 'mutual_fund'::public.instrument_type, 'Financial Services', 18.75, 0.85, 4.74,
                 19.20, 18.10, 22.50, 15.80, '৳2,850 Cr', 8.9, 5.2,
                 18.60, 18.90, 125000, 95000),
                 
                (instrument_gold22k, 'GOLD22K', 'Gold 22 Karat',
                 'gold'::public.instrument_type, 'Precious Metals', 6850.00, 125.00, 1.86,
                 6950.00, 6750.00, 7200.00, 6200.00, NULL, NULL, NULL,
                 6840.00, 6860.00, 5000, 4500);

        END $$;

        -- 12. Create portfolio summary view for easy data access
        CREATE OR REPLACE VIEW public.portfolio_summary AS
        SELECT 
            up.id as user_id,
            up.virtual_cash_available,
            up.virtual_starting_balance,
            COALESCE(SUM(pos.quantity * i.last_price), 0) as holdings_value,
            (up.virtual_cash_available + COALESCE(SUM(pos.quantity * i.last_price), 0)) as total_portfolio_value,
            COALESCE(SUM(pos.total_invested), 0) as total_invested,
            ((up.virtual_cash_available + COALESCE(SUM(pos.quantity * i.last_price), 0)) - up.virtual_starting_balance) as total_pl,
            COUNT(pos.id) as total_positions
        FROM public.user_profiles up
        LEFT JOIN public.user_positions pos ON up.id = pos.user_id
        LEFT JOIN public.instruments i ON pos.instrument_id = i.id
        WHERE up.is_active = true
        GROUP BY up.id, up.virtual_cash_available, up.virtual_starting_balance;