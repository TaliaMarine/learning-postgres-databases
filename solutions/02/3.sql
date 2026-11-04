create role lab_02_owner login password 'lab-only';
create database lab_02_copy template shop_template owner lab_02_owner connection limit 3;
