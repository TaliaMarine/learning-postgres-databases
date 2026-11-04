select not rolcanlogin as ok, 'lab_analysts cannot log in' as what from pg_roles where rolname = 'lab_analysts'
union all select rolcanlogin, 'lab_maria can log in' from pg_roles where rolname = 'lab_maria'
union all select pg_has_role('lab_maria', 'lab_analysts', 'member'), 'lab_maria is a member of lab_analysts'
union all select has_table_privilege('lab_maria', 'shop.orders', 'select'), 'lab_maria can read orders through the group'
union all select not has_table_privilege('lab_maria', 'shop.orders', 'delete'), 'lab_maria cannot delete orders';
