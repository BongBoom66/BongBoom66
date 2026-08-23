-- ============================================================
-- បន្ថែមលេខសំគាល់មូលបត្រ (Cheque Number)
-- Run ក្នុង Supabase SQL Editor
-- ============================================================
alter table documents add column if not exists cheque_number text;
