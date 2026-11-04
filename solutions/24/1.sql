select pg_is_in_recovery()                                    as in_recovery,
       (select count(*) from pg_stat_replication)             as standbys,
       (select count(*) from pg_replication_slots)            as slots,
       current_setting('wal_level')                           as wal_level,
       current_setting('wal_level') = 'logical'               as logical_ready,
       current_setting('max_wal_senders')::integer            as max_wal_senders;
