select coalesce(rolcanlogin, false) as ok, 'lab_02_owner can log in' as what from (select 1) x left join pg_roles on rolname = 'lab_02_owner'
union all
select exists (select 1 from pg_database where datname = 'lab_02_copy'), 'database lab_02_copy exists'
union all
select coalesce((select pg_get_userbyid(datdba) = 'lab_02_owner' from pg_database where datname = 'lab_02_copy'), false), 'lab_02_copy is owned by lab_02_owner'
union all
select coalesce((select datconnlimit = 3 from pg_database where datname = 'lab_02_copy'), false), 'connection limit is 3'
union all
select coalesce((select not datistemplate from pg_database where datname = 'lab_02_copy'), false), 'lab_02_copy is an ordinary database, not a template'
union all
select coalesce((select pg_database_size('lab_02_copy') > 50 * 1024 * 1024 from pg_database where datname = 'lab_02_copy'), false), 'lab_02_copy contains the shop data (it was copied from shop_template)';
