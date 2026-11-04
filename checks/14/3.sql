create function pg_temp.plan(q text) returns text language plpgsql as $$
declare r text;
begin
  execute 'explain (format json) ' || q into r;
  return r;
end $$;

select count(*) = 1 as ok, 'analytics.events has a secondary index starting with customer_id' as what
from pg_index i
where i.indrelid = 'analytics.events'::regclass and not i.indisprimary
  and i.indisvalid and i.indkey[0] = (select attnum from pg_attribute where attrelid = 'analytics.events'::regclass and attname = 'customer_id')
union all
select pg_temp.plan('select id, occurred_at from analytics.events where customer_id = 4242 order by occurred_at desc limit 10') like '%"Node Type": "Index%',
       'the latest-10 query uses an index scan'
union all
select pg_temp.plan('select id, occurred_at from analytics.events where customer_id = 4242 order by occurred_at desc limit 10') not like '%"Sort"%',
       'the latest-10 query needs no Sort step';
