create extension if not exists pgstattuple;
select to_regclass('public.lab_vac_demo') is not null as ok, 'table public.lab_vac_demo exists' as what
union all select (select count(*) = 1000 from public.lab_vac_demo), 'the table holds 1000 rows'
union all select (select count(*) = 300 from public.lab_vac_demo where note like '%(edited)'), 'exactly 300 rows were edited'
union all select (select last_vacuum is not null from pg_stat_user_tables where relid = 'public.lab_vac_demo'::regclass), 'VACUUM has run on the table'
union all select (select dead_tuple_count = 0 from pgstattuple('public.lab_vac_demo')), 'no dead row versions are left in the table file';
