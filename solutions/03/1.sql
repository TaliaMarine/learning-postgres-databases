create role lab_reader login password 'lab-only';
grant usage on schema shop to lab_reader;
grant select on shop.products to lab_reader;
