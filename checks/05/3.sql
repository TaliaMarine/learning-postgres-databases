create temp table _fn_check (ok boolean, what text);

insert into _fn_check
select coalesce((select not rolcanlogin from pg_roles where rolname = 'lab_05_fn_owner'), false), 'lab_05_fn_owner exists and cannot log in';
insert into _fn_check
select coalesce((select rolcanlogin from pg_roles where rolname = 'lab_05_clerk'), false), 'lab_05_clerk exists and can log in';
insert into _fn_check
select coalesce((select pg_get_userbyid(proowner) = 'lab_05_fn_owner' from pg_proc where oid = to_regprocedure('shop.customer_spend(integer)')), false), 'shop.customer_spend(integer) is owned by lab_05_fn_owner';
insert into _fn_check
select coalesce((select prosecdef from pg_proc where oid = to_regprocedure('shop.customer_spend(integer)')), false), 'the function is SECURITY DEFINER';
insert into _fn_check
select coalesce((select exists (select 1 from unnest(proconfig) c where c like 'search_path=%') from pg_proc where oid = to_regprocedure('shop.customer_spend(integer)')), false), 'the function pins its search_path';
insert into _fn_check
select coalesce((select exists (select 1 from unnest(proconfig) c where c like 'search_path=%' and c not like '%shop%' and c not like '%public%') from pg_proc where oid = to_regprocedure('shop.customer_spend(integer)')), false), 'the pinned search_path contains no user schemas';
insert into _fn_check
select coalesce(has_function_privilege('lab_05_clerk', to_regprocedure('shop.customer_spend(integer)'), 'execute'), false), 'lab_05_clerk can execute the function';
insert into _fn_check
select coalesce(not has_function_privilege('public', to_regprocedure('shop.customer_spend(integer)'), 'execute'), false), 'PUBLIC cannot execute the function';
insert into _fn_check
select coalesce(not has_table_privilege('lab_05_clerk', 'shop.orders', 'select'), false), 'lab_05_clerk cannot read shop.orders directly';

do $$
declare got numeric; want numeric; none numeric;
begin
  select coalesce(sum(total), 0) into want from shop.orders where customer_id = 1;
  set role lab_05_clerk;
  got := shop.customer_spend(1);
  none := shop.customer_spend(-1);
  reset role;
  insert into _fn_check values
    (got = want and want > 0, 'lab_05_clerk gets the right total through the function'),
    (none = 0, 'a customer without orders gives 0');
exception when others then
  reset role;
  insert into _fn_check values (false, 'could not call the function as lab_05_clerk: ' || sqlerrm);
end $$;

select * from _fn_check;
