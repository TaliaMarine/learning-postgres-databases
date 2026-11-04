create function pg_temp.plan(q text) returns text language plpgsql as $$
declare r json;
begin
  execute 'explain (format json, costs off) ' || q into r;
  return r::text;
end $$;

select exists (select 1 from pg_index i
               where i.indexrelid = to_regclass('analytics.events_purchase_customer_idx')
                 and i.indrelid = 'analytics.events'::regclass
                 and i.indpred is not null) as ok,
       'events_purchase_customer_idx is a partial index on analytics.events' as what
union all
select coalesce(pg_relation_size(to_regclass('analytics.events_purchase_customer_idx')) < 1024 * 1024, false),
       'the index is smaller than 1 MB'
union all
select pg_temp.plan($q$select * from analytics.events where kind = 'purchase' and customer_id = 42$q$)
         like '%events_purchase_customer_idx%',
       'the plan for kind = purchase and customer_id = 42 uses it';
