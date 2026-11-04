-- roles
create role lab_27_owner nologin;
create role lab_27_app login password 'lab-only';
create role lab_27_reader login password 'lab-only';

-- database
create database lab_27_service owner lab_27_owner template template0;
revoke connect on database lab_27_service from public;
grant connect on database lab_27_service to lab_27_app, lab_27_reader;

\c lab_27_service

-- schema and tables, created as the owner
set role lab_27_owner;

create schema tickets;

create table tickets.agents (
  id        integer generated always as identity primary key,
  email     text not null unique,
  full_name text not null
);

create table tickets.tickets (
  id         integer generated always as identity primary key,
  agent_id   integer     not null references tickets.agents (id),
  title      text        not null,
  status     text        not null default 'open' check (status in ('open', 'closed')),
  priority   smallint    not null default 2 check (priority between 1 and 3),
  created_at timestamptz not null default now()
);

-- privileges, granted by the owner
grant usage on schema tickets to lab_27_app, lab_27_reader;
grant select, insert, update, delete on tickets.agents, tickets.tickets to lab_27_app;
grant select on tickets.agents, tickets.tickets to lab_27_reader;

reset role;
