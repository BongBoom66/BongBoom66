-- ============================================================
-- បន្ថែមប្រភេទឯកសារថ្មី៖ ស្នើសុំទូទាត់បំណុល (Payment Request)
-- Run ក្នុង Supabase SQL Editor
-- ============================================================
-- មុខងារនេះប្រើ documents.doc_type = 'payment_request' ដែលជាតម្លៃថ្មី
-- (ក្រៅពី invoice/quotation/delivery ដែលមានស្រាប់)។ បើតារាង documents
-- មាន CHECK constraint កំណត់ត្រឹមតែប្រភេទចាស់ៗ សូមលុបវាចោល ដើម្បីអនុញ្ញាត
-- ឲ្យប្រភេទថ្មីនេះរក្សាទុកបាន។ បើគ្មាន constraint នេះ (ឈ្មោះមិនត្រូវគ្នា)
-- បន្ទាត់ខាងក្រោមនឹងមិនធ្វើអ្វីទេ (safe no-op)។
alter table documents drop constraint if exists documents_doc_type_check;
