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
select 1 + g % 5,
       'Ticket ' || g,
       case when g % 47 = 0 then 'open' else 'closed' end,
       (1 + g % 3)::smallint,
       timestamptz '2026-01-01 00:00+00' + g * interval '10 minutes'
from generate_series(1, 20000) g;

-- Only the 425 open tickets are indexed, and the index is already in the order the query wants.
create index tickets_open_by_agent_idx on tickets.tickets (agent_id, created_at desc) where status = 'open';

analyze tickets.agents;
analyze tickets.tickets;
