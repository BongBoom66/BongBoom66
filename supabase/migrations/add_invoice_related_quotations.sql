-- ============================================================
-- បញ្ជាក់លេខ Quotation ច្រើនសន្លឹក ដែលបានទាញចូល Invoice តែមួយ
-- Run ក្នុង Supabase SQL Editor
-- ============================================================
-- ពេលភ្ញៀវម្នាក់មាន Quotation ច្រើន ប៉ុន្តែចង់ចេញ Invoice តែមួយ ជួរឈរនេះផ្ទុក
-- លេខ Quotation ទាំងអស់ (ខណ្ឌដោយសញ្ញា ",") ដើម្បីបង្ហាញយោងលើ Invoice នោះ។
alter table documents add column if not exists related_quotation_nos text;
