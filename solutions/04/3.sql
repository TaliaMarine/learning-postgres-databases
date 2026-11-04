create role lab_04_owner login password 'lab-only';
create role lab_04_viewer nologin;
create role lab_04_lead login password 'lab-only';

grant usage, create on schema shop to lab_04_owner;
grant usage on schema shop to lab_04_viewer;
grant usage on schema shop to lab_04_lead;

alter default privileges for role lab_04_owner in schema shop
  grant select on tables to lab_04_viewer;

grant select on shop.orders to lab_04_lead with grant option;
