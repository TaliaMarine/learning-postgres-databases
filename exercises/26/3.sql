-- Before a major upgrade, list what you would have to check or reinstall.
-- Return one row per extension installed in THIS database, with columns:
--   extension          text     the extension name
--   installed_version  text     the version installed here
--   default_version    text     the version the server's files provide
--   up_to_date         boolean  true when the two are equal
--   schema             text     the schema it is installed in
-- Then run ./pg check 26 3.

