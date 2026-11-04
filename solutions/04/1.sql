create role lab_04_report login password 'lab-only';
grant usage on schema shop to lab_04_report;
grant select on shop.products, shop.categories to lab_04_report;
