-- Is this server a primary, and is it ready for replicas? Return ONE row with
-- these columns:
--   in_recovery        boolean  true on a standby, false on a primary
--   standbys           bigint   standbys connected right now (pg_stat_replication)
--   slots              bigint   replication slots that exist (pg_replication_slots)
--   wal_level          text     the current wal_level setting
--   logical_ready      boolean  true when wal_level is 'logical'
--   max_wal_senders    integer  the max_wal_senders setting, as an integer
-- Then run ./pg check 24 1.

