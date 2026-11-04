-- Roles and databases are cluster-wide, so they can be checked from inside lab_23_restored.
select exists (select 1 from pg_database where datname = 'lab_23_restored') as have_db \gset
\if :have_db
\c lab_23_restored
\endif
create function pg_temp.row_count(t text) returns bigint language plpgsql as $$
declare n bigint;
begin
  execute format('select count(*) from %s', t) into n;
  return n;
exception when others then
  return -1;
end $$;

select exists (select 1 from pg_roles where rolname = 'lab_23_owner') as ok, 'role lab_23_owner exists' as what
union all
select coalesce((select datdba::regrole::text = 'lab_23_owner' from pg_database where datname = 'lab_23_restored'), false),
       'database lab_23_restored exists and belongs to lab_23_owner'
union all
select current_database() = 'lab_23_restored'
       and (select count(*) from pg_tables where schemaname = 'shop') = 5,
       'the five shop tables were restored into lab_23_restored'
union all
select current_database() = 'lab_23_restored'
       and not exists (select 1 from pg_tables where schemaname = 'shop' and tableowner <> 'lab_23_owner'),
       'every restored shop table is owned by lab_23_owner'
union all
select current_database() = 'lab_23_restored'
       and coalesce((select nspowner::regrole::text from pg_namespace where nspname = 'shop'), '') = 'lab_23_owner',
       'schema shop is owned by lab_23_owner'
union all
select current_database() = 'lab_23_restored' and pg_temp.row_count('shop.orders') = 200000,
       'shop.orders has all 200000 rows'
union all
select current_database() = 'lab_23_restored'
       and (select count(*) from pg_tables where schemaname in ('analytics', 'course')) = 0,
       'only the shop schema was restored';
