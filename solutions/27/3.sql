-- starting point
create database lab_27_service template template0;
\c lab_27_service
create schema tickets;
create table tickets.agents (id integer generated always as identity primary key,
  email text not null unique, full_name text not null);
create table tickets.tickets (id integer generated always as identity primary key,
  agent_id integer not null references tickets.agents (id), title text not null,
  status text not null default 'open' check (status in ('open', 'closed')),
  priority smallint not null default 2 check (priority between 1 and 3),
  created_at timestamptz not null default now());
insert into tickets.agents (email, full_name)
  select 'agent' || g || '@example.com', 'Agent ' || g from generate_series(1, 5) g;
insert into tickets.tickets (agent_id, title, status, priority, created_at)
  select 1 + g % 5, 'Ticket ' || g, case when g % 47 = 0 then 'open' else 'closed' end,
         (1 + g % 3)::smallint, timestamptz '2026-01-01 00:00+00' + g * interval '10 minutes'
  from generate_series(1, 2000) g;

-- 1. what the source looks like
select count(*) as src_agents_rows,
       md5(string_agg(id || ':' || email || ':' || full_name, ',' order by id)) as src_agents_fp
from tickets.agents \gset
select count(*) as src_tickets_rows,
       md5(string_agg(id || ':' || agent_id || ':' || title || ':' || status || ':' || priority || ':' || created_at, ',' order by id)) as src_tickets_fp
from tickets.tickets \gset

-- 2. dump
\setenv PGUSER postgres
\! pg_dump -Fc -d lab_27_service -f /tmp/lab_27_3.dump

-- 3. restore into a blank database
\c postgres
create database lab_27_verify template template0;
\! pg_restore -d lab_27_verify --exit-on-error /tmp/lab_27_3.dump

-- 4. compare
\c lab_27_verify
create table public.restore_report as
with restored as (
  select 'tickets.agents'::text as table_name, count(*) as n,
         md5(string_agg(id || ':' || email || ':' || full_name, ',' order by id)) as fp
  from tickets.agents
  union all
  select 'tickets.tickets', count(*),
         md5(string_agg(id || ':' || agent_id || ':' || title || ':' || status || ':' || priority || ':' || created_at, ',' order by id))
  from tickets.tickets
), source as (
  select 'tickets.agents'::text as table_name, :src_agents_rows::bigint as n, :'src_agents_fp'::text as fp
  union all
  select 'tickets.tickets', :src_tickets_rows::bigint, :'src_tickets_fp'
)
select r.table_name,
       s.n  as source_rows,       r.n  as restored_rows,
       s.fp as source_fingerprint, r.fp as restored_fingerprint,
       (s.n = r.n and s.fp = r.fp) as matches
from restored r join source s using (table_name);

-- 5. clean up
\! rm -f /tmp/lab_27_3.dump
