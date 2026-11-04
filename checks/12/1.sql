create function pg_temp.plan(q text) returns text language plpgsql as $$
declare r json;
begin
  execute 'explain (format json, costs off) ' || q into r;
  return r::text;
end $$;

select exists (select 1 from pg_indexes
               where schemaname = 'analytics' and tablename = 'events' and indexname = 'events_customer_idx'
                 and indexdef like '%(customer_id)%') as ok,
       'index events_customer_idx exists on (customer_id)' as what
union all
select pg_temp.plan('select * from analytics.events where customer_id = 42') like '%events_customer_idx%',
       'the plan for customer_id = 42 uses events_customer_idx';
