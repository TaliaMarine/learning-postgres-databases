-- Make a custom-format (-Fc) dump of the database this file runs in, and save
-- it inside the container as /tmp/lab_23_1.dump. Run pg_dump from this file
-- with psql's \! command (it runs a shell command). Two psql lines tell
-- pg_dump which database and user to use:
--   \setenv PGDATABASE :DBNAME
--   \setenv PGUSER postgres
-- Leave the dump file in place; the check reads it and then removes it.
-- Then run ./pg check 23 1.

