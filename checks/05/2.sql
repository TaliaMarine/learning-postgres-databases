create temp table _rls_check (ok boolean, what text);

insert into _rls_check
select coalesce((select rolcanlogin from pg_roles where rolname = 'lab_05_agent'), false), 'lab_05_agent exists and can log in';
insert into _rls_check
select coalesce((select relrowsecurity from pg_class where oid = to_regclass('shop.tickets')), false), 'row-level security is enabled on shop.tickets';
insert into _rls_check
select coalesce((select count(*) > 0 from pg_policy where polrelid = to_regclass('shop.tickets')), false), 'shop.tickets has a policy';

do $$
declare total int; mine int; seen int; foreign_seen int;
begin
  -- as superuser, which bypasses row-level security, add known rows
  insert into shop.tickets values (9001, 'lab_05_agent', 'Lost parcel'), (9002, 'lab_05_agent', 'Wrong size'), (9003, 'someone_else', 'Refund please');
  select count(*) into total from shop.tickets;
  select count(*) into mine from shop.tickets where owner_name = 'lab_05_agent';
  set role lab_05_agent;
  select count(*) into seen from shop.tickets;
  select count(*) into foreign_seen from shop.tickets where owner_name <> 'lab_05_agent';
  reset role;
  insert into _rls_check values
    (seen = mine and mine = 2, 'lab_05_agent sees its own 2 rows (sees ' || seen || ')'),
    (foreign_seen = 0 and seen < total, 'lab_05_agent sees nobody else''s rows');
exception when others then
  reset role;
  insert into _rls_check values (false, 'could not test as lab_05_agent: ' || sqlerrm);
end $$;

select * from _rls_check;
