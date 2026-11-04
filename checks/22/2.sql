select coalesce((select relpersistence = 'p' from pg_class where oid = to_regclass('public.lab_kept_events')), false) as ok, 'lab_kept_events is an ordinary, logged table' as what
union all select coalesce((select relpersistence = 'u' from pg_class where oid = to_regclass('public.lab_scratch_events')), false), 'lab_scratch_events is unlogged'
union all select (select count(*) = 1000 from public.lab_kept_events), 'lab_kept_events holds 1000 rows'
union all select (select count(*) = 1000 from public.lab_scratch_events), 'lab_scratch_events holds 1000 rows'
union all select (select count(*) = 2 from pg_attribute where attrelid = to_regclass('public.lab_scratch_events') and attnum > 0 and not attisdropped and attname in ('id', 'note')), 'lab_scratch_events has the columns id and note';
