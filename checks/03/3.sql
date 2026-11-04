select rolcreaterole as ok, 'lab_ops can create roles' as what from pg_roles where rolname = 'lab_ops'
union all select not rolsuper, 'lab_ops is not a superuser' from pg_roles where rolname = 'lab_ops'
union all select not rolcreatedb, 'lab_ops cannot create databases' from pg_roles where rolname = 'lab_ops'
union all select rolvaliduntil::date = date '2030-01-01', 'lab_ops password expires 2030-01-01' from pg_roles where rolname = 'lab_ops';
