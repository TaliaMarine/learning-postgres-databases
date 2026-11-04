insert into public.lab_readings (id, taken_at, value) values
  (1, '2025-01-15 12:00+00', 1), (2, '2025-02-20 12:00+00', 2), (3, '2025-02-28 23:59+00', 3), (4, '2026-07-01 00:00+00', 4);

select (select relkind = 'p' from pg_class where oid = to_regclass('public.lab_readings')) as ok, 'public.lab_readings is a partitioned table' as what
union all select (select partstrat = 'r' and partnatts = 1 from pg_partitioned_table where partrelid = to_regclass('public.lab_readings')), 'it is partitioned by range on one column'
union all select (select count(*) = 3 from pg_inherits where inhparent = to_regclass('public.lab_readings')), 'it has three partitions'
union all select (select tableoid::regclass::text = 'lab_readings_2025_01' from public.lab_readings where id = 1), 'a January row lands in lab_readings_2025_01'
union all select (select tableoid::regclass::text = 'lab_readings_2025_02' from public.lab_readings where id = 3), 'the last minute of February lands in lab_readings_2025_02'
union all select (select tableoid::regclass::text = 'lab_readings_default' from public.lab_readings where id = 4), 'a row from 2026 lands in the default partition'
union all select (select count(*) = 1 from pg_constraint where conrelid = to_regclass('public.lab_readings') and contype = 'p'), 'the table has a primary key';
