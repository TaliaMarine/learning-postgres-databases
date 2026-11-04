create role lab_05_owner nologin;
create role lab_05_ro nologin;
alter schema shop owner to lab_05_owner;
grant usage on schema shop to lab_05_ro;
grant select on all tables in schema shop to lab_05_ro;
