create table lab_07_note (
  id   integer generated always as identity primary key,
  body text not null
);
create table lab_07_note_tag (
  note_id integer not null references lab_07_note (id) on delete cascade,
  tag     text not null,
  tag_len integer generated always as (length(tag)) stored,
  primary key (note_id, tag)
);
