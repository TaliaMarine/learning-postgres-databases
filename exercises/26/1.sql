-- How much connection room does this server have? Return ONE row with:
--   max_connections      integer  the max_connections setting
--   reserved             integer  superuser_reserved_connections + reserved_connections
--   for_normal_roles     integer  max_connections minus reserved
--   connections_here     bigint   client backends connected to THIS database right now
--   needs_restart        boolean  true when changing max_connections needs a
--                                 server restart (look at pg_settings.context)
-- Then run ./pg check 26 1.

