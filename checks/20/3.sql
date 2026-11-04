create function pg_temp.plan_text(p_sql text) returns text language plpgsql as $$
declare line text; acc text := '';
begin
  for line in execute 'explain (costs off) ' || p_sql loop acc := acc || line || E'\n'; end loop;
  return acc;
end $$;

select (select relkind = 'p' and (select partstrat from pg_partitioned_table where partrelid = c.oid) = 'r' from pg_class c where c.oid = to_regclass('analytics.events_p')) as ok, 'analytics.events_p is range-partitioned' as what
union all select (select count(*) = 12 from pg_inherits where inhparent = to_regclass('analytics.events_p')), 'it has 12 partitions: 11 months and the default'
union all select to_regclass('analytics.events_2025_01') is null, 'the January partition is gone'
union all select (select count(*) = 11 from pg_inherits i join pg_class c on c.oid = i.inhrelid where i.inhparent = to_regclass('analytics.events_p') and c.relname ~ '^events_2025_(0[2-9]|1[0-2])$'), 'February to December partitions are attached'
union all select (select count(*) = (select count(*) from analytics.events where occurred_at >= '2025-02-01') from analytics.events_p), 'every row from February onwards was kept'
union all select (select count(*) = 0 from analytics.events_p where occurred_at < '2025-02-01'), 'no January row remains'
union all select (select count(*) = 0 from analytics.events_default), 'the default partition is empty'
union all select pg_temp.plan_text('select count(*) from analytics.events_p where occurred_at >= ''2025-03-01'' and occurred_at < ''2025-04-01''') like '%events_2025_03%'
                 and pg_temp.plan_text('select count(*) from analytics.events_p where occurred_at >= ''2025-03-01'' and occurred_at < ''2025-04-01''') not like '%events_2025_04%',
                 'a query for March scans only the March partition';
