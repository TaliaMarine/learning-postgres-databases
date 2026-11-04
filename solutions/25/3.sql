create extension if not exists dblink;
begin;
update shop.products set stock = stock where id = 1;
do $$
begin
  perform dblink_connect('worker', 'dbname=' || current_database() || ' application_name=lab_worker');
  perform dblink_send_query('worker', 'update shop.products set stock = stock + 1 where id = 1');
  perform pg_sleep(1);
end $$;

select w.application_name,
       w.state,
       w.wait_event_type,
       w.wait_event,
       pg_blocking_pids(w.pid) = array[pg_backend_pid()] as blocked_by_me,
       w.query
from pg_stat_activity w
where w.datname = current_database()
  and cardinality(pg_blocking_pids(w.pid)) > 0;

rollback;
select dblink_disconnect('worker') \gset
