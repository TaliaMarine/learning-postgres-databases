create function pg_temp.rejects(stmt text) returns boolean language plpgsql as $f$
begin
  execute stmt;
  return false;
exception
  when integrity_constraint_violation then return true;
  when others then return false;
end $f$;

create function pg_temp.accepts(stmt text) returns boolean language plpgsql as $f$
begin
  execute stmt;
  return true;
exception when others then
  return false;
end $f$;

select exists (select 1 from information_schema.columns where table_name = 'lab_07_coupon' and column_name = 'id' and is_identity = 'YES') as ok, 'id is an identity column' as what
union all select exists (select 1 from pg_constraint where conrelid = to_regclass('lab_07_coupon') and contype = 'p'), 'there is a primary key'
union all select pg_temp.rejects($$insert into lab_07_coupon (code, pct_off) values ('A', 10), ('A', 20)$$), 'a duplicate code is rejected'
union all select pg_temp.rejects($$insert into lab_07_coupon (code, pct_off) values (null, 10)$$), 'a missing code is rejected'
union all select pg_temp.rejects($$insert into lab_07_coupon (code, pct_off) values ('B', null)$$), 'a missing pct_off is rejected'
union all select pg_temp.rejects($$insert into lab_07_coupon (code, pct_off) values ('C', 0)$$), 'pct_off 0 is rejected'
union all select pg_temp.rejects($$insert into lab_07_coupon (code, pct_off) values ('D', 91)$$), 'pct_off 91 is rejected'
union all select pg_temp.accepts($$insert into lab_07_coupon (code, pct_off) values ('E', 1), ('F', 90)$$), 'pct_off 1 and 90 are accepted';
