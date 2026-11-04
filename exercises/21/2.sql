-- Create a login role lab_21_reports and give it its own defaults, stored on
-- the role (not in postgresql.conf, and not with SET in your session):
--   work_mem          64MB
--   statement_timeout 30s
-- Every new session of that role should then start with those values.
-- Run ./pg check 21 2 when you are done.

