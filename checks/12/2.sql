create function pg_temp.plan(q text) returns text language plpgsql as $$
declare r json;
begin
  execute 'explain (format json, costs off) ' || q into r;
  return r::text;
end $$;

select exists (select 1 from pg_indexes
               where schemaname = 'analytics' and tablename = 'events' and indexname = 'events_user_feed_idx') as ok,
       'index events_user_feed_idx exists' as what
union all
select pg_temp.plan($q$select * from analytics.events where customer_id = 42 and kind = 'page_view'
                       order by occurred_at desc limit 10$q$) like '%events_user_feed_idx%',
       'the plan uses events_user_feed_idx'
union all
select pg_temp.plan($q$select * from analytics.events where customer_id = 42 and kind = 'page_view'
                       order by occurred_at desc limit 10$q$) not like '%"Sort"%',
       'the plan has no Sort node';
