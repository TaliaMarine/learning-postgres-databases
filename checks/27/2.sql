select exists (select 1 from pg_database where datname = 'lab_27_service') as have_db \gset
\if :have_db
\c lab_27_service
\endif
create function pg_temp.plan(q text) returns text language plpgsql as $$
declare r text;
begin
  execute 'explain (format json) ' || q into r;
  return r;
exception when others then
  return '';
end $$;
create function pg_temp.n(q text) returns bigint language plpgsql as $$
declare r bigint;
begin
  execute q into r;
  return r;
exception when others then
  return -1;
end $$;

select current_database() = 'lab_27_service' and pg_temp.n('select count(*) from tickets.agents') = 5 as ok,
       'there are 5 agents' as what
union all
select current_database() = 'lab_27_service' and pg_temp.n('select count(*) from tickets.tickets') = 20000,
       'there are 20000 tickets'
union all
select current_database() = 'lab_27_service'
       and pg_temp.n($q$select count(*) from tickets.tickets where status = 'open'$q$) = 425
       and pg_temp.n($q$select count(*) from tickets.tickets where agent_id = 3$q$) = 4000
       and pg_temp.n($q$select sum(priority) from tickets.tickets$q$) = 40001
       and pg_temp.n($q$select extract(epoch from max(created_at) - min(created_at))::bigint from tickets.tickets$q$) = 11999400,
       'the ticket values follow the recipe'
union all
select current_database() = 'lab_27_service'
       and (select count(*) from pg_index i where i.indrelid = to_regclass('tickets.tickets') and not i.indisprimary and i.indisvalid) = 1,
       'tickets has exactly one index besides its primary key'
union all
select current_database() = 'lab_27_service'
       and coalesce((select pg_get_expr(i.indpred, i.indrelid) is not null
                     from pg_index i where i.indrelid = to_regclass('tickets.tickets') and not i.indisprimary and i.indisvalid), false),
       'that index is a partial index'
union all
select current_database() = 'lab_27_service'
       and pg_temp.plan($q$select id, title from tickets.tickets where status = 'open' and agent_id = 3 order by created_at desc limit 10$q$) like '%"Node Type": "Index%',
       'the support query uses an index scan'
union all
select current_database() = 'lab_27_service'
       and pg_temp.plan($q$select id, title from tickets.tickets where status = 'open' and agent_id = 3 order by created_at desc limit 10$q$) not like '%"Sort"%'
       and pg_temp.plan($q$select id, title from tickets.tickets where status = 'open' and agent_id = 3 order by created_at desc limit 10$q$) like '%tickets%',
       'the support query needs no Sort step'
union all
select current_database() = 'lab_27_service'
       and coalesce((select last_analyze is not null or last_autoanalyze is not null from pg_stat_user_tables where relid = to_regclass('tickets.tickets')), false),
       'statistics were refreshed (ANALYZE ran)';
