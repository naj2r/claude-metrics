"""
build_pop_canton_yearbook.py
Purpose:  Ingest PI's verified Excel transcription of the 1908 Statistical
          Yearbook canton-population table (mid-year resident-population
          estimates, 1867-1908) and emit per-year clean 25-canton CSVs for the
          workshop cohort. Currently emits 1907 (scale/density/per-cap controls,
          pre-1908-vote annual) and 1906 (petition denominator; the petition is
          a 1906 event, matching eligible_1906).
Input:    $Absinthe1Data/original/Statistical Yearbooks of Switzerland/
              SwissStats1908_population_1908-1867.xlsx   (sheet 'English')
Output:   analysis/processed/pop_1907_canton.csv   (canton_iso, pop_1907)
          analysis/processed/pop_1906_canton.csv   (canton_iso, pop_1906)
Author:   Nicholas A Jensen
Date:     2026-06-17

Cross-validation:
  For each year, the sum of the 25 canton estimates must equal the source
  'Switzerland' total for that year (asserted exactly):
     1907 -> 3,524,529   |   1906 -> 3,491,163

Source notes:
  - 1907 = closest pre-vote annual estimate (ban vote 5 July 1908); also matches
    the 1907 workshop wine vintage. 1906 = petition-year denominator.
  - The source flags PROVISIONAL only the 1908 values for Neuchatel/Geneva/
    Switzerland (italic). All 1906 & 1907 figures are final estimates.
  - 25 cantons = the 1908 cantonal universe (Jura still in Bern; 6 half-cantons
    listed separately). Matches the project's canton_iso set.

Supersedes build_pop_1907_canton.py (single-year). Mirrors the immutable-raw-tier
hardcode rationale of build_canton_wine_1907_pi.py (one-shot data-prep).
"""
from __future__ import annotations
import os
import sys
from pathlib import Path

import pandas as pd

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# ----------------------------------------------------------------------------
# 0. Config
# ----------------------------------------------------------------------------
ABSINTHE1DATA = os.environ.get(
    "Absinthe1Data",
    r"C:/Users/jensenn/Dropbox/research_data_raw/c-metrics-absinthe1",
)
SRC = (Path(ABSINTHE1DATA) / "original" / "Statistical Yearbooks of Switzerland"
       / "SwissStats1908_population_1908-1867.xlsx")

HERE = Path(__file__).resolve().parent            # analysis/scripts/python
PROJECT_ROOT = HERE.parent.parent.parent          # c-metrics-absinthe1
OUTDIR = PROJECT_ROOT / "analysis" / "processed"

# year -> source 'Switzerland' national total (cross-check constant)
YEARS = {1907: 3_524_529, 1906: 3_491_163}

NAME_TO_ISO = {
    "Zurich": "ZH", "Bern": "BE", "Lucerne": "LU", "Uri": "UR", "Schwyz": "SZ",
    "Obwalden": "OW", "Nidwalden": "NW", "Glarus": "GL", "Zug": "ZG",
    "Fribourg": "FR", "Solothurn": "SO", "Basel-City": "BS",
    "Basel-Country": "BL", "Schaffhausen": "SH", "Appenzell Outer Rhodes": "AR",
    "Appenzell Inner Rhodes": "AI", "St. Gallen": "SG", "Grisons": "GR",
    "Aargau": "AG", "Thurgau": "TG", "Ticino": "TI", "Vaud": "VD",
    "Valais": "VS", "Neuchâtel": "NE", "Geneva": "GE",
}


def to_iso(name: str) -> str:
    key = str(name).split("(")[0].strip()
    if key not in NAME_TO_ISO:
        sys.exit(f"ERROR: unmapped canton name: {name!r} (key {key!r})")
    return NAME_TO_ISO[key]


def build_year(df: pd.DataFrame, year: int, national_total: int) -> None:
    canton_col = df.columns[0]
    col = [c for c in df.columns if str(c).strip() == str(year)]
    if len(col) != 1:
        sys.exit(f"ERROR: expected exactly one {year} column, found {col}")
    col = col[0]

    sub = df[[canton_col, col]].rename(columns={canton_col: "canton_name", col: f"pop_{year}"})
    sub = sub.dropna(subset=["canton_name", f"pop_{year}"])

    is_ch = sub["canton_name"].str.strip().str.startswith("Switzerland")
    ch = sub[is_ch]
    if len(ch) != 1:
        sys.exit(f"ERROR[{year}]: expected exactly 1 Switzerland row, got {len(ch)}")
    ch_total = int(round(float(ch[f"pop_{year}"].iloc[0])))
    sub = sub[~is_ch].copy()

    sub["canton_iso"] = sub["canton_name"].map(to_iso)
    assert len(sub) == 25, f"[{year}] expected 25 cantons, got {len(sub)}"
    assert sub["canton_iso"].is_unique, f"[{year}] duplicate canton_iso"
    assert (sub[f"pop_{year}"] > 0).all(), f"[{year}] non-positive value(s)"
    frac = (sub[f"pop_{year}"] - sub[f"pop_{year}"].round()).abs()
    assert (frac < 1e-9).all(), f"[{year}] non-integer value(s)"
    sub[f"pop_{year}"] = sub[f"pop_{year}"].round().astype("int64")

    canton_sum = int(sub[f"pop_{year}"].sum())
    assert canton_sum == ch_total == national_total, (
        f"[{year}] national-total mismatch: cantons={canton_sum:,}, "
        f"source CH={ch_total:,}, expected={national_total:,}")

    out = sub[["canton_iso", f"pop_{year}"]].sort_values("canton_iso").reset_index(drop=True)
    dest = OUTDIR / f"pop_{year}_canton.csv"
    out.to_csv(dest, index=False)
    print(f"  {year}: 25 cantons, sum={canton_sum:,} == CH total OK -> {dest.relative_to(PROJECT_ROOT)}")


def main() -> None:
    if not SRC.exists():
        sys.exit(f"ERROR: source not found: {SRC}\nSet $Absinthe1Data if your Dropbox lives elsewhere.")
    df = pd.read_excel(SRC, sheet_name="English", header=3)
    print(f"Loaded sheet 'English': {df.shape[0]} rows x {df.shape[1]} cols")
    OUTDIR.mkdir(parents=True, exist_ok=True)
    for year, total in YEARS.items():
        build_year(df, year, total)
    print("Done.")


if __name__ == "__main__":
    main()
