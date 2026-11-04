-- Create two tables in schema public with the columns (id integer, note text):
--   public.lab_kept_events      an ordinary (WAL-logged) table
--   public.lab_scratch_events   an UNLOGGED table (no WAL, emptied after a crash)
-- Insert 1000 rows into each (id 1..1000, note = 'event ' || id).
-- Run ./pg check 22 2 when you are done.

