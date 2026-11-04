select backend_type,
       state,
       wait_event is not null              as is_waiting,
       datname = current_database()        as in_this_database,
       query like '%pg_stat_activity%'     as sees_itself
from pg_stat_activity
where pid = pg_backend_pid();
