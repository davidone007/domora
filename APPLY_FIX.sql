-- ============================================================================
-- APPLY FIX: Update handle_new_user trigger to ignore email conflicts
-- ============================================================================
-- INSTRUCTIONS:
-- 1. Go to Supabase Dashboard → SQL Editor
-- 2. Click "New Query"
-- 3. Copy and paste this entire script
-- 4. Click "Run"
-- 5. Verify success message appears
-- ============================================================================

-- Drop existing trigger (safe - function will be recreated)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Recreate function with ON CONFLICT DO NOTHING (ignores ALL conflicts, including email)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (new.id, new.email)
  ON CONFLICT DO NOTHING;
  RETURN new;
END;
$$;

-- Recreate trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Verify: Count existing users in both tables
SELECT 
  (SELECT COUNT(*) FROM auth.users) as auth_users_count,
  (SELECT COUNT(*) FROM public.users) as public_users_count;

-- Success: If query runs without error, the fix is applied.
-- You can now retry signup with the problematic email (miguelangelmartines148@gmail.com)
