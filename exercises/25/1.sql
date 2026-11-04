-- Find your own session in pg_stat_activity (pg_backend_pid() is your
-- process id) and return one row with these columns:
--   backend_type     text     what kind of process it is
--   state            text     what it is doing right now
--   is_waiting       boolean  true when wait_event is not null
--   in_this_database boolean  true when datname is the current database
--   sees_itself      boolean  true when its query text mentions pg_stat_activity
-- Then run ./pg check 25 1.

