# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

**Learning PostgreSQL** — an English, hands-on PostgreSQL 18 course for application
developers who already know some SQL and want to understand the database underneath:
objects, roles and privileges, the planner, transactions, and operations. It is a
static HTML site (published to GitHub Pages) plus a local Docker database that the
reader runs their own exercises against.

Modelled on `learning-go-course-beginner` (lesson template, exercise layout) and on
`generated-docs` (fragment → page build, link checker, Pages workflow).

## Layout

```
index.html                          GENERATED home page (from _src/index.html)
start/setup.html                    GENERATED — Docker, ./pg, the dataset
lessons/NN-slug.html                GENERATED — 27 lessons in seven parts
appendices/*.html                   GENERATED — annexes A1–A5, B, C, D, E, F
assets/css/course.css               shared stylesheet (hand-written)
assets/js/course.js                 shared behaviour: chrome, search, labs, playground
assets/js/mini-seed.js              GENERATED from tools/mini_seed.sql
assets/js/search-index.js           GENERATED
_src/                               THE SOURCE: page bodies only (no <html>, no nav, no h1 for lessons)
  index.html  start/setup.html  lessons/NN-slug.html  appendices/slug.html
exercises/NN/K.sql                  the student's starting file (K = 1, 2, 3, ...)
solutions/NN/K.sql                  model solution — verified by ./pg verify
checks/NN/K.sql                     optional: assertions for "state" exercises (roles, grants, DDL)
docker/initdb/*.sql|sh              seed data and template, run once on an empty volume
docker-compose.yml                  PostgreSQL 18 service
pg                                  the helper every reader uses (up, psql, check, solution, verify, ...)
tools/outline.py                    THE course outline: order, titles, descriptions, tags
tools/build_docs.py                 builds all generated pages from outline + _src
tools/check_links.py                link and anchor checker, run in CI
tools/mini_seed.sql                 the seed for the in-browser playground
.github/workflows/pages.yml         build check, link check, publish
```

To add or rename a lesson: change `tools/outline.py`, add `_src/lessons/NN-slug.html`,
then run `python3 tools/build_docs.py`. The sidebar, pager, search and home page follow.

## Build and verify

```bash
python3 tools/build_docs.py         # regenerate every page (commit the result)
python3 tools/build_docs.py --check # fails if committed generated files are stale
python3 tools/check_links.py .      # no broken links or anchors
./pg up && ./pg verify              # every solution passes, every unedited stub fails
```

`./pg verify` needs the Docker database running. It creates and drops temporary
databases and `lab_*` roles, so **do not run it while another check is running**.

## Placeholders in fragments

- `{{stub NN K}}` — inserts `exercises/NN/K.sql` as a code block (the starting file).
- `{{solution NN K}}` — inserts `solutions/NN/K.sql` inside a collapsed `<details>`.
- `<!--LESSON_LIST-->` — home page only.

Editing an exercise file automatically updates the page on the next build. Do not paste
exercise code into fragments by hand.

## Lesson template (strict)

Every lesson fragment follows the same order so readers build muscle memory:

1. Lede paragraph `<p class="lede">` — what the reader will be able to do; no `<h1>`
   (the builder adds the eyebrow and title from the outline).
2. `<h2 id="goals">Learning goals</h2>` — 5 to 7 bullets.
3. `<h2 id="lab">Set up for this lesson</h2>` — which database to use, which `./pg`
   command to run, what to expect (usually "the shop database is already seeded").
4. Numbered explanation sections, one idea per `<h2>`, each with a small runnable
   `sql` example (`<figure class="code" data-lang="sql">`) and, where it helps, a
   `<div class="lab pg">` playground. Use `<h3>` for sub-points.
5. Pitfalls as callouts: `<div class="note warn|danger|tip|info">` with
   `<span class="note-title">…</span>`. Do not invent other labels.
