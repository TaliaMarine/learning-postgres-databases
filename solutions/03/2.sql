create role lab_analysts nologin;
create role lab_maria login password 'lab-only';
grant lab_analysts to lab_maria;
grant usage on schema shop to lab_analysts;
grant select on shop.orders to lab_analysts;
