create function public.lab_sort_mem() returns text
language sql
stable
set work_mem = '128MB'
as $$ select current_setting('work_mem') $$;
