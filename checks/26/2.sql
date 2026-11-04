create function pg_temp.upper_dup_rejected() returns boolean language plpgsql as $$
begin
  insert into shop.customers (email, full_name, country, created_at)
  select upper(email), full_name, country, created_at from shop.customers order by id limit 1;
  return false;
exception when unique_violation then
  return true;
end $$;

select exists (select 1 from pg_extension where extname = 'citext' and extnamespace = 'public'::regnamespace) as ok,
       'the citext extension is installed in schema public' as what
union all
select coalesce((select format_type(atttypid, atttypmod) in ('citext', 'public.citext')
                 from pg_attribute where attrelid = 'shop.customers'::regclass and attname = 'email'), false),
       'shop.customers.email is of type citext'
union all
select (select count(*) from shop.customers) = 20000, 'shop.customers still has all 20000 rows'
union all
select pg_temp.upper_dup_rejected(), 'an upper-case copy of an existing email is rejected';
