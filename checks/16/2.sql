create temp table lab_r (n int, got int);
do $$
begin
  for i in 1..6 loop
    insert into lab_r values (i, shop.lab_claim_job());
  end loop;
end $$;
select (select count(*) from shop.lab_jobs) = 5 as ok, 'five jobs exist' as what
union all select (select got from lab_r where n = 1) = 1, 'first call claims job 1'
union all select (select got from lab_r where n = 2) = 2, 'second call claims job 2'
union all select (select got from lab_r where n = 5) = 5, 'fifth call claims job 5'
union all select (select got from lab_r where n = 6) is null, 'sixth call returns NULL (queue empty)'
union all select (select count(*) from shop.lab_jobs where claimed_at is not null) = 5, 'every job has claimed_at set'
union all select prosrc ilike '%skip locked%', 'the function uses SKIP LOCKED' from pg_proc where proname = 'lab_claim_job' and pronamespace = 'shop'::regnamespace;
