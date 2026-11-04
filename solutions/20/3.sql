create table analytics.events_p (
  id          bigint      not null,
  occurred_at timestamptz not null,
  customer_id integer,
  kind        text        not null,
  payload     jsonb       not null default '{}',
  primary key (id, occurred_at)
) partition by range (occurred_at);

do $$
declare
  m date;
begin
  for m in select generate_series(date '2025-01-01', date '2025-12-01', interval '1 month')::date loop
    execute format('create table analytics.%I partition of analytics.events_p for values from (%L) to (%L)',
                   'events_' || to_char(m, 'YYYY_MM'), m, (m + interval '1 month')::date);
  end loop;
end
$$;
create table analytics.events_default partition of analytics.events_p default;

insert into analytics.events_p (id, occurred_at, customer_id, kind, payload)
select id, occurred_at, customer_id, kind, payload from analytics.events;

alter table analytics.events_p detach partition analytics.events_2025_01;
drop table analytics.events_2025_01;
