"""The course outline: the single source of truth for pages, order and navigation.

Everything else (sidebar, prev/next pager, search index, home-page lesson list,
the required-entry-point check in CI) is generated from this file. To add a page:
add one line here and write _src/<path>.html with a <!--meta--> header.

Fields: (slug, title, description, tags)
  slug  - file name without .html; for lessons it starts with the two-digit number
  tags  - subset of: "ex" (has Docker exercises), "pgl" (has in-browser playground)
"""

START = [
    ("setup", "Set up your lab",
     "Install Docker, start PostgreSQL 18 with one command, meet the shop dataset, learn the ./pg helper and the in-browser playground.",
     ["pgl"]),
]

# (part title, blurb, [lessons])
PARTS = [
    ("Part 1 — Foundations: the server, databases, schemas and roles",
     "Before any query tuning: what a cluster, a database, a schema, a role and a privilege actually are, and how they fit together.",
     [
        ("01-architecture", "How PostgreSQL is built", "Cluster, postmaster, backends, shared buffers, WAL, the data directory and the life of a query.", ["ex", "pgl"]),
        ("02-databases-and-schemas", "Databases and schemas", "The object hierarchy, templates, search_path, the system catalogs and how to find anything with psql.", ["ex", "pgl"]),
        ("03-roles-and-users", "Roles and users", "There is only one thing: a role. Login, attributes, membership, inheritance, ownership and pg_hba.conf.", ["ex", "pgl"]),
        ("04-privileges-and-grants", "Privileges and grants", "GRANT and REVOKE at every level, PUBLIC, default privileges, column privileges, and how to audit who can do what.", ["ex", "pgl"]),
        ("05-security-and-rls", "Hardening and row-level security", "A least-privilege layout for an application, the public schema trap, row-level security, SECURITY DEFINER and passwords.", ["ex", "pgl"]),
     ]),
    ("Part 2 — Modelling and SQL in depth",
     "Types, constraints and the parts of SQL beyond the basics that you will use every week.",
     [
        ("06-data-types", "Data types", "Numbers, text, time zones, uuid, enums, ranges, arrays and the mistakes each one invites.", ["ex", "pgl"]),
        ("07-constraints-and-design", "Constraints and schema design", "Keys, foreign keys and their actions, check and exclusion constraints, identity, generated columns, normalisation.", ["ex", "pgl"]),
        ("08-advanced-queries", "Advanced queries", "CTEs, window functions, LATERAL, grouping sets, FILTER, recursive queries, set operations.", ["ex", "pgl"]),
        ("09-changing-data", "Changing data safely", "INSERT ... ON CONFLICT, RETURNING, MERGE, UPDATE ... FROM, COPY and bulk loading.", ["ex", "pgl"]),
        ("10-json-and-arrays", "JSONB and arrays", "When to use JSONB, operators, path queries, indexing it, and when a column would have been better.", ["ex", "pgl"]),
        ("11-text-search", "Text search and pattern matching", "LIKE and its limits, full-text search, ranking, trigram similarity and which index serves each.", ["ex", "pgl"]),
     ]),
    ("Part 3 — Performance",
     "Reading plans, building the right index and finding the queries that matter.",
     [
        ("12-indexes", "Indexes", "B-tree, composite, partial, expression and covering indexes; GIN, GiST, BRIN; what an index costs.", ["ex", "pgl"]),
        ("13-explain-and-planner", "EXPLAIN and the planner", "Reading plans, statistics, selectivity, join algorithms, and why the planner sometimes picks badly.", ["ex", "pgl"]),
        ("14-query-tuning", "A query-tuning workflow", "pg_stat_statements, finding the slow query, rewriting, pagination, N+1 and a repeatable method.", ["ex"]),
     ]),
    ("Part 4 — Transactions and concurrency",
     "What ACID means in practice, how MVCC lets readers and writers coexist, and what happens when they collide.",
     [
        ("15-transactions-and-mvcc", "Transactions and MVCC", "Snapshots, xmin/xmax, isolation levels, and what each level really prevents.", ["ex", "pgl"]),
        ("16-locking", "Locking and concurrency", "Row and table locks, lock queues, deadlocks, SELECT FOR UPDATE, SKIP LOCKED, advisory locks, safe migrations.", ["ex", "pgl"]),
        ("17-vacuum-and-bloat", "Vacuum, bloat and autovacuum", "Dead tuples, HOT updates, autovacuum tuning, wraparound and how to measure bloat.", ["ex"]),
     ]),
    ("Part 5 — Programming the database",
     "Logic that lives next to the data, and the structures that keep very large tables manageable.",
     [
        ("18-views-and-functions", "Views, functions and procedures", "Views, materialized views, SQL and PL/pgSQL functions, procedures, volatility.", ["ex", "pgl"]),
        ("19-triggers-and-events", "Triggers, LISTEN/NOTIFY and audit", "Row and statement triggers, audit trails, event triggers, LISTEN/NOTIFY and their pitfalls.", ["ex", "pgl"]),
        ("20-partitioning", "Partitioning", "Range, list and hash partitioning, pruning, retention by dropping partitions, and when not to.", ["ex"]),
     ]),
    ("Part 6 — Operating PostgreSQL",
     "Running it for real: configuration, durability, backups, replication, monitoring and upgrades.",
     [
        ("21-configuration", "Configuration and tuning", "How settings are layered, the ten that matter, memory sizing, ALTER SYSTEM and per-role settings.", ["ex"]),
        ("22-wal-and-durability", "WAL, checkpoints and durability", "Why a crash loses nothing, checkpoints, fsync, synchronous_commit and the cost of each.", ["ex"]),
        ("23-backup-and-recovery", "Backup, restore and PITR", "pg_dump, pg_restore, base backups, WAL archiving, point-in-time recovery, and testing restores.", ["ex"]),
        ("24-replication", "Replication and high availability", "Streaming and logical replication, replicas, failover, lag, and what HA tools do for you.", ["ex"]),
        ("25-monitoring", "Monitoring and diagnostics", "The pg_stat views, logs, locks, connections, and a checklist for \"the database is slow\".", ["ex"]),
        ("26-connections-and-upgrades", "Connections, pooling, extensions and upgrades", "Why connections are expensive, pgbouncer, extensions, minor and major upgrades.", ["ex"]),
     ]),
    ("Part 7 — Putting it together",
     "One end-to-end project that uses roles, schema design, indexes, transactions and backup together.",
     [
        ("27-capstone", "Capstone project", "Design, secure, load, tune and back up a small service database from a blank cluster.", ["ex"]),
     ]),
]

