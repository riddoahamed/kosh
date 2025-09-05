-- Location: supabase/migrations/20250904223500_enhanced_bo_applications_system.sql
-- Schema Analysis: Existing bo_applications table with basic fields (nid, mobile, full_name, bank_account, date_of_birth, status)
-- Integration Type: Enhancement - Adding BSEC-compliant fields to existing table
-- Dependencies: Existing bo_applications table, user_profiles table, storage system

-- Add comprehensive BSEC-compliant fields to existing bo_applications table
ALTER TABLE public.bo_applications 
ADD COLUMN IF NOT EXISTS father_name TEXT,
ADD COLUMN IF NOT EXISTS mother_name TEXT,
ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')),
ADD COLUMN IF NOT EXISTS marital_status TEXT CHECK (marital_status IN ('Single', 'Married', 'Divorced', 'Widowed')),
ADD COLUMN IF NOT EXISTS occupation TEXT,
ADD COLUMN IF NOT EXISTS monthly_income BIGINT,
ADD COLUMN IF NOT EXISTS present_address TEXT,
ADD COLUMN IF NOT EXISTS permanent_address TEXT,
ADD COLUMN IF NOT EXISTS bank_name TEXT,
ADD COLUMN IF NOT EXISTS bank_branch TEXT,
ADD COLUMN IF NOT EXISTS bank_routing_number TEXT,
ADD COLUMN IF NOT EXISTS nominee_name TEXT,
ADD COLUMN IF NOT EXISTS nominee_relation TEXT,
ADD COLUMN IF NOT EXISTS nominee_percentage DECIMAL(5,2) DEFAULT 100.00,
ADD COLUMN IF NOT EXISTS nominee_nid TEXT,
ADD COLUMN IF NOT EXISTS nominee_address TEXT,
ADD COLUMN IF NOT EXISTS risk_tolerance TEXT CHECK (risk_tolerance IN ('Conservative', 'Moderate', 'Aggressive')),
ADD COLUMN IF NOT EXISTS investment_experience TEXT CHECK (investment_experience IN ('Beginner', 'Intermediate', 'Advanced')),
ADD COLUMN IF NOT EXISTS annual_income_range TEXT,
ADD COLUMN IF NOT EXISTS investment_objectives TEXT,
ADD COLUMN IF NOT EXISTS nid_front_image_url TEXT,
ADD COLUMN IF NOT EXISTS nid_back_image_url TEXT,
ADD COLUMN IF NOT EXISTS selfie_image_url TEXT,
ADD COLUMN IF NOT EXISTS address_proof_image_url TEXT,
ADD COLUMN IF NOT EXISTS signature_image_url TEXT,
ADD COLUMN IF NOT EXISTS bo_id TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS application_step INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS step_data JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS rejection_reason TEXT,
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS review_notes TEXT;

-- Create storage buckets for BO application documents (private storage for sensitive documents)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('bo-documents', 'bo-documents', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- RLS policies for BO documents storage (Pattern 1: Private User Storage)
CREATE POLICY "users_view_own_bo_documents"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'bo-documents' AND owner = auth.uid());

CREATE POLICY "users_upload_own_bo_documents" 
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'bo-documents' 
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "users_update_own_bo_documents"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'bo-documents' AND owner = auth.uid())
WITH CHECK (bucket_id = 'bo-documents' AND owner = auth.uid());

CREATE POLICY "users_delete_own_bo_documents"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'bo-documents' AND owner = auth.uid());

