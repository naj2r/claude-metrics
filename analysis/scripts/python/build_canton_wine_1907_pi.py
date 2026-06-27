"""
build_canton_wine_1907_pi.py
Purpose:  Ingest PI's verified Excel transcription of the 1908 Statistical
          Yearbook canton-wine table (1907 data, 20 wine-producing cantons),
          pad with 5 zero rows for alpine non-wine cantons (UR, OW, NW, ZG, AI),
          compute wine_revenue_share_canton (W6), and write a 25-row cleaned
          CSV for downstream Stata import.
Input:    $Absinthe1Data/original/Statistical Yearbooks of Switzerland/Canton1907_wine-data.xlsx
Output:   analysis/processed/canton_wine_1907_pi.csv  (25 rows × 6 cols)
Author:   Nicholas A Jensen
Date:     2026-05-18

Cross-validation:
  CH national total cultivated area (PI Excel): 27,214.8 ha
  HSSO I.06 1905 (Ritzmann 1990 national estimate):   27,200.0 ha
  Agreement: 0.05% (14.8 ha on 27,200 ha total) -> PI transcription validated.

Adapted from PI's non-authoritative example. Differences:
  - Output path follows c-metrics-absinthe1 project convention (analysis/processed/)
  - Adds CH-total cross-validation assertion against I.06
  - Adds 25-row count and non-negative assertions before save
  - Adds source-file existence check with friendly error
"""
from __future__ import annotations
import os
import sys
from pathlib import Path

import pandas as pd

# UTF-8 safe stdout for Windows
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# ----------------------------------------------------------------------------
# 0. Paths
# ----------------------------------------------------------------------------
# Source lives in the immutable raw-data tier ($Absinthe1Data). Hard-coding the
# absolute path here is acceptable because (a) this is a one-shot data-prep
# step, not part of the Stata pipeline, and (b) the Dropbox-mirrored raw-data
# tier IS the project's canonical location for source files. The Stata pipeline
# itself uses $Absinthe1Data via the user's profile, so no path-leak risk.
ABSINTHE1DATA = os.environ.get(
    "Absinthe1Data",
    r"C:/Users/jensenn/Dropbox/research_data_raw/c-metrics-absinthe1",
)
SRC = Path(ABSINTHE1DATA) / "original" / "Statistical Yearbooks of Switzerland" / "Canton1907_wine-data.xlsx"

# Output goes under c-metrics-absinthe1/analysis/processed/.  Walk up from this
# script's __file__ location to find the project root rather than hard-coding.
HERE = Path(__file__).resolve().parent          # analysis/scripts/python
PROJECT_ROOT = HERE.parent.parent.parent          # c-metrics-absinthe1
OUT = PROJECT_ROOT / "analysis" / "processed" / "canton_wine_1907_pi.csv"

# ----------------------------------------------------------------------------
# 1. Read source
# ----------------------------------------------------------------------------
if not SRC.exists():
    sys.exit(f"ERROR: source not found: {SRC}\nSet $Absinthe1Data env var if your Dropbox lives elsewhere.")

df = pd.read_excel(SRC, sheet_name="Sheet3")
print(f"Loaded {len(df)} rows from {SRC.name}")
print(f"  Columns: {list(df.columns)[:6]} ... (+{len(df.columns)-6} more)")

# ----------------------------------------------------------------------------
# 2. Keep + rename the 5 primary columns
# ----------------------------------------------------------------------------
# The PI Excel has 16 columns; we keep only the 5 primary measures.  The 11
# bonus columns (red/white/mixed breakouts) are deferred; the Stata script
# uses only the primary measures for M1A.  Add them back later if a referee
# asks for varietal heterogeneity.
COL_MAP = {
    "Code":                  "canton_iso",
    "Cultivated area (ha)":  "wine_area_canton_ha",      # W1
    "Total yield (hl)":      "wine_volume_canton_hl",    # W2
    "Total value (Fr)":      "wine_revenue_canton_fr",   # W3
    "Yield per ha (hl)":     "wine_yield_canton_hl_per_ha",  # W4
}
df = df[list(COL_MAP.keys())].rename(columns=COL_MAP)

# ----------------------------------------------------------------------------
# 3. Extract CH national row + cross-validate against Ritzmann I.06
# ----------------------------------------------------------------------------
ch = df[df["canton_iso"] == "CH"]
if len(ch) != 1:
    sys.exit(f"ERROR: expected exactly 1 CH row, got {len(ch)}")
