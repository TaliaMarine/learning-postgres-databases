create function pg_temp.untouched() returns boolean language plpgsql as $$
declare before text; inside text; after text;
begin
  set work_mem = '10MB';
  before := current_setting('work_mem');
  inside := public.lab_sort_mem();
  after  := current_setting('work_mem');
  return before = '10MB' and after = '10MB' and inside = '128MB';
end $$;

select coalesce((select prorettype = 'text'::regtype from pg_proc where oid = to_regprocedure('public.lab_sort_mem()')), false) as ok, 'public.lab_sort_mem() returns text' as what
union all select coalesce((select 'work_mem=128MB' = any (proconfig) from pg_proc where oid = to_regprocedure('public.lab_sort_mem()')), false), 'work_mem = 128MB is attached to the function'
union all select coalesce(pg_temp.untouched(), false), 'inside it reports 128MB while the caller keeps its own 10MB';
