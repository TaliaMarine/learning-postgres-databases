create function pg_temp.fails(p_sql text) returns boolean language plpgsql as $$
begin
  execute p_sql;
  return false;
exception when others then
  return true;
end $$;

select exists (select 1 from pg_event_trigger where evtname = 'require_app_prefix' and evtevent = 'ddl_command_end') as ok, 'event trigger require_app_prefix runs on ddl_command_end' as what
union all select pg_temp.fails('create table public.lab_untidy (id int)'), 'public.lab_untidy is refused'
union all select not exists (select 1 from pg_class where relname = 'lab_untidy'), 'the refused table was rolled back'
union all select not pg_temp.fails('create table public.app_orders_copy (id int)'), 'public.app_orders_copy is allowed'
union all select not pg_temp.fails('create table shop.lab_anything (id int)'), 'tables in schema shop are not restricted';
