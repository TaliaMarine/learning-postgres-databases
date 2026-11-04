-- ordered
select name, setting, unit, context, (context = 'postmaster') as needs_restart
from pg_settings
where name in ('shared_buffers', 'work_mem', 'maintenance_work_mem', 'effective_cache_size',
               'max_connections', 'random_page_cost', 'effective_io_concurrency',
               'checkpoint_timeout', 'max_wal_size', 'log_min_duration_statement')
order by name;
