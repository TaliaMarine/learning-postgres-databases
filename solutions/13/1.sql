-- ordered
select s.kind,
       round(c.reltuples::numeric * s.freq::numeric)::int as estimated_rows,
       (select count(*) from analytics.events e where e.kind = s.kind) as actual_rows
from pg_stats p
cross join lateral unnest(p.most_common_vals::text::text[], p.most_common_freqs) as s(kind, freq)
join pg_class c on c.oid = 'analytics.events'::regclass
where p.schemaname = 'analytics' and p.tablename = 'events' and p.attname = 'kind'
order by s.kind;
