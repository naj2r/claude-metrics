# Raw data (immutable)

Place all raw input datasets here. This folder is **read-only** for the analysis pipeline — hard rule 01 blocks any script from writing to it. Only `processed/` and `results/` are writable.

## Conventions

- One folder per data source if you have multiple sources, or files at the root if you only have one or two.
- Keep raw data **as you received it** — no manual cleaning, no renaming columns. Cleaning happens in `1_process_raw_data.do`.
- Document each file's source: where it came from, when, sample period, refresh cadence. Edit this README.

## Gitignore

Raw data is gitignored by default (`analysis/data/*` with exceptions for `auto.csv` and this `README.md`). For private/large data, store on Dropbox or another shared location and configure `$DROPBOX` in your local Stata `profile.do`.

## After populating this folder

1. Edit `CONTEXT.md` (project root) — fill in the Dataset(s) section.
2. Update `1_process_raw_data.do` — replace the placeholder import with your actual import code.
3. Run `/run-stata` to verify the pipeline picks up the new data.
