select exists (select 1 from pg_database where datname = 'lab_27_service') as have_src \gset
select exists (select 1 from pg_database where datname = 'lab_27_verify')  as have_dst \gset
\if :have_src
\c lab_27_service
select md5(string_agg(id || ':' || email || ':' || full_name, ',' order by id)) as live_agents_fp from tickets.agents \gset
select md5(string_agg(id || ':' || agent_id || ':' || title || ':' || status || ':' || priority || ':' || created_at, ',' order by id)) as live_tickets_fp from tickets.tickets \gset
\else
\set live_agents_fp ''
\set live_tickets_fp ''
\endif
\if :have_dst
\c lab_27_verify
\endif
create function pg_temp.q(sql text) returns text language plpgsql as $$
declare r text;
begin
  execute sql into r;
  return r;
exception when others then
  return null;
end $$;
select pg_read_binary_file('/tmp/lab_27_3.dump', 0, 5, true) is null as dump_gone \gset

select current_database() = 'lab_27_verify' and :'have_dst'::boolean as ok,
       'database lab_27_verify exists and was used' as what
union all
select coalesce(pg_temp.q('select count(*) from tickets.agents') = '5'
       and pg_temp.q('select count(*) from tickets.tickets') = '2000', false),
       'lab_27_verify holds the restored tables (5 agents, 2000 tickets)'
union all
select coalesce(pg_temp.q('select count(*) from pg_constraint where connamespace = ''tickets''::regnamespace and contype in (''p'', ''f'', ''u'', ''c'')') = '6', false),
       'the restored tables kept their primary keys, foreign key, unique and check constraints'
union all
select coalesce(pg_temp.q('select count(*) from public.restore_report') = '2', false),
       'public.restore_report has one row per table'
union all
select coalesce(pg_temp.q('select count(*) from public.restore_report where matches') = '2', false),
       'both rows say matches = true'
union all
select coalesce(pg_temp.q('select count(*) from information_schema.columns where table_schema = ''public'' and table_name = ''restore_report'' and column_name in (''table_name'', ''source_rows'', ''restored_rows'', ''source_fingerprint'', ''restored_fingerprint'', ''matches'')') = '6', false),
       'the report has the six required columns'
union all
select coalesce(pg_temp.q('select source_fingerprint from public.restore_report where table_name = ''tickets.agents''') = :'live_agents_fp'
       and pg_temp.q('select source_fingerprint from public.restore_report where table_name = ''tickets.tickets''') = :'live_tickets_fp'
       and :'live_agents_fp' <> '', false),
       'the source fingerprints in the report equal the live source tables'
union all
select coalesce(pg_temp.q('select restored_fingerprint from public.restore_report where table_name = ''tickets.agents''') =
         pg_temp.q('select md5(string_agg(id || '':'' || email || '':'' || full_name, '','' order by id)) from tickets.agents')
       and pg_temp.q('select restored_fingerprint from public.restore_report where table_name = ''tickets.tickets''') =
         pg_temp.q('select md5(string_agg(id || '':'' || agent_id || '':'' || title || '':'' || status || '':'' || priority || '':'' || created_at, '','' order by id)) from tickets.tickets'), false),
       'the restored fingerprints equal the restored tables (not typed in by hand)'
union all
select :'dump_gone'::boolean, 'the dump file /tmp/lab_27_3.dump was removed';