ANNEXES = [
    ("a1-select-basics", "A1. SELECT, filtering and sorting", "Refresher with a live database: SELECT, WHERE, ORDER BY, LIMIT, DISTINCT, NULL handling, expressions.", ["pgl"]),
    ("a2-joins", "A2. Joins and combining tables", "INNER, LEFT, RIGHT, FULL and CROSS joins and set operations, each runnable and visualised.", ["pgl"]),
    ("a3-aggregation", "A3. Aggregation and grouping", "COUNT, SUM, AVG, GROUP BY, HAVING, FILTER and how NULL behaves in each.", ["pgl"]),
    ("a4-subqueries-and-ctes", "A4. Subqueries and CTEs", "Scalar, row and table subqueries, EXISTS, IN, correlated subqueries and WITH.", ["pgl"]),
    ("a5-ddl-and-dml", "A5. Creating and changing things", "CREATE TABLE, ALTER, INSERT, UPDATE, DELETE, transactions and constraints at the basic level.", ["pgl"]),
    ("b-psql", "B. psql cheat sheet", "Every meta-command and setting you will actually use, with examples.", []),
    ("c-catalog-queries", "C. Catalog and diagnostic queries", "A library of copy-paste queries over pg_catalog and pg_stat_* for everyday questions.", ["pgl"]),
    ("d-glossary", "D. Glossary", "Every PostgreSQL term used in the course, defined in one or two sentences.", []),
    ("e-troubleshooting", "E. Troubleshooting", "Error messages you will meet, what they mean and what to do.", []),
    ("f-whats-next", "F. What to learn next", "Topics deliberately left out, and where to go for each.", []),
]


def lesson_number(slug: str) -> str:
    return slug.split("-", 1)[0]
