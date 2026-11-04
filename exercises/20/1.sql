-- Create a range-partitioned table public.lab_readings with the columns
--   id bigint not null, taken_at timestamptz not null, value numeric
-- partitioned by RANGE (taken_at). It needs a primary key (think about which
-- columns it must contain). Add three partitions:
--   public.lab_readings_2025_01   January 2025   (2025-01-01 up to, not including, 2025-02-01)
--   public.lab_readings_2025_02   February 2025
--   public.lab_readings_default   the default partition
-- Run ./pg check 20 1 when you are done.

