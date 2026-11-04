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

select exists (select 1 from pg_constraint where conrelid = to_regclass('lab_07_booking') and contype = 'x') as ok, 'there is an exclusion constraint' as what
union all select exists (select 1 from information_schema.columns where table_name = 'lab_07_booking' and column_name = 'id' and is_identity = 'YES'), 'id is an identity column'
union all select pg_temp.accepts($$insert into lab_07_booking (room, during) values (1, '[2030-01-01 10:00+00,2030-01-01 11:00+00)')$$), 'a first booking is accepted'
union all select pg_temp.rejects($$insert into lab_07_booking (room, during) values (1, '[2030-01-01 10:30+00,2030-01-01 11:30+00)')$$), 'an overlapping booking of the same room is rejected'
union all select pg_temp.accepts($$insert into lab_07_booking (room, during) values (2, '[2030-01-01 10:30+00,2030-01-01 11:30+00)')$$), 'the same time in another room is accepted'
union all select pg_temp.accepts($$insert into lab_07_booking (room, during) values (1, '[2030-01-01 11:00+00,2030-01-01 12:00+00)')$$), 'a back-to-back booking of the same room is accepted';