ch_area = float(ch["wine_area_canton_ha"].iloc[0])
ch_rev  = float(ch["wine_revenue_canton_fr"].iloc[0])
ch_vol  = float(ch["wine_volume_canton_hl"].iloc[0])
print(f"CH 1907 totals: area={ch_area:,.1f} ha, vol={ch_vol:,.1f} hl, revenue={ch_rev:,.0f} Fr")

# Cross-validation: PI's 1907 area should be within 1% of Ritzmann's 1905
# (HSSO I.06) national figure of 27,200 ha.  Different sources, slightly
# different years (1905 vs 1907), but both Switzerland-wide.
RITZMANN_1905 = 27_200.0
pct_diff = abs(ch_area - RITZMANN_1905) / RITZMANN_1905 * 100
print(f"Cross-check: PI 1907 area vs Ritzmann I.06 1905 = {pct_diff:.2f}% diff")
assert pct_diff < 1.0, f"PI vs Ritzmann disagree by {pct_diff:.2f}% — investigate before using"

# ----------------------------------------------------------------------------
# 4. Drop CH row + pad with 5 zero rows for alpine non-wine cantons
# ----------------------------------------------------------------------------
# CH row is the normalizer, not an observation.  After dropping it we have 20
# rows; the 1908 cantonal universe is 25 (BE+JU still combined as BE per the
# project's BE/JU rule).  The 5 missing are alpine/non-wine cantons with zero
# commercial vineyards:
#   UR = Uri        (alpine pasture)
#   OW = Obwalden   (alpine pasture)
#   NW = Nidwalden  (alpine pasture)
#   ZG = Zug        (no significant viticulture pre-WW1)
#   AI = Appenzell I.-Rh. (alpine pasture)
df_cantons = df[df["canton_iso"] != "CH"].copy()
assert len(df_cantons) == 20, f"expected 20 wine cantons, got {len(df_cantons)}"

ZERO_CANTONS = ["UR", "OW", "NW", "ZG", "AI"]
zeros = pd.DataFrame({
    "canton_iso":                  ZERO_CANTONS,
    "wine_area_canton_ha":         [0.0] * 5,
    "wine_volume_canton_hl":       [0.0] * 5,
    "wine_revenue_canton_fr":      [0.0] * 5,
    "wine_yield_canton_hl_per_ha": [0.0] * 5,
})
df_cantons = pd.concat([df_cantons, zeros], ignore_index=True)
assert len(df_cantons) == 25, f"expected 25 cantons after padding, got {len(df_cantons)}"

# ----------------------------------------------------------------------------
# 5. Compute W6 = wine_revenue_share_canton (share of CH total revenue)
# ----------------------------------------------------------------------------
# W6 is useful as an alternative wine-economic-importance measure to W1 area.
# Since the canton sum equals CH total (zero rows contribute 0), the W6 sum
# across cantons must equal 1.0 to numerical precision.
df_cantons["wine_revenue_share_canton"] = (
    df_cantons["wine_revenue_canton_fr"] / ch_rev
)
share_sum = df_cantons["wine_revenue_share_canton"].sum()
print(f"W6 (wine_revenue_share_canton) sum across 25 cantons: {share_sum:.6f} (expect 1.000000)")
assert abs(share_sum - 1.0) < 1e-6, f"W6 sums to {share_sum}, not 1.000000"

# ----------------------------------------------------------------------------
# 6. Sort + integrity checks + save
# ----------------------------------------------------------------------------
df_cantons = df_cantons.sort_values("canton_iso").reset_index(drop=True)

# Integrity checks: all wine measures non-negative; canton_iso unique
for col in ("wine_area_canton_ha", "wine_volume_canton_hl",
            "wine_revenue_canton_fr", "wine_yield_canton_hl_per_ha"):
    assert (df_cantons[col] >= 0).all(), f"negative values in {col}"
assert df_cantons["canton_iso"].is_unique, "duplicate canton_iso codes"

OUT.parent.mkdir(parents=True, exist_ok=True)
df_cantons.to_csv(OUT, index=False)
print(f"\n=== SAVED: {OUT.relative_to(PROJECT_ROOT)} ===")
print(f"Shape: {df_cantons.shape}")
print(f"\nNon-zero canton count by field:")
for col in ("wine_area_canton_ha", "wine_volume_canton_hl", "wine_revenue_canton_fr"):
    nz = int((df_cantons[col] > 0).sum())
    print(f"  {col}: {nz}/25")
print(f"\nFirst 5 rows:\n{df_cantons.head().to_string(index=False)}")
print(f"\nLast 5 rows:\n{df_cantons.tail().to_string(index=False)}")
