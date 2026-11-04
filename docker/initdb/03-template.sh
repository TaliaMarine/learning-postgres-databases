#!/usr/bin/env bash
# Snapshot the freshly seeded database as a template. ./pg check clones it for every
# check, so your practice database (shop) is never changed by the exercise checker.
set -euo pipefail
psql -v ON_ERROR_STOP=1 -U postgres -d postgres -c "create database shop_template template shop is_template true"
psql -v ON_ERROR_STOP=1 -U postgres -d shop -c "create table course.ready as select 1 as one"
