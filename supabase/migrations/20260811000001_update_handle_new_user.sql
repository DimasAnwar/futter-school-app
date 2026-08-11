-- Update handle_new_user trigger function in Supabase to auto-assign nim and jurusan from user metadata into public.profiles

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, email, full_name, role, nim, jurusan)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.raw_user_meta_data ->> 'role', 'Students'),
    nullif(trim(new.raw_user_meta_data ->> 'nim'), ''),
    nullif(trim(new.raw_user_meta_data ->> 'jurusan'), '')
  )
  on conflict (id) do update set
    email = excluded.email,
    full_name = excluded.full_name,
    role = excluded.role,
    nim = coalesce(excluded.nim, public.profiles.nim),
    jurusan = coalesce(excluded.jurusan, public.profiles.jurusan);
  return new;
end;
$$;
