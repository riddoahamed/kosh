-- Location: supabase/migrations/20250905214800_add_onboarding_experience_fields.sql
-- Schema Analysis: Existing user_profiles table found with role, is_active, risk_score fields
-- Integration Type: Extension - Adding onboarding tracking fields
-- Dependencies: public.user_profiles (existing table)

-- Add experience level enum type
CREATE TYPE public.experience_level AS ENUM ('beginner', 'intermediate', 'experienced');

-- Add onboarding and experience fields to existing user_profiles table
ALTER TABLE public.user_profiles
ADD COLUMN has_onboarded BOOLEAN DEFAULT false,
ADD COLUMN experience_level public.experience_level DEFAULT NULL;

-- Add indexes for new fields
CREATE INDEX idx_user_profiles_has_onboarded ON public.user_profiles(has_onboarded);
CREATE INDEX idx_user_profiles_experience_level ON public.user_profiles(experience_level);

-- Update existing mock data to have proper onboarding status
UPDATE public.user_profiles 
SET has_onboarded = true, 
    experience_level = 'intermediate'::public.experience_level 
WHERE email IN ('user@example.com', 'testuser@example.com');