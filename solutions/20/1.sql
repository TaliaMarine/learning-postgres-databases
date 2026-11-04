create table public.lab_readings (
  id       bigint      not null,
  taken_at timestamptz not null,
  value    numeric,
  primary key (id, taken_at)
) partition by range (taken_at);

create table public.lab_readings_2025_01 partition of public.lab_readings
  for values from ('2025-01-01') to ('2025-02-01');
create table public.lab_readings_2025_02 partition of public.lab_readings
  for values from ('2025-02-01') to ('2025-03-01');
create table public.lab_readings_default partition of public.lab_readings default;
