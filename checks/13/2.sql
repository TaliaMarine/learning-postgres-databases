create function pg_temp.plan_rows(q text) returns numeric language plpgsql as $$
declare j jsonb;
begin
  execute 'explain (format json) ' || q into j;
  return (j -> 0 -> 'Plan' ->> 'Plan Rows')::numeric;
end $$;

select exists (select 1 from pg_statistic_ext where stxname = 'lab_ev_device') as ok,
       'extended statistics lab_ev_device exist' as what
union all
select exists (select 1 from pg_statistic_ext_data d join pg_statistic_ext s on s.oid = d.stxoid
               where s.stxname = 'lab_ev_device' and d.stxdexpr is not null),
       'lab_ev_device has been populated by ANALYZE'
union all
select pg_temp.plan_rows('select * from analytics.events where payload ->> ''device'' = ''mobile''') between 300000 and 370000,
       'estimate for device = mobile is within the right range (real count is 332937)';
