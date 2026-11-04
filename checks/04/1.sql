select rolcanlogin as ok, 'lab_04_report can log in' as what from pg_roles where rolname = 'lab_04_report'
union all select has_schema_privilege('lab_04_report', 'shop', 'usage'), 'lab_04_report can use schema shop'
union all select has_table_privilege('lab_04_report', 'shop.products', 'select'), 'can read products'
union all select has_table_privilege('lab_04_report', 'shop.categories', 'select'), 'can read categories'
union all select not has_table_privilege('lab_04_report', 'shop.' || t, p), 'cannot ' || p || ' ' || t
  from (values ('products','insert'), ('products','update'), ('products','delete'), ('categories','insert'), ('categories','update'), ('categories','delete')) v(t, p)
union all select not has_any_column_privilege('lab_04_report', 'shop.' || t, 'select'), 'cannot read ' || t
  from (values ('customers'), ('orders'), ('order_items')) v(t)
union all select not has_schema_privilege('lab_04_report', 'shop', 'create'), 'cannot create objects in shop';
