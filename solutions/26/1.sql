select current_setting('max_connections')::integer as max_connections,
       current_setting('superuser_reserved_connections')::integer
         + current_setting('reserved_connections')::integer as reserved,
       current_setting('max_connections')::integer
         - current_setting('superuser_reserved_connections')::integer
         - current_setting('reserved_connections')::integer as for_normal_roles,
       (select count(*) from pg_stat_activity
        where backend_type = 'client backend' and datname = current_database()) as connections_here,
       (select context = 'postmaster' from pg_settings where name = 'max_connections') as needs_restart;
