-- Write an event trigger that keeps the public schema tidy: after a plain
-- CREATE TABLE, raise an exception if the new table is in schema public and
-- its name does not start with 'app_'. Tables in other schemas (such as shop)
-- stay unrestricted. Because the exception happens at the end of the command,
-- PostgreSQL rolls the CREATE TABLE back.
-- Name the function public.require_app_prefix and the trigger require_app_prefix.
-- Run ./pg check 19 3 when you are done.

