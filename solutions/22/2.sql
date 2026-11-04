create table public.lab_kept_events (id integer, note text);
create unlogged table public.lab_scratch_events (id integer, note text);

insert into public.lab_kept_events    select g, 'event ' || g from generate_series(1, 1000) g;
insert into public.lab_scratch_events select g, 'event ' || g from generate_series(1, 1000) g;
