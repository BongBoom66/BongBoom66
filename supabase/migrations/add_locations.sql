-- ============================================================
-- មុខងារគ្រប់គ្រងស្តុកច្រើនទីតាំង (កន្លែងលក់ + ឃ្លាំង)
-- Run ក្នុង Supabase SQL Editor
-- ============================================================

-- ១. តារាងទីតាំង (ហាង/ឃ្លាំង)
create table if not exists locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null default 'shop', -- 'shop' ឬ 'warehouse'
  is_default boolean default false,
  created_at timestamptz default now()
);
alter table locations enable row level security;
drop policy if exists "allow all locations" on locations;
create policy "allow all locations" on locations for all using (true) with check (true);

-- ២. តារាងស្តុកតាមទីតាំង (product_id + location_id => qty)
create table if not exists product_stock (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  location_id uuid references locations(id) on delete cascade,
  qty numeric default 0,
  updated_at timestamptz default now(),
  unique(product_id, location_id)
);
alter table product_stock enable row level security;
drop policy if exists "allow all product_stock" on product_stock;
create policy "allow all product_stock" on product_stock for all using (true) with check (true);

-- ៣. បង្កើតទីតាំងលំនាំដើម ១ ដើម្បីផ្ទេរស្តុកចាស់មកដាក់ (ប្តូរឈ្មោះនៅក្នុង App វិញក៏បាន)
insert into locations (name, type, is_default)
select 'ហាងចម្បង', 'shop', true
where not exists (select 1 from locations);

-- ៤. ផ្ទេរស្តុកទាំងអស់ដែលមានស្រាប់ក្នុង products.stock_qty ចូលទីតាំងលំនាំដើម
insert into product_stock (product_id, location_id, qty)
select p.id, l.id, p.stock_qty
from products p, (select id from locations where is_default=true limit 1) l
on conflict (product_id, location_id) do nothing;

-- ============================================================
-- ៥. តារាងកត់ត្រាប្រវត្តិផ្ទេរស្តុក (Stock Transfer History)
-- ============================================================
create table if not exists stock_transfers (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete set null,
  product_name text,
  from_location_id uuid references locations(id) on delete set null,
  to_location_id uuid references locations(id) on delete set null,
  qty numeric not null,
  transferred_by uuid references profiles(id) on delete set null,
  transferred_by_name text,
  created_at timestamptz default now()
);
alter table stock_transfers enable row level security;
drop policy if exists "allow all stock_transfers" on stock_transfers;
create policy "allow all stock_transfers" on stock_transfers for all using (true) with check (true);

-- ============================================================
-- ៦. បន្ថែម Column វិធីទូទាត់ (Cash / Bank / មូលបត្រ)
-- ============================================================
alter table documents add column if not exists payment_method text;

-- ============================================================
-- ៧. បន្ថែម Column បារកូដ (Barcode) សម្រាប់ផលិតផល
-- ============================================================
alter table products add column if not exists barcode text;
create unique index if not exists products_barcode_idx on products(barcode) where barcode is not null;

-- ============================================================
-- ៨. បន្ថែម Column ធនាគារ (សម្រាប់ជម្រើសទូទាត់តាមធនាគារ)
-- ============================================================
alter table documents add column if not exists bank_name text;

-- ============================================================
-- ៩. បន្ថែម Column ផ្អាកគណនី Staff (សម្រាប់ Staff ដែលលាឈប់)
-- ============================================================
alter table profiles add column if not exists disabled boolean default false;
