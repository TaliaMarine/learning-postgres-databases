select exists (select 1 from pg_database where datname = 'lab_27_service') as have_db \gset
\if :have_db
\c lab_27_service
\endif
create function pg_temp.can(r text, sql text) returns boolean language plpgsql as $$
begin
  execute 'set local role ' || quote_ident(r);
  execute sql;
  reset role;
  return true;
exception when others then
  reset role;
  return false;
end $$;

select coalesce((select not rolcanlogin from pg_roles where rolname = 'lab_27_owner'), false) as ok, 'lab_27_owner is a group role that cannot log in' as what
union all
select coalesce((select rolcanlogin and not rolsuper and not rolcreatedb and not rolcreaterole from pg_roles where rolname = 'lab_27_app'), false),
       'lab_27_app can log in and has no extra powers'
union all
select coalesce((select rolcanlogin and not rolsuper from pg_roles where rolname = 'lab_27_reader'), false),
       'lab_27_reader can log in and is not a superuser'
union all
select coalesce((select datdba::regrole::text = 'lab_27_owner' from pg_database where datname = 'lab_27_service'), false),
       'database lab_27_service is owned by lab_27_owner'
union all
select current_database() = 'lab_27_service'
       and not has_database_privilege('public', 'lab_27_service', 'connect'),
       'PUBLIC cannot connect to lab_27_service'
union all
select current_database() = 'lab_27_service'
       and has_database_privilege('lab_27_app', 'lab_27_service', 'connect')
       and has_database_privilege('lab_27_reader', 'lab_27_service', 'connect'),
       'the two login roles can connect'
union all
select current_database() = 'lab_27_service'
       and coalesce((select nspowner::regrole::text = 'lab_27_owner' from pg_namespace where nspname = 'tickets'), false)
       and (select count(*) from pg_tables where schemaname = 'tickets' and tableowner = 'lab_27_owner') = 2,
       'schema tickets and both tables are owned by lab_27_owner'
union all
select current_database() = 'lab_27_service'
       and (select count(*) from pg_constraint where conrelid = to_regclass('tickets.tickets') and contype = 'p') = 1
       and (select count(*) from pg_constraint where conrelid = to_regclass('tickets.tickets') and contype = 'f') = 1
       and (select count(*) from pg_constraint where conrelid = to_regclass('tickets.agents') and contype = 'u') = 1,
       'primary keys, the foreign key and the unique e-mail exist'
union all
select current_database() = 'lab_27_service' and pg_temp.can('lab_27_app',
         $q$insert into tickets.agents (email, full_name) values ('a@example.com', 'A')$q$),
       'lab_27_app can insert an agent'
union all
select current_database() = 'lab_27_service' and pg_temp.can('lab_27_app',
         $q$insert into tickets.tickets (agent_id, title) select id, 't' from tickets.agents limit 1$q$),
       'lab_27_app can insert a ticket (identity needs no extra grant)'
union all
select current_database() = 'lab_27_service' and not pg_temp.can('lab_27_app',
         $q$insert into tickets.tickets (agent_id, title, status) select id, 't', 'pending' from tickets.agents limit 1$q$),
       'a ticket with status pending is rejected'
union all
select current_database() = 'lab_27_service' and not pg_temp.can('lab_27_app',
         $q$insert into tickets.tickets (agent_id, title, priority) select id, 't', 4 from tickets.agents limit 1$q$),
       'a ticket with priority 4 is rejected'
union all
select current_database() = 'lab_27_service' and pg_temp.can('lab_27_reader', 'select count(*) from tickets.tickets'),
       'lab_27_reader can read tickets'
union all
select current_database() = 'lab_27_service' and not pg_temp.can('lab_27_reader',
         $q$update tickets.tickets set title = 'x'$q$),
       'lab_27_reader cannot update tickets'
union all
select current_database() = 'lab_27_service' and not pg_temp.can('lab_27_app', 'create table tickets.extra (id int)'),
       'lab_27_app cannot create tables in schema tickets';
