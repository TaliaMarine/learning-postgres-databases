create role lab_05_fn_owner nologin;
create role lab_05_clerk login password 'lab-only';
grant usage on schema shop to lab_05_fn_owner, lab_05_clerk;
grant select on shop.orders to lab_05_fn_owner;

create function shop.customer_spend(p_customer integer) returns numeric
  language sql stable security definer
  set search_path = pg_catalog, pg_temp
  as $$ select coalesce(sum(o.total), 0) from shop.orders o where o.customer_id = p_customer $$;

alter function shop.customer_spend(integer) owner to lab_05_fn_owner;
revoke execute on function shop.customer_spend(integer) from public;
grant execute on function shop.customer_spend(integer) to lab_05_clerk;
