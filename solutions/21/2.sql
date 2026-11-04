create role lab_21_reports login password 'lab-only';
alter role lab_21_reports set work_mem = '64MB';
alter role lab_21_reports set statement_timeout = '30s';
