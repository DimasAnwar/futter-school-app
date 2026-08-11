-- Run once in Supabase SQL Editor after creating the profiles table.
-- Promote the first admin manually, for example:
-- update public.profiles set role = 'Admin' where email = 'admin@example.com';

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and lower(role) in ('admin', 'admins')
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- An Admin can manage every application table. Other role policies remain
-- responsible for limiting Student, Teacher, and Parent access.
drop policy if exists "Admin full access to profiles" on public.profiles;
create policy "Admin full access to profiles" on public.profiles
  for all to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

drop policy if exists "Admin full access to mata_kuliah" on public.mata_kuliah;
create policy "Admin full access to mata_kuliah" on public.mata_kuliah
  for all to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

drop policy if exists "Admin full access to enrollments" on public.enrollments;
create policy "Admin full access to enrollments" on public.enrollments
  for all to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

drop policy if exists "Admin full access to materi" on public.materi;
create policy "Admin full access to materi" on public.materi
  for all to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

drop policy if exists "Admin full access to tugas" on public.tugas;
create policy "Admin full access to tugas" on public.tugas
  for all to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

drop policy if exists "Admin full access to pengumpulan_tugas" on public.pengumpulan_tugas;
create policy "Admin full access to pengumpulan_tugas" on public.pengumpulan_tugas
  for all to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));
