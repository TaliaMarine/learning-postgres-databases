-- ordered
select name, setting, context
from pg_settings
where name in ('fsync', 'full_page_writes', 'synchronous_commit', 'wal_level', 'wal_segment_size')
order by name;
