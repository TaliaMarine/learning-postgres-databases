-- Create the table public.lab_vac_demo (id integer primary key, note text) and
-- put 1000 rows in it (note = 'row 1' ... 'row 1000'). Then append the text
-- ' (edited)' to the note of the first 300 rows (id 1..300), which leaves 300
-- dead row versions behind. Finally run a plain VACUUM (not VACUUM FULL) on the
-- table. Run ./pg check 17 2 when you are done.

