-- ============================================================
-- កត់ត្រាកាលបរិច្ឆេទដែលបានពិនិត្យ ចំណូលរួម (Shared Revenue Review)
-- Run ក្នុង Supabase SQL Editor
-- ============================================================
-- ដើម្បីអោយអាចត្រងមើលថា Invoice ណាត្រូវបានពិនិត្យនៅថ្ងៃណា (ឧ. ថ្ងៃនេះ)
alter table documents add column if not exists shared_revenue_reviewed_at timestamptz;
