select not rolcanlogin as ok, 'lab_04_support cannot log in' as what from pg_roles where rolname = 'lab_04_support'
union all select rolcanlogin, 'lab_04_agent can log in' from pg_roles where rolname = 'lab_04_agent'
union all select pg_has_role('lab_04_agent', 'lab_04_support', 'member'), 'lab_04_agent is a member of lab_04_support'
union all select has_schema_privilege('lab_04_agent', 'shop', 'usage'), 'agent can use schema shop'
union all select has_table_privilege('lab_04_agent', 'shop.orders', 'select'), 'agent can read orders'
union all select not has_table_privilege('lab_04_agent', 'shop.orders', p), 'agent cannot ' || p || ' orders'
  from (values ('insert'), ('update'), ('delete')) v(p)
union all select has_column_privilege('lab_04_agent', 'shop.customers', c, 'select'), 'agent can read customers.' || c
  from (values ('id'), ('full_name'), ('country'), ('status')) v(c)
union all select not has_column_privilege('lab_04_agent', 'shop.customers', c, 'select'), 'agent cannot read customers.' || c
  from (values ('email'), ('phone'), ('profile')) v(c)
union all select not has_table_privilege('lab_04_agent', 'shop.customers', 'select'), 'agent has no table-level SELECT on customers'
union all select has_column_privilege('lab_04_agent', 'shop.customers', 'status', 'update'), 'agent can update customers.status'
union all select not has_column_privilege('lab_04_agent', 'shop.customers', c, 'update'), 'agent cannot update customers.' || c
  from (values ('full_name'), ('email'), ('country')) v(c)
union all select not has_table_privilege('lab_04_agent', 'shop.customers', p), 'agent cannot ' || p || ' customers rows'
  from (values ('insert'), ('delete')) v(p);
