select r.rolcanlogin as ok, 'lab_16_app can log in' as what from pg_roles r where r.rolname = 'lab_16_app'
union all select 'lock_timeout=2s' = any (r.rolconfig), 'lock_timeout is 2s for the role' from pg_roles r where r.rolname = 'lab_16_app'
union all select 'idle_in_transaction_session_timeout=1min' = any (r.rolconfig), 'idle_in_transaction_session_timeout is 1min for the role' from pg_roles r where r.rolname = 'lab_16_app';
