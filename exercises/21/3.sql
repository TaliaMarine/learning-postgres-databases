-- Some functions need a lot of sort memory only while they run.
-- Create a function public.lab_sort_mem() that returns text: the value of
-- work_mem as seen from inside the function. Make it always 128MB there, no
-- matter what the caller has set, by attaching the setting to the function
-- itself (not by calling SET inside the body). Outside the function, the
-- caller's own work_mem must be left alone.
-- Run ./pg check 21 3 when you are done.

