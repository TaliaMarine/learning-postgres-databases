select coalesce((select not rolcanlogin from pg_roles where rolname = 'lab_05_owner'), false) as ok, 'lab_05_owner exists and cannot log in' as what
union all select coalesce((select pg_get_userbyid(nspowner) = 'lab_05_owner' from pg_namespace where nspname = 'shop'), false), 'lab_05_owner owns schema shop'
union all select coalesce((select not rolcanlogin from pg_roles where rolname = 'lab_05_ro'), false), 'lab_05_ro exists and cannot log in'
union all select coalesce(has_schema_privilege('lab_05_ro', 'shop', 'usage'), false), 'lab_05_ro can use schema shop'
union all select coalesce((select count(*) = count(*) filter (where has_table_privilege('lab_05_ro', c.oid, 'select'))
                           from pg_class c where c.relnamespace = 'shop'::regnamespace and c.relkind = 'r'), false), 'lab_05_ro can read every table in shop'
union all select coalesce(not exists (select 1 from pg_class c where c.relnamespace = 'shop'::regnamespace and c.relkind = 'r'
                           and (has_table_privilege('lab_05_ro', c.oid, 'insert') or has_table_privilege('lab_05_ro', c.oid, 'update')
                                or has_table_privilege('lab_05_ro', c.oid, 'delete') or has_table_privilege('lab_05_ro', c.oid, 'truncate'))), false), 'lab_05_ro cannot change anything'
union all select coalesce(not has_schema_privilege('lab_05_ro', 'analytics', 'usage'), false), 'lab_05_ro cannot use schema analytics'
union all select coalesce(not has_table_privilege('lab_05_ro', 'analytics.events', 'select'), false), 'lab_05_ro cannot read analytics.events';
