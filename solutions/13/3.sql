create function public.lab_plan_nodes(q text) returns setof text
language plpgsql as $$
declare
  j jsonb;
begin
  execute 'explain (format json) ' || q into j;
  return query
    select distinct jsonb_path_query(j, 'strict $.**."Node Type"') #>> '{}'
    order by 1;
end
$$;
