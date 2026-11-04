create role lab_02_dev login password 'lab-only';
create schema dev authorization lab_02_dev;
alter role lab_02_dev set search_path = dev, shop;
