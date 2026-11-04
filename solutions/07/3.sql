create extension if not exists btree_gist;
create table lab_07_booking (
  id     integer generated always as identity primary key,
  room   integer not null,
  during tstzrange not null,
  exclude using gist (room with =, during with &&)
);
