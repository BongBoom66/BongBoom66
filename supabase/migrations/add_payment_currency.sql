-- ============================================================
-- បញ្ជាក់រូបិយប័ណ្ណដែលទទួលបានពេលទូទាត់ (Dollar / Riel)
-- Run ក្នុង Supabase SQL Editor
-- ============================================================

-- វិធីទូទាត់ (payment_method) មានស្រាប់ — បន្ថែម column ថ្មីសម្រាប់កត់ត្រា
-- ថាតើទទួលជា Dollar ឬ Riel ជាក់ស្តែង និងចំនួន Riel ជាក់ស្តែងបានទទួល
alter table documents add column if not exists payment_currency text default 'usd';
alter table documents add column if not exists payment_riel_amount numeric;
