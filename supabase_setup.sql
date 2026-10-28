-- 놀러가요 후쿠오카!  | 가족 계정 + 개인 기록 저장
-- Supabase Dashboard > SQL Editor 에서 1회 실행합니다.
-- 사용 전 README_설치가이드.md 읽기.
-- 주의: SQL 에 비밀번호/Client Secret/항공권 QR 등을 입력하지 마세요.

create extension if not exists pgcrypto;

create table if not exists public.family_members (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null default '여행자',
  avatar text not null default 'f1',
  role text not null default 'family' check (role in ('family', 'admin')),
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

-- RLS 안에서 안전하게 가족/관리자 여부 확인 (무한 RLS 재귀 방지).
create or replace function public.is_family_approved()
returns boolean language sql stable security definer set search_path=public
as $$select exists(select 1 from public.family_members where id=auth.uid() and approved=true)$$;
create or replace function public.is_family_admin()
returns boolean language sql stable security definer set search_path=public
as $$select exists(select 1 from public.family_members where id=auth.uid() and approved=true and role='admin')$$;
revoke all on function public.is_family_approved() from public;
revoke all on function public.is_family_admin() from public;
grant execute on function public.is_family_approved() to authenticated;
grant execute on function public.is_family_admin() to authenticated;

-- 로그인한 사용자가 본인 계정의 관리자/승인 값을 조작하지 못하게 차단.
create or replace function public.guard_family_roles()
returns trigger language plpgsql set search_path=public as $$
begin
  if auth.uid() is not null and (new.role is distinct from old.role or new.approved is distinct from old.approved) then
    raise exception 'Role and approval can only be changed by a project administrator';
  end if;
  return new;
end $$;
drop trigger if exists trg_family_roles on public.family_members;
create trigger trg_family_roles before update on public.family_members
for each row execute function public.guard_family_roles();

alter table public.family_members enable row level security;
drop policy if exists fm_self_read on public.family_members;
create policy fm_self_read on public.family_members for select to authenticated using (id=auth.uid());
drop policy if exists fm_self_create on public.family_members;
create policy fm_self_create on public.family_members for insert to authenticated
with check (id=auth.uid() and role='family' and approved=false);
drop policy if exists fm_self_profile_update on public.family_members;
create policy fm_self_profile_update on public.family_members for update to authenticated
using (id=auth.uid()) with check (id=auth.uid());

create table if not exists public.travel_days (
  day_index integer primary key check(day_index between 0 and 3),
  content jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.travel_days enable row level security;
drop policy if exists days_family_read on public.travel_days;
create policy days_family_read on public.travel_days for select to authenticated using (public.is_family_approved());
drop policy if exists days_admin_insert on public.travel_days;
create policy days_admin_insert on public.travel_days for insert to authenticated with check (public.is_family_admin());
drop policy if exists days_admin_update on public.travel_days;
create policy days_admin_update on public.travel_days for update to authenticated
using(public.is_family_admin()) with check(public.is_family_admin());
drop policy if exists days_admin_delete on public.travel_days;
create policy days_admin_delete on public.travel_days for delete to authenticated using(public.is_family_admin());

create table if not exists public.completed_stops (
  user_id uuid not null references auth.users(id) on delete cascade,
  stop_id text not null,
  completed_at timestamptz not null default now(),
  primary key (user_id, stop_id)
);
alter table public.completed_stops enable row level security;
drop policy if exists checks_self_read on public.completed_stops;
create policy checks_self_read on public.completed_stops for select to authenticated using (user_id=auth.uid() and public.is_family_approved());
drop policy if exists checks_self_insert on public.completed_stops;
create policy checks_self_insert on public.completed_stops for insert to authenticated with check (user_id=auth.uid() and public.is_family_approved());
drop policy if exists checks_self_delete on public.completed_stops;
create policy checks_self_delete on public.completed_stops for delete to authenticated using (user_id=auth.uid() and public.is_family_approved());
drop policy if exists checks_self_update on public.completed_stops;
create policy checks_self_update on public.completed_stops for update to authenticated using (user_id=auth.uid() and public.is_family_approved()) with check (user_id=auth.uid() and public.is_family_approved());

create table if not exists public.private_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null default 'free' check(kind in ('check','free','loot','receipt')),
  title text not null,
  body text not null default '',
  photo_path text,
  sticker_path text,
  created_at timestamptz not null default now()
);
create index if not exists private_notes_user_idx on public.private_notes (user_id, created_at desc);
alter table public.private_notes enable row level security;
drop policy if exists notes_self_read on public.private_notes;
create policy notes_self_read on public.private_notes for select to authenticated using (user_id=auth.uid() and public.is_family_approved());
drop policy if exists notes_self_insert on public.private_notes;
create policy notes_self_insert on public.private_notes for insert to authenticated with check (user_id=auth.uid() and public.is_family_approved());
drop policy if exists notes_self_update on public.private_notes;
create policy notes_self_update on public.private_notes for update to authenticated
using(user_id=auth.uid() and public.is_family_approved()) with check(user_id=auth.uid() and public.is_family_approved());
drop policy if exists notes_self_delete on public.private_notes;
create policy notes_self_delete on public.private_notes for delete to authenticated using(user_id=auth.uid() and public.is_family_approved());

-- 사진/스티커는 public=false (비공개 버킷). 앱이 로그인 사용자의 서명 URL 생성.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('memo-media','memo-media',false,5242880,array['image/jpeg'])
on conflict (id) do update set public=false,file_size_limit=5242880,allowed_mime_types=array['image/jpeg'];
drop policy if exists media_self_read on storage.objects;
create policy media_self_read on storage.objects for select to authenticated
using(bucket_id='memo-media' and (storage.foldername(name))[1]=auth.uid()::text and public.is_family_approved());
drop policy if exists media_self_insert on storage.objects;
create policy media_self_insert on storage.objects for insert to authenticated
with check(bucket_id='memo-media' and (storage.foldername(name))[1]=auth.uid()::text and public.is_family_approved());
drop policy if exists media_self_delete on storage.objects;
create policy media_self_delete on storage.objects for delete to authenticated
using(bucket_id='memo-media' and (storage.foldername(name))[1]=auth.uid()::text and public.is_family_approved());

-- SQL 실행 완료! 다음에는 아래 승인용 SQL을 '별도 실행'하세요.
-- 먼저 본인의 Google 로그인 → 대기 화면까지 확인한 뒤 아래 값을 바꾸어 실행.
-- UPDATE public.family_members SET approved=true, role='admin'
-- WHERE id=(SELECT id FROM auth.users WHERE email='내-구글-이메일@gmail.com' LIMIT 1);
-- 부모님/언니가 각각 최초 로그인한 뒤 본인의 계정으로 family 승인을 해줍니다.
-- UPDATE public.family_members SET approved=true
-- WHERE id IN (SELECT id FROM auth.users WHERE email IN ('가족1@gmail.com','가족2@gmail.com','가족3@gmail.com'));
