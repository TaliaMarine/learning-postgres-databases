select coalesce(rolcanlogin, false) as ok, 'lab_02_dev can log in' as what from (select 1) x left join pg_roles on rolname = 'lab_02_dev'
union all
select coalesce((select pg_get_userbyid(nspowner) = 'lab_02_dev' from pg_namespace where nspname = 'dev'), false), 'schema dev exists and is owned by lab_02_dev'
union all
select coalesce((select replace(substr(c, length('search_path=') + 1), ' ', '') = 'dev,shop'
                 from pg_roles r, unnest(r.rolconfig) c
                 where r.rolname = 'lab_02_dev' and c like 'search_path=%'), false),
       'lab_02_dev has search_path = dev, shop';
