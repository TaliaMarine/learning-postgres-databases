-- For these ten settings, return name, setting (as text), unit and context
-- (all from pg_settings):
--   shared_buffers, work_mem, maintenance_work_mem, effective_cache_size,
--   max_connections, random_page_cost, effective_io_concurrency,
--   checkpoint_timeout, max_wal_size, log_min_duration_statement
-- plus one extra column needs_restart (boolean): true when changing the
-- setting requires a server restart (context = 'postmaster').
-- Order by name. Run ./pg check 21 1 when you are done.

