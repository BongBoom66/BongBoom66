-- ============================================================
-- ស្ថានភាពត្រួតពិនិត្យចំណូលរួម ដាច់ដោយឡែកតាមម្ចាស់និមួយៗ
-- Run ក្នុង Supabase SQL Editor
-- ============================================================
-- មុននេះ ស្ថានភាព "ពិនិត្យរួច" ត្រូវបានផ្ទុកនៅលើ documents (មួយក្នុងមួយ Invoice)
-- ដូច្នេះ Invoice ណាមួយមានទំនិញរបស់ម្ចាស់ច្រើននាក់ ការសម្គាល់ថាបានពិនិត្យសម្រាប់
-- ម្ចាស់ម្នាក់ នឹងបង្ហាញថា "ពិនិត្យរួច" សម្រាប់ម្ចាស់ផ្សេងទៀតដែរ (ព្រោះជាជួរដេកតែមួយ)។
-- តារាងនេះផ្ទុកស្ថានភាពដាច់ដោយឡែក មួយក្នុងមួយ (Invoice, ម្ចាស់)។
create table if not exists shared_revenue_reviews (
  id uuid primary key default gen_random_uuid(),
  document_id uuid not null references documents(id) on delete cascade,
  owner_name text not null,
  reviewed boolean not null default false,
  reviewed_at timestamptz,
  note text,
  created_at timestamptz not null default now(),
  unique(document_id, owner_name)
);
create index if not exists idx_shared_revenue_reviews_document on shared_revenue_reviews(document_id);
alter table shared_revenue_reviews enable row level security;
drop policy if exists "allow all shared_revenue_reviews" on shared_revenue_reviews;
create policy "allow all shared_revenue_reviews" on shared_revenue_reviews for all using (true) with check (true);
