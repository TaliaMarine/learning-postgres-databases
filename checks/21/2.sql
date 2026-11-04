select coalesce((select rolcanlogin from pg_roles where rolname = 'lab_21_reports'), false) as ok, 'lab_21_reports exists and can log in' as what
union all select coalesce((select 'work_mem=64MB' = any (setconfig) from pg_db_role_setting s join pg_roles r on r.oid = s.setrole
                           where r.rolname = 'lab_21_reports' and s.setdatabase = 0), false), 'the role has work_mem = 64MB stored for all databases'
union all select coalesce((select 'statement_timeout=30s' = any (setconfig) from pg_db_role_setting s join pg_roles r on r.oid = s.setrole
                           where r.rolname = 'lab_21_reports' and s.setdatabase = 0), false), 'the role has statement_timeout = 30s stored for all databases'
union all select coalesce((select cardinality(setconfig) = 2 from pg_db_role_setting s join pg_roles r on r.oid = s.setrole
                           where r.rolname = 'lab_21_reports' and s.setdatabase = 0), false), 'the role has exactly those two settings';
