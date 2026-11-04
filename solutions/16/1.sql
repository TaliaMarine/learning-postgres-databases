create role lab_16_app login password 'lab-only';
alter role lab_16_app set lock_timeout = '2s';
alter role lab_16_app set idle_in_transaction_session_timeout = '1min';
