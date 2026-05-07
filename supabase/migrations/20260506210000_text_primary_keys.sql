-- Flutter app uses string primary keys (e.g. default_salary_account, timestamp strings),
-- not UUIDs. The previous uuid columns caused every Supabase upsert to fail silently
-- (invalid uuid / FK mismatches). user_id stays uuid and still references auth.users.

drop policy if exists "transactions_delete_own" on public.transactions;
drop policy if exists "transactions_update_own" on public.transactions;
drop policy if exists "transactions_insert_own" on public.transactions;
drop policy if exists "transactions_select_own" on public.transactions;

drop policy if exists "categories_delete_own" on public.categories;
drop policy if exists "categories_update_own" on public.categories;
drop policy if exists "categories_insert_own" on public.categories;
drop policy if exists "categories_select_own" on public.categories;

drop policy if exists "accounts_delete_own" on public.accounts;
drop policy if exists "accounts_update_own" on public.accounts;
drop policy if exists "accounts_insert_own" on public.accounts;
drop policy if exists "accounts_select_own" on public.accounts;

drop table if exists public.transactions;
drop table if exists public.categories;
drop table if exists public.accounts;

create table public.accounts (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  balance double precision not null default 0,
  icon text,
  color text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.categories (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  icon text,
  color text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.transactions (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  account_id text not null references public.accounts (id) on delete cascade,
  category_id text references public.categories (id) on delete set null,
  amount double precision not null,
  type text not null check (type in ('income', 'expense')),
  description text,
  date timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_accounts_user_id on public.accounts (user_id);
create index idx_categories_user_id on public.categories (user_id);
create index idx_transactions_user_id on public.transactions (user_id);
create index idx_transactions_account_id on public.transactions (account_id);
create index idx_transactions_category_id on public.transactions (category_id);

alter table public.accounts enable row level security;
alter table public.categories enable row level security;
alter table public.transactions enable row level security;

create policy "accounts_select_own"
on public.accounts for select
using (auth.uid() = user_id);

create policy "accounts_insert_own"
on public.accounts for insert
with check (auth.uid() = user_id);

create policy "accounts_update_own"
on public.accounts for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "accounts_delete_own"
on public.accounts for delete
using (auth.uid() = user_id);

create policy "categories_select_own"
on public.categories for select
using (auth.uid() = user_id);

create policy "categories_insert_own"
on public.categories for insert
with check (auth.uid() = user_id);

create policy "categories_update_own"
on public.categories for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "categories_delete_own"
on public.categories for delete
using (auth.uid() = user_id);

create policy "transactions_select_own"
on public.transactions for select
using (auth.uid() = user_id);

create policy "transactions_insert_own"
on public.transactions for insert
with check (auth.uid() = user_id);

create policy "transactions_update_own"
on public.transactions for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "transactions_delete_own"
on public.transactions for delete
using (auth.uid() = user_id);