6. `<h2 id="when">When to use, when not to</h2>` — a comparison table with ✅/❌ columns.
7. `<h2 id="inspect">Inspect it</h2>` — a short query or command to run before the exercises.
8. `<h2 id="exercises">Your turn</h2>` — exactly three exercises: basic, intermediate,
   challenge. Each is a `<section class="exercise">` card (see below).
9. `<h2 id="summary">Summary</h2>` — short bullets.
10. `<h2 id="next">Looking ahead</h2>` — two sentences and a link to the next lesson.

### Exercise card

```html
<section class="exercise">
  <div class="ex-head"><span>Exercise 2</span><span class="grow"></span><span class="lvl">intermediate</span></div>
  <div class="ex-body">
    <p>Task in one or two sentences. Name the output columns exactly as shown.</p>
    <p>Open <code>exercises/03/2.sql</code>, write your answer, then run <code>./pg check 03 2</code>.</p>
  </div>
  {{stub 03 2}}
  <details><summary>Hint</summary><p>…</p></details>
  {{solution 03 2}}
</section>
```

`{{solution}}` already creates its own collapsed `<details>`. Put it directly in the
card, after the hint, and never wrap it in another `<details>`.

## Content rules

- **Audience:** developers who know SQL basics (SELECT, JOIN, GROUP BY, INSERT, UPDATE)
  but have not administered PostgreSQL. Define each new term once, in plain English.
- **Voice:** English, second person, direct. Short sentences. Contractions are fine.
- **Accuracy over breadth:** every SQL statement must run on PostgreSQL 18. Verify
  statements with `./pg sql` or `./pg run` before they go in a lesson.
- **Names and examples:** use the shop dataset. Its tables are `shop.customers`,
  `shop.categories`, `shop.products`, `shop.orders`, `shop.order_items` and
  `analytics.events`. The browser playground has the same names with far fewer rows.
- **Roles created by exercises** must start with `lab_` so the checker can remove them.
- **Plans and timings:** plans and timings in lessons come from the Docker database
  (1 million events). The browser playground is too small to show realistic plans, so
  say so when using `EXPLAIN` in a playground.
- **No secrets:** the lab password `course` is for the local container only. Never
  present it as a production practice.
- **Do not** use features that PostgreSQL 18 does not have, and do not state version
  numbers you have not checked.

## Playground markup

```html
<div class="lab pg">
  <div class="lab-head">playground <span class="note-lite">real PostgreSQL 18 in your browser · seeded with a small shop</span></div>
  <div class="lab-body">
    <div class="pg-editor"><textarea class="sql" spellcheck="false">select count(*) from shop.orders;</textarea></div>
    <div class="pg-out"></div>
  </div>
</div>
```

The script adds the Run and Reset buttons and the status light. Keep the starter query
runnable. Playground labs share one database per page.

## Exercise rules (checked by ./pg)

- `exercises/NN/K.sql` is what the reader edits. It begins with a comment that states
  the task, and it must **fail** the checker as shipped (the verifier checks this).
- `solutions/NN/K.sql` is the model answer. It must **pass**. It must be deterministic:
  no `now()`, no `random()`, no unordered `LIMIT` without `ORDER BY`.
- Query exercises compare the reader's result with the solution's result, as CSV, with
  row order ignored. Put `-- ordered` as the first line of a solution whose row order
  matters. Name output columns exactly as the task asks.
- State exercises (roles, grants, DDL, transactions) have `checks/NN/K.sql`. The reader's
  file runs first in a fresh copy of the database, then the check file runs. The check
  returns rows `(ok boolean, what text)`; every `ok` must be true.
- Exercises must work on a fresh clone of the practice database. Anything a state
  exercise creates in the cluster (roles, databases) must be named `lab_*`.

## Things not to do

- Do not change `docker/initdb` after the volume exists without telling the reader to run
  `./pg reset`.
- Do not add third-party services, analytics or cookies.
- Do not commit generated files that are out of date: run the build first.
- Do not write planning or summary documents into the repo unless asked.
