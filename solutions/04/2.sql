create role lab_04_support nologin;
create role lab_04_agent login password 'lab-only';
grant lab_04_support to lab_04_agent;
grant usage on schema shop to lab_04_support;
grant select on shop.orders to lab_04_support;
grant select (id, full_name, country, status) on shop.customers to lab_04_support;
grant update (status) on shop.customers to lab_04_support;
