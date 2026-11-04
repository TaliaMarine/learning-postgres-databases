select coalesce((select prorettype = 'text'::regtype from pg_proc where oid = to_regprocedure('public.lab_wal_distance(pg_lsn,pg_lsn)')), false) as ok, 'public.lab_wal_distance(pg_lsn, pg_lsn) returns text' as what
union all select coalesce(public.lab_wal_distance('0/3000000', '0/1000000') = '32 MB', false), 'lab_wal_distance(0/3000000, 0/1000000) is 32 MB'
union all select coalesce(public.lab_wal_distance('1/0', '0/0') = '4096 MB', false), 'lab_wal_distance(1/0, 0/0) is 4096 MB'
union all select coalesce((select array_agg(attname::text order by attnum) = array['lsn', 'segment', 'segment_size_mb']
                           from pg_attribute where attrelid = to_regclass('public.lab_wal_position') and attnum > 0 and not attisdropped), false), 'lab_wal_position has the columns lsn, segment, segment_size_mb'
union all select coalesce((select atttypid = 'pg_lsn'::regtype from pg_attribute where attrelid = to_regclass('public.lab_wal_position') and attname = 'lsn'), false), 'lsn is a pg_lsn'
union all select (select segment_size_mb = 16 from public.lab_wal_position), 'the segment size is 16 MB'
union all select (select segment ~ '^[0-9A-F]{24}$' and segment = pg_walfile_name(lsn) from public.lab_wal_position), 'the segment name belongs to the reported lsn';