-- Admin access to all BO documents for review purposes
CREATE POLICY "admins_view_all_bo_documents"
ON storage.objects
FOR SELECT
TO authenticated  
USING (
    bucket_id = 'bo-documents'
    AND EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_bo_applications_step ON public.bo_applications(application_step);
CREATE INDEX IF NOT EXISTS idx_bo_applications_bo_id ON public.bo_applications(bo_id);
CREATE INDEX IF NOT EXISTS idx_bo_applications_approved_at ON public.bo_applications(approved_at);

-- Function to generate unique BO ID
CREATE OR REPLACE FUNCTION public.generate_bo_id()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    new_bo_id TEXT;
    counter INTEGER := 0;
BEGIN
    LOOP
        -- Generate BO ID with format: BO + YYYYMMDD + 5-digit sequence
        new_bo_id := 'BO' || to_char(NOW(), 'YYYYMMDD') || 
                    LPAD((EXTRACT(epoch FROM NOW())::INTEGER % 100000)::TEXT, 5, '0');
        
        -- Check if this BO ID already exists
        IF NOT EXISTS (SELECT 1 FROM public.bo_applications WHERE bo_id = new_bo_id) THEN
            EXIT;
        END IF;
        
        counter := counter + 1;
        IF counter > 1000 THEN
            RAISE EXCEPTION 'Unable to generate unique BO ID after 1000 attempts';
        END IF;
    END LOOP;
    
    RETURN new_bo_id;
END;
$func$;

-- Function to approve BO application
CREATE OR REPLACE FUNCTION public.approve_bo_application(application_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    application_record RECORD;
    generated_bo_id TEXT;
BEGIN
    -- Check if user is admin
    IF NOT EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Unauthorized');
    END IF;

    -- Get application record
    SELECT * INTO application_record 
    FROM public.bo_applications 
    WHERE id = application_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Application not found');
    END IF;
    
    IF application_record.status != 'in_review' THEN
        RETURN jsonb_build_object('success', false, 'error', 'Application is not in review status');
    END IF;
    
    -- Generate unique BO ID
    generated_bo_id := public.generate_bo_id();
    
    -- Update application
    UPDATE public.bo_applications
    SET 
        status = 'approved'::public.bo_application_status,
        bo_id = generated_bo_id,
        approved_at = NOW(),
        updated_at = NOW()
    WHERE id = application_id;
    
    -- Create notification for user
    INSERT INTO public.notifications (user_id, title, content, notification_type)
    VALUES (
        application_record.user_id,
        'BO Account Approved!',
        'Congratulations! Your BO account has been approved. Your BO ID is: ' || generated_bo_id,
        'account_status'
    );
    
    RETURN jsonb_build_object('success', true, 'bo_id', generated_bo_id);
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$func$;

-- Function to reject BO application
CREATE OR REPLACE FUNCTION public.reject_bo_application(
    application_id UUID, 
    rejection_reason TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    application_record RECORD;
BEGIN
    -- Check if user is admin
    IF NOT EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Unauthorized');
    END IF;

    -- Get application record
    SELECT * INTO application_record 
    FROM public.bo_applications 
    WHERE id = application_id;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Application not found');
    END IF;
    
    -- Update application
    UPDATE public.bo_applications
    SET 
        status = 'rejected'::public.bo_application_status,
        rejection_reason = rejection_reason,
        updated_at = NOW()
    WHERE id = application_id;
    
    -- Create notification for user
    INSERT INTO public.notifications (user_id, title, content, notification_type)
    VALUES (
        application_record.user_id,
        'BO Account Application Update',
        'Your BO account application has been reviewed. Please check your profile for details.',
        'account_status'
    );
    
    RETURN jsonb_build_object('success', true, 'message', 'Application rejected successfully');
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$func$;

-- Function for users to check their BO application status
CREATE OR REPLACE FUNCTION public.get_user_bo_status()
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN
            jsonb_build_object(
                'has_application', false,
                'status', null,
                'bo_id', null
            )
        ELSE
            jsonb_build_object(
                'has_application', true,
                'status', MAX(status::text),
                'bo_id', MAX(bo_id),
                'application_step', MAX(application_step),
                'created_at', MAX(created_at),
                'approved_at', MAX(approved_at)
            )
    END
FROM public.bo_applications 
WHERE user_id = auth.uid();
$func$;

-- Add sample enhanced BO application data
DO $$
DECLARE
    existing_user_id UUID;
    existing_application_id UUID;
BEGIN
    -- Get existing user ID
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Check if application exists
        SELECT id INTO existing_application_id 
        FROM public.bo_applications 
        WHERE user_id = existing_user_id 
        LIMIT 1;
        
        -- Update existing application with enhanced data
        IF existing_application_id IS NOT NULL THEN
            UPDATE public.bo_applications
            SET 
                father_name = 'Ahmed Rahman',
                mother_name = 'Fatima Rahman',
                gender = 'Male',
                marital_status = 'Single',
                occupation = 'Software Engineer',
                monthly_income = 80000,
                present_address = 'House 123, Road 45, Dhanmondi, Dhaka-1205',
                permanent_address = 'Village Kamargaon, Mymensingh-2200',
                bank_name = 'Dutch Bangla Bank Ltd',
                bank_branch = 'Dhanmondi Branch',
                bank_routing_number = '090270327',
                nominee_name = 'Rashida Rahman',
                nominee_relation = 'Mother',
                nominee_percentage = 100.00,
                nominee_nid = '1234567890128',
                nominee_address = 'Village Kamargaon, Mymensingh-2200',
                risk_tolerance = 'Moderate',
                investment_experience = 'Intermediate',
                annual_income_range = '5-10 Lakh BDT',
                investment_objectives = 'Long-term wealth building and retirement planning',
                application_step = 8,
                step_data = jsonb_build_object(
                    'personal_details', jsonb_build_object('completed', true),
                    'nid_verification', jsonb_build_object('completed', true),
                    'bank_account', jsonb_build_object('completed', true),
                    'photo_verification', jsonb_build_object('completed', true),
                    'address_proof', jsonb_build_object('completed', true),
                    'nominee_information', jsonb_build_object('completed', true),
                    'risk_assessment', jsonb_build_object('completed', true)
                )
            WHERE id = existing_application_id;
            
            RAISE NOTICE 'Enhanced existing BO application with comprehensive data';
        ELSE
            RAISE NOTICE 'No existing BO application found to enhance';
        END IF;
    ELSE
        RAISE NOTICE 'No existing users found';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error updating BO application: %', SQLERRM;
END $$;

-- Create cleanup function for test data
CREATE OR REPLACE FUNCTION public.cleanup_bo_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    -- Delete test BO applications
    DELETE FROM public.bo_applications 
    WHERE nid LIKE '1234567890%' 
    OR nid LIKE '9876543210%';
    
    -- Delete test storage objects
    DELETE FROM storage.objects 
    WHERE bucket_id = 'bo-documents' 
    AND name LIKE '%/test_%';
    
    RAISE NOTICE 'BO test data cleanup completed';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'BO cleanup failed: %', SQLERRM;
END;
$func$;