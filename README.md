# /data
This is where the magic happens. The `Makefile` in this directory contains tasks for fetching, munging, and storing data from San Francisco's data repository. Here are the tasks you'll find useful:

## `make db`
Create the sqlite database `archive.db` and the relevant tables: `updates` and `reports`.

## `make sync`
Sync the `updates` tables to the `reports` table, ignoring duplicate rows. This should be run after any of the `update-*` targets.

## `make update-archive`
Download the full archive (back to 2003) of crime report data and add it to the `updates` table. This will probably take a long time because San Francisco's servers are slow.

## `make update-90d`
Download the rolling 90-day report data and add it to the `updates` table.

## `make update-weekly`
Download the last week's worth of report data and add it to the `updates` table.

## `make update-daily`
Download the *delta* between yesterday's data and today's, and add it to the `updates` table. Note that the daily delta often contains reports from weeks and sometimes months ago. Because of the SFPD's lag in releasing reports, this will likely *never* contain reports from yesterday.

## `make update FILE=path/to/data.csv`
Manually insert rows from the named CSV file into the `updates` table.

## `make flush`
Flush all of the sqlite databases's relevant tables by re-creating them.

## `make clean`
Delete rows from the `updates` table only. You should do this after successfully performing an update and sync, so that future sync operations include only the most recent updates.
