create function public.lab_wal_distance(a pg_lsn, b pg_lsn) returns text
language sql
immutable
as $$ select pg_size_pretty(a - b) $$;

create view public.lab_wal_position as
select pg_current_wal_lsn()                                         as lsn,
       pg_walfile_name(pg_current_wal_lsn())                        as segment,
       (pg_size_bytes(current_setting('wal_segment_size')) / 1048576)::int as segment_size_mb;
