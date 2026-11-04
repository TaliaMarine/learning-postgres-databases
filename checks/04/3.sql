-- Practical test first: create a table as lab_04_owner, as the future table the task talks about.
set role lab_04_owner;
create table shop.lab_04_probe (id int);
reset role;

select rolcanlogin as ok, 'lab_04_owner can log in' as what from pg_roles where rolname = 'lab_04_owner'
union all select rolcanlogin, 'lab_04_lead can log in' from pg_roles where rolname = 'lab_04_lead'
union all select not rolcanlogin, 'lab_04_viewer cannot log in' from pg_roles where rolname = 'lab_04_viewer'
union all select has_schema_privilege('lab_04_owner', 'shop', 'create'), 'lab_04_owner can create in schema shop'
union all select has_schema_privilege('lab_04_viewer', 'shop', 'usage'), 'lab_04_viewer can use schema shop'
union all select has_schema_privilege('lab_04_lead', 'shop', 'usage'), 'lab_04_lead can use schema shop'
union all select has_table_privilege('lab_04_viewer', 'shop.lab_04_probe', 'select'), 'viewer can read a table the owner creates later'
union all select not has_table_privilege('lab_04_viewer', 'shop.lab_04_probe', 'insert'), 'viewer cannot write that table'
union all select not has_table_privilege('lab_04_viewer', 'shop.orders', 'select'), 'viewer cannot read the existing shop.orders'
union all select not has_table_privilege('lab_04_viewer', 'shop.customers', 'select'), 'viewer cannot read the existing shop.customers'
union all select has_table_privilege('lab_04_lead', 'shop.orders', 'select with grant option'), 'lead can read orders and pass SELECT on'
union all select not has_table_privilege('lab_04_lead', 'shop.orders', 'update'), 'lead cannot update orders';
