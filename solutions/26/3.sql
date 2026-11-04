select e.extname                               as extension,
       e.extversion                            as installed_version,
       a.default_version                       as default_version,
       e.extversion = a.default_version        as up_to_date,
       e.extnamespace::regnamespace::text      as schema
from pg_extension e
join pg_available_extensions a on a.name = e.extname;
