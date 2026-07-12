-- ============================================================
-- បន្ថែមកំណត់ចំណាំពេលត្រួតពិនិត្យចំណូលរួម
-- Run ក្នុង Supabase SQL Editor
-- ============================================================
alter table documents add column if not exists shared_revenue_note text;
