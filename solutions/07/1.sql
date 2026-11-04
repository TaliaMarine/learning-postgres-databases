create table lab_07_coupon (
  id      integer generated always as identity primary key,
  code    text not null unique,
  pct_off integer not null check (pct_off between 1 and 90)
);
