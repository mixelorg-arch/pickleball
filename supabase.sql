-- Pickle (pickleball open-play app) — isolated cloud sync.
-- Everything is prefixed pickle_ so it cannot collide with other apps in this project.
-- Run once in: Supabase dashboard -> SQL Editor.

create table if not exists public.pickle_rooms (
  code       text primary key check (char_length(code) between 8 and 64),
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- RLS on with NO policies: the publishable (anon) key cannot touch the table directly.
alter table public.pickle_rooms enable row level security;
revoke all on public.pickle_rooms from anon, authenticated;

-- Read one room. You must know the (unguessable) room code.
create or replace function public.pickle_get(p_code text)
returns table (data jsonb, updated_at timestamptz)
language sql security definer set search_path = public as $$
  select r.data, r.updated_at from public.pickle_rooms r where r.code = p_code;
$$;

-- Create/replace one room. Returns the server timestamp.
create or replace function public.pickle_put(p_code text, p_data jsonb)
returns timestamptz
language plpgsql security definer set search_path = public as $$
declare ts timestamptz := now();
begin
  if p_code is null or char_length(p_code) < 8 then raise exception 'room code too short'; end if;
  if octet_length(p_data::text) > 4000000 then raise exception 'room data too large'; end if;
  insert into public.pickle_rooms (code, data, updated_at) values (p_code, p_data, ts)
  on conflict (code) do update set data = excluded.data, updated_at = excluded.updated_at;
  return ts;
end;
$$;

revoke all on function public.pickle_get(text) from public;
revoke all on function public.pickle_put(text, jsonb) from public;
grant execute on function public.pickle_get(text) to anon, authenticated;
grant execute on function public.pickle_put(text, jsonb) to anon, authenticated;
