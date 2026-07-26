-- Personnel Registry — Supabase schema
-- Run this whole file once in your project's SQL Editor
-- (Supabase dashboard → SQL Editor → New query → paste → Run).

create extension if not exists pgcrypto;

-- ===================== TABLES =====================

create table if not exists departments (
  name text primary key
);

create table if not exists personnel_files (
  id uuid primary key default gen_random_uuid(),
  ref text unique not null,
  name text not null,
  role text not null,
  dept text not null default 'Unassigned',
  status text not null default 'pending' check (status in ('pending','digitized')),
  hired_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists documents (
  id uuid primary key default gen_random_uuid(),
  file_id uuid not null references personnel_files(id) on delete cascade,
  name text not null,
  storage_path text not null,
  mime_type text,
  uploaded_at timestamptz not null default now()
);

create index if not exists documents_file_id_idx on documents(file_id);

-- ===================== ROW LEVEL SECURITY =====================
-- Only signed-in registry staff (any authenticated Supabase user)
-- can read or write. There is no public/anon access by design —
-- these are personnel records with attached ID scans.

alter table departments enable row level security;
alter table personnel_files enable row level security;
alter table documents enable row level security;

create policy "staff full access" on departments
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "staff full access" on personnel_files
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "staff full access" on documents
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ===================== SEED DATA (optional demo data) =====================
-- Delete or comment out this section if you want to start empty.

insert into departments (name) values
  ('Human Resources'),('Finance'),('Operations'),('IT & Systems'),
  ('Sales'),('Customer Support'),('Unassigned')
on conflict do nothing;

insert into personnel_files (ref, name, role, dept, status, hired_on) values
  ('EMP-2011-04521','Grace Namuli','HR Officer','Human Resources','pending','2011-03-14'),
  ('EMP-2016-09102','Peter Okello','Software Engineer','IT & Systems','pending','2016-06-03'),
  ('EMP-2009-01187','Susan Achen','Accountant','Finance','pending','2009-01-22'),
  ('EMP-1998-00342','David Mugisha','Operations Manager','Operations','pending','1998-09-09'),
  ('EMP-2013-06678','Irene Nakato','Sales Executive','Sales','pending','2013-11-17'),
  ('EMP-2004-02290','Sam Byaruhanga','IT Support Lead','IT & Systems','pending','2004-04-02'),
  ('EMP-2019-11209','Betty Adong','Customer Support Agent','Customer Support','pending','2019-02-05'),
  ('EMP-2007-03954','Emmanuel Kato','Finance Assistant','Finance','pending','2007-08-30'),
  ('EMP-2001-00871','Ruth Tumusiime','HR Assistant','Human Resources','pending','2001-12-11')
on conflict do nothing;

-- All seeded records start as "pending" since seed data can't include
-- real scanned files — upload a real document to any of them and its
-- status will flip to "Digitized" automatically, same as any new file.
