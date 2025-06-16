-- =====================================================
-- COMPLETE DATABASE SCHEMA FIX FOR ANONYMOUS ACCESS
-- =====================================================

-- =====================================================
-- 1. CREATE STANDALONE USER_PROFILES TABLE
-- =====================================================

-- Drop existing user_profiles table and recreate without auth dependency
DROP TABLE IF EXISTS user_profiles CASCADE;

CREATE TABLE user_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  full_name text,
  avatar_url text,
  bio text,
  preferences jsonb DEFAULT '{}'::jsonb
);

-- Enable RLS on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. FIX REVIEWS TABLE COMPLETELY
-- =====================================================

-- Drop existing reviews table and recreate with correct structure
DROP TABLE IF EXISTS reviews CASCADE;

CREATE TABLE reviews (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  toilet_id text NOT NULL,
  user_id uuid, -- References user_profiles.id (no auth dependency)
  review_text text,
  rating bigint CHECK (rating >= 1 AND rating <= 5),
  created_at timestamptz DEFAULT now()
);

-- Add foreign key constraints
ALTER TABLE reviews ADD CONSTRAINT reviews_toilet_id_fkey 
FOREIGN KEY (toilet_id) REFERENCES kakoos(uuid) ON DELETE CASCADE;

ALTER TABLE reviews ADD CONSTRAINT reviews_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE SET NULL;

-- Enable RLS on reviews
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. FIX REPORTS TABLE COMPLETELY
-- =====================================================

-- Drop existing reports table and recreate with correct structure
DROP TABLE IF EXISTS reports CASCADE;

CREATE TABLE reports (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  toilet_id text NOT NULL,
  user_id uuid, -- References user_profiles.id (no auth dependency)
  issue_text text,
  created_at timestamptz DEFAULT now()
);

-- Add foreign key constraints
ALTER TABLE reports ADD CONSTRAINT reports_toilet_id_fkey 
FOREIGN KEY (toilet_id) REFERENCES kakoos(uuid) ON DELETE CASCADE;

ALTER TABLE reports ADD CONSTRAINT reports_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE SET NULL;

-- Enable RLS on reports
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. FIX SAVED_TOILETS TABLE
-- =====================================================

-- Drop and recreate saved_toilets table
DROP TABLE IF EXISTS saved_toilets CASCADE;

CREATE TABLE saved_toilets (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id uuid NOT NULL,
  toilet_id text NOT NULL,
  notes text,
  saved_at timestamptz DEFAULT now(),
  UNIQUE(user_id, toilet_id)
);

-- Add foreign key constraints
ALTER TABLE saved_toilets ADD CONSTRAINT saved_toilets_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE CASCADE;

ALTER TABLE saved_toilets ADD CONSTRAINT saved_toilets_toilet_id_fkey 
FOREIGN KEY (toilet_id) REFERENCES kakoos(uuid) ON DELETE CASCADE;

-- Enable RLS on saved_toilets
ALTER TABLE saved_toilets ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. FIX USERS TABLE (LEGACY COMPATIBILITY)
-- =====================================================

-- Drop and recreate users table without auth dependency
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  created_at timestamptz DEFAULT now(),
  name text,
  email text,
  phone varchar,
  auth_user_id uuid -- Optional field, no foreign key constraint
);

-- Enable RLS on users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 6. CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Reviews table indexes
CREATE INDEX IF NOT EXISTS idx_reviews_toilet_id ON reviews(toilet_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at DESC);

-- Reports table indexes
CREATE INDEX IF NOT EXISTS idx_reports_toilet_id ON reports(toilet_id);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);

