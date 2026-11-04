-- Restore the shop schema into a new database that belongs to another role.
--   1. create a role lab_23_owner (it does not need to log in);
--   2. create a database lab_23_restored owned by lab_23_owner
--      (use template0 so it starts empty);
--   3. dump only the schema shop of THIS database (custom format) and restore
--      it into lab_23_restored so that every restored object is owned by
--      lab_23_owner, not by postgres. Stop at the first restore error.
-- Remove the dump file at the end. Then run ./pg check 23 3.

