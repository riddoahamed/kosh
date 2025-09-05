-- Location: supabase/migrations/20250904220000_bo_applications_system.sql
-- Schema Analysis: Creating new BO Application system with user profiles relationship
-- Integration Type: New feature addition with authentication
-- Dependencies: auth.users (Supabase managed), user_profiles table creation

-- 1. Create user_profiles table (intermediary between auth and business logic)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create BO application status enum
CREATE TYPE public.bo_application_status AS ENUM (
    'submitted',
    'in_review', 
    'approved',
    'rejected'
);

-- 3. Create BO applications table
CREATE TABLE public.bo_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    nid TEXT NOT NULL,
    full_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    mobile TEXT NOT NULL,
    bank_account TEXT,
    status public.bo_application_status DEFAULT 'submitted'::public.bo_application_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create notifications table for in-app messaging
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL DEFAULT 'general',
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Create essential indexes for performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_bo_applications_user_id ON public.bo_applications(user_id);
CREATE INDEX idx_bo_applications_status ON public.bo_applications(status);
CREATE INDEX idx_bo_applications_created_at ON public.bo_applications(created_at);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at);

-- 6. Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bo_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 7. Create admin role checking function (uses auth metadata)
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

-- 8. RLS Policies using correct patterns

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Admin access to all user profiles
CREATE POLICY "admin_full_access_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for BO applications
CREATE POLICY "users_manage_own_bo_applications"
ON public.bo_applications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Admin access to all BO applications
CREATE POLICY "admin_full_access_bo_applications"
ON public.bo_applications
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for notifications
CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Admin access to all notifications (read only for admin panel)
CREATE POLICY "admin_read_all_notifications"
ON public.notifications
FOR SELECT
TO authenticated
USING (public.is_admin_from_auth());

-- 9. Function for automatic profile creation on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (
        id, 
        email, 
        full_name, 
        phone,
        role
    )
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'phone',
        COALESCE(NEW.raw_user_meta_data->>'role', 'user')
    );
    RETURN NEW;
END;
$$;

-- 10. Trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 11. Function to update user profile updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 12. Triggers for updated_at timestamps
CREATE TRIGGER user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER bo_applications_updated_at
    BEFORE UPDATE ON public.bo_applications
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- 13. Mock data for development and testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    user2_uuid UUID := gen_random_uuid();
    app1_uuid UUID := gen_random_uuid();
    app2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@kosh.com.bd', crypt('AdminPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "KOSH Admin", "role": "admin", "phone": "+8801712000001"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@example.com', crypt('UserPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sheikh Riddo", "phone": "+8801712345678"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'testuser@example.com', crypt('TestPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Test User", "phone": "+8801712345679"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create BO applications (user_profiles will be created by trigger)
    INSERT INTO public.bo_applications (id, user_id, nid, full_name, date_of_birth, mobile, bank_account, status, created_at)
    VALUES
        (app1_uuid, user_uuid, '1234567890123', 'Sheikh Riddo', '1990-05-15', '01712345678', '1234567890', 'submitted'::public.bo_application_status, now() - interval '2 days'),
        (app2_uuid, user2_uuid, '9876543210987', 'Test User', '1985-12-20', '01712345679', null, 'in_review'::public.bo_application_status, now() - interval '1 day');

    -- Create sample notifications
    INSERT INTO public.notifications (user_id, type, title, body, read, created_at)
    VALUES
        (user_uuid, 'bo_status', 'BO Application Received', 'Your BO application has been received and is under review.', false, now() - interval '1 day'),
        (user2_uuid, 'bo_status', 'BO Application In Review', 'We are processing your BO with our partner.', false, now() - interval '6 hours'),
        (user_uuid, 'system', 'Welcome to KOSH', 'Welcome to KOSH trading platform. Start your investment journey today!', true, now() - interval '3 days');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 14. Cleanup function for development (optional)
CREATE OR REPLACE FUNCTION public.cleanup_bo_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email IN ('admin@kosh.com.bd', 'user@example.com', 'testuser@example.com');

    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.notifications WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.bo_applications WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);
    
    RAISE NOTICE 'BO test data cleanup completed successfully';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;

-- Add helpful comment
COMMENT ON TABLE public.bo_applications IS 'Brokerage account opening applications with user data and status tracking';
COMMENT ON TABLE public.notifications IS 'In-app notifications for users about BO status and system updates';
COMMENT ON FUNCTION public.cleanup_bo_test_data() IS 'Development helper to clean up test data - use with caution';