-- Saved toilets table indexes
CREATE INDEX IF NOT EXISTS idx_saved_toilets_user_id ON saved_toilets(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_toilets_toilet_id ON saved_toilets(toilet_id);

-- User profiles table indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_id ON user_profiles(id);

-- Users table indexes
CREATE INDEX IF NOT EXISTS idx_users_auth_user_id ON users(auth_user_id);

-- =====================================================
-- 7. SET UP RLS POLICIES FOR ANONYMOUS ACCESS
-- =====================================================

-- User profiles policies (public read, anyone can create)
CREATE POLICY "Public profiles are viewable by everyone"
  ON user_profiles
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can create profiles"
  ON user_profiles
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can update profiles"
  ON user_profiles
  FOR UPDATE
  TO public
  USING (true);

CREATE POLICY "Anyone can delete profiles"
  ON user_profiles
  FOR DELETE
  TO public
  USING (true);

-- Reviews policies (full public access for anonymous reviews)
CREATE POLICY "Anyone can read reviews"
  ON reviews
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can create reviews"
  ON reviews
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can update reviews"
  ON reviews
  FOR UPDATE
  TO public
  USING (true);

CREATE POLICY "Anyone can delete reviews"
  ON reviews
  FOR DELETE
  TO public
  USING (true);

-- Reports policies (full public access for anonymous reports)
CREATE POLICY "Anyone can read reports"
  ON reports
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can create reports"
  ON reports
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can update reports"
  ON reports
  FOR UPDATE
  TO public
  USING (true);

CREATE POLICY "Anyone can delete reports"
  ON reports
  FOR DELETE
  TO public
  USING (true);

-- Saved toilets policies (public access)
CREATE POLICY "Anyone can read saved toilets"
  ON saved_toilets
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can create saved toilets"
  ON saved_toilets
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can update saved toilets"
  ON saved_toilets
  FOR UPDATE
  TO public
  USING (true);

CREATE POLICY "Anyone can delete saved toilets"
  ON saved_toilets
  FOR DELETE
  TO public
  USING (true);

-- Users table policies (public access)
CREATE POLICY "Anyone can read users"
  ON users
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Anyone can create users"
  ON users
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can update users"
  ON users
  FOR UPDATE
  TO public
  USING (true);

CREATE POLICY "Anyone can delete users"
  ON users
  FOR DELETE
  TO public
  USING (true);

-- =====================================================
-- 8. ENSURE KAKOOS TABLE IS ACCESSIBLE
-- =====================================================

-- Disable RLS on kakoos for public access (if it exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'kakoos') THEN
    ALTER TABLE kakoos DISABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- =====================================================
-- 9. ADD SAMPLE ANONYMOUS USER PROFILES FOR TESTING
-- =====================================================

-- Insert sample anonymous user profiles (now safe without auth dependency)
INSERT INTO user_profiles (id, full_name, avatar_url, bio) VALUES 
('00000000-0000-0000-0000-000000000001', 'Anonymous User 1', null, 'Anonymous reviewer'),
('00000000-0000-0000-0000-000000000002', 'Anonymous User 2', null, 'Anonymous reviewer'),
('00000000-0000-0000-0000-000000000003', 'Anonymous User 3', null, 'Anonymous reviewer'),
('00000000-0000-0000-0000-000000000004', 'Anonymous User 4', null, 'Anonymous reviewer'),
('00000000-0000-0000-0000-000000000005', 'Anonymous User 5', null, 'Anonymous reviewer')
ON CONFLICT (id) DO NOTHING;

-- Insert corresponding legacy users records
INSERT INTO users (name, email, auth_user_id) VALUES 
('Anonymous User 1', 'anon1@example.com', null),
('Anonymous User 2', 'anon2@example.com', null),
('Anonymous User 3', 'anon3@example.com', null),
('Anonymous User 4', 'anon4@example.com', null),
('Anonymous User 5', 'anon5@example.com', null);

-- =====================================================
-- 10. ADD SAMPLE REVIEWS ONLY FOR EXISTING TOILETS
-- =====================================================

-- Add sample reviews only if the corresponding toilets exist in kakoos table
-- This prevents foreign key constraint violations
DO $$
DECLARE
    toilet_exists boolean;
BEGIN
    -- Check if any toilets exist in kakoos table before adding reviews
    SELECT EXISTS(SELECT 1 FROM kakoos LIMIT 1) INTO toilet_exists;
    
    IF toilet_exists THEN
        -- Add reviews only for toilets that actually exist
        INSERT INTO reviews (toilet_id, user_id, review_text, rating)
        SELECT 
            k.uuid,
            '00000000-0000-0000-0000-000000000001',
            'Great facility! Very clean and well-maintained.',
            5
        FROM kakoos k
        LIMIT 1;
        
        INSERT INTO reviews (toilet_id, user_id, review_text, rating)
        SELECT 
            k.uuid,
            '00000000-0000-0000-0000-000000000002',
            'Good location and accessibility features.',
            4
        FROM kakoos k
        LIMIT 1;
        
        RAISE NOTICE 'Sample reviews added for existing toilets.';
    ELSE
        RAISE NOTICE 'No toilets found in kakoos table. Skipping sample reviews.';
    END IF;
END $$;

-- =====================================================
-- 11. FINAL VERIFICATION
-- =====================================================

-- Verify all tables exist and have correct structure
DO $$
BEGIN
  -- Check if all required tables exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_profiles') THEN
    RAISE EXCEPTION 'user_profiles table does not exist!';
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'reviews') THEN
    RAISE EXCEPTION 'reviews table does not exist!';
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'reports') THEN
    RAISE EXCEPTION 'reports table does not exist!';
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'saved_toilets') THEN
    RAISE EXCEPTION 'saved_toilets table does not exist!';
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
    RAISE EXCEPTION 'users table does not exist!';
  END IF;
  
  -- Check if foreign key relationships exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'reviews' AND constraint_name = 'reviews_user_id_fkey'
  ) THEN
    RAISE EXCEPTION 'reviews -> user_profiles foreign key does not exist!';
  END IF;
  
  -- Verify sample data was inserted
  IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE id = '00000000-0000-0000-0000-000000000001') THEN
    RAISE EXCEPTION 'Sample user profiles were not inserted!';
  END IF;
  
  RAISE NOTICE 'All database schema fixes completed successfully!';
  RAISE NOTICE 'Anonymous access enabled for all tables.';
  RAISE NOTICE 'Sample user profiles created.';
  RAISE NOTICE 'Reviews will be added only if toilets exist in kakoos table.';
END $$;