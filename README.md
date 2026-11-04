# Learning PostgreSQL

A hands-on course in **PostgreSQL 18** for developers who already write SQL and want to understand the database
underneath: what a database, a schema, a role and a privilege really are, how the planner and transactions
behave, and how to run it.

https://taliamarine.github.io/learning-postgres-databases/

**Read the course:** the site is published with GitHub Pages from this repository (see the
[workflow](.github/workflows/pages.yml)). Build it locally with `python3 tools/build_docs.py` and open
`index.html` in a browser.

## What is in it

| Part | Covers |
|---|---|
| Setup | Docker, one command to start PostgreSQL 18, the shop dataset, the `./pg` helper |
| 1 · Foundations | Architecture, databases and schemas, roles and users, privileges and grants, security and row-level security |
| 2 · Modelling and SQL | Data types, constraints and design, advanced queries, changing data safely, JSONB and arrays, text search |
| 3 · Performance | Indexes, EXPLAIN and the planner, a query-tuning workflow |
| 4 · Transactions | MVCC and isolation levels, locking and concurrency, vacuum and bloat |
| 5 · Programming the database | Views and functions, triggers and notifications, partitioning |
| 6 · Operating PostgreSQL | Configuration, WAL and durability, backup and recovery, replication, monitoring, connections and upgrades |
| 7 · Capstone | A small service database built from a blank cluster |
| Annexes | SELECT basics, joins, aggregation, subqueries and CTEs, DDL and DML, psql, catalog queries, glossary, troubleshooting, what's next |

Each lesson has:

- **Live playgrounds** in the page: a real PostgreSQL 18 running in your browser (WebAssembly), no install needed.
- **Three exercises** that run against a PostgreSQL 18 container on your machine. You edit a file, run
  `./pg check LESSON N`, and the checker tells you whether the database does what the task asks.

## Quick start

```bash
./pg up                 # start PostgreSQL 18 in Docker, seeded with the shop dataset
./pg psql               # interactive session
./pg check 03           # check lesson 3's exercises
./pg solution 03 2      # show a model answer (try first!)
./pg down               # stop
```

Full setup, requirements (Docker, Windows via WSL 2) and troubleshooting are in
[start/setup.html](start/setup.html).

## Repository layout

```
index.html, start/, lessons/, appendices/   the generated site (committed; published by Pages)
_src/                                        page bodies: the source of truth for the site
exercises/NN/K.sql                           starting files you edit
solutions/NN/K.sql                           model answers
checks/NN/K.sql                              assertions for exercises that change state
docker-compose.yml, docker/initdb/          the PostgreSQL 18 container and its seed data
pg                                           the helper script
tools/outline.py                             course order, titles and tags
tools/build_docs.py                          builds the site from outline and _src
tools/check_links.py                         link and anchor checker used in CI
```

## Maintaining the course

```bash
python3 tools/build_docs.py          # rebuild every page
python3 tools/build_docs.py --check  # fails if the committed pages are stale
python3 tools/check_links.py .       # no broken links or anchors
./pg up && ./pg verify               # every solution passes; every unedited stub fails
```

CI runs all of the above on every push and pull request. See [CLAUDE.md](CLAUDE.md) for the conventions that
writers and maintainers follow.

## Licence

To be decided by the repository owner.
