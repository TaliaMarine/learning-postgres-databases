create function pg_temp.rejects(stmt text) returns boolean language plpgsql as $f$
begin
  execute stmt;
  return false;
exception
  when integrity_constraint_violation then return true;
  when others then return false;
end $f$;

create function pg_temp.tag_len_works() returns boolean language plpgsql as $f$
declare nid integer; len integer;
begin
  insert into lab_07_note (body) values ('hello') returning id into nid;
  insert into lab_07_note_tag (note_id, tag) values (nid, 'urgent') returning tag_len into len;
  return len = 6;
exception when others then
  return false;
end $f$;

select exists (select 1 from information_schema.columns where table_name = 'lab_07_note' and column_name = 'id' and is_identity = 'YES') as ok, 'lab_07_note.id is an identity column' as what
union all select exists (select 1 from pg_constraint where conrelid = to_regclass('lab_07_note_tag') and contype = 'p' and array_length(conkey, 1) = 2), 'tag table has a two-column primary key'
union all select exists (select 1 from pg_constraint where conrelid = to_regclass('lab_07_note_tag') and contype = 'f' and confrelid = to_regclass('lab_07_note') and confdeltype = 'c'), 'foreign key to lab_07_note with on delete cascade'
union all select exists (select 1 from pg_attribute where attrelid = to_regclass('lab_07_note_tag') and attname = 'tag_len' and attgenerated = 's'), 'tag_len is a stored generated column'
union all select pg_temp.rejects($$insert into lab_07_note_tag (note_id, tag) values (999, 'x')$$), 'a tag for a missing note is rejected'
union all select pg_temp.tag_len_works(), 'tag_len is computed (urgent = 6)';
