create table public.lab_vac_demo (id integer primary key, note text);
insert into public.lab_vac_demo select g, 'row ' || g from generate_series(1, 1000) g;
update public.lab_vac_demo set note = note || ' (edited)' where id <= 300;
vacuum public.lab_vac_demo;
