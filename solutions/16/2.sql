create table shop.lab_jobs (
  id         integer generated always as identity primary key,
  payload    text not null,
  claimed_at timestamptz
);
insert into shop.lab_jobs (payload) select 'job-' || g from generate_series(1, 5) g;

create function shop.lab_claim_job() returns integer
language sql as $$
  update shop.lab_jobs
  set claimed_at = clock_timestamp()
  where id = (select id
              from shop.lab_jobs
              where claimed_at is null
              order by id
              for update skip locked
              limit 1)
  returning id
$$;
