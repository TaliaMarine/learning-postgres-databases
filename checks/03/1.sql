select rolcanlogin as ok, 'lab_reader can log in' as what from pg_roles where rolname = 'lab_reader'
union all select has_table_privilege('lab_reader', 'shop.products', 'select'), 'lab_reader can read products'
union all select not has_table_privilege('lab_reader', 'shop.customers', 'select'), 'lab_reader cannot read customers'
union all select not has_table_privilege('lab_reader', 'shop.products', 'update'), 'lab_reader cannot change products';
