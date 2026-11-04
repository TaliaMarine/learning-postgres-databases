create function public.require_app_prefix() returns event_trigger
language plpgsql
as $$
declare
  r record;
begin
  for r in select * from pg_event_trigger_ddl_commands() loop
    if r.schema_name = 'public' and r.object_identity not like 'public.app\_%' then
      raise exception 'tables in public must be named app_*, got %', r.object_identity;
    end if;
  end loop;
end;
$$;

create event trigger require_app_prefix
on ddl_command_end
when tag in ('CREATE TABLE')
execute function public.require_app_prefix();
