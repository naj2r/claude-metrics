# Cahannes (Muster 1981) — Time Series Table & Figure in Stata

**Source:** E. Muster, *Zahlen und Fakten zu Alkohol- und Drogenproblemen* (Lausanne: SFA, 1981), transcribed in `data/raw/1981CahannesTableTranscribed.csv`.

The data are **period averages** — each observation covers a multi-year bin (e.g. 1903/1912). For plotting, values are assigned to the **midpoint year** of each bin (e.g. 1907.5). See note at bottom on this convention.

---

## 1. Enter the data

```stata
clear
input str9 period float(year_mid wine beer cider spirits total_pc)
"1880/1884"  1882.0   70.0  36.3  22.4  11.81  21.0
"1893/1902"  1897.5   88.8  61.6  28.1   7.17  22.9
"1903/1912"  1907.5   71.3  71.7  30.3   6.40  21.5
"1913/1922"  1917.5   53.6  42.8  37.8   6.19  16.0
"1923/1932"  1927.5   50.0  55.0  37.7   6.73  18.4
"1933/1938"  1935.5   44.0  54.6  36.1   2.88  13.6
"1939/1944"  1941.5   37.9  39.3  32.7   2.31  10.1
"1945/1949"  1947.0   36.7  34.1  35.3   3.02  10.4
"1950/1955"  1952.5   33.9  48.5  26.9   3.02  10.9
"1956/1960"  1958.0   34.9  60.1  17.3   3.51  11.8
"1961/1965"  1963.0   37.0  73.5  11.0   4.46  13.2
"1966/1970"  1968.0   40.2  77.1   7.6   4.71  13.8
"1971/1975"  1973.0   44.5  74.8   6.5   5.30  14.4
"1976"       1976.0   43.5  71.1   6.0   4.50  13.1
"1977"       1977.0   44.9  68.3   5.7   4.70  13.2
"1978"       1978.0   45.0  68.0   5.4   5.00  13.3
"1979"       1979.0   46.2  68.2   5.3   5.00  13.3
end

label var wine     "Wine (L/capita)"
label var beer     "Beer (L/capita)"
label var cider    "Cider (L/capita)"
label var spirits  "Distilled spirits (L/capita)"
label var total_pc "Total at 100% alcohol per person aged 15+"
```

---

## 2. Print the table

```stata
* Clean console table
list period wine beer cider spirits total_pc, ///
    sep(0) noobs divider clean abbreviate(20)
```

### Export to Excel (for paper appendix)

```stata
* Rename for nicer column headers before export
preserve
rename wine     Wine
rename beer     Beer
rename cider    Cider
rename spirits  "Distilled Spirits"
rename total_pc "Total per capita (15+, 100% alc)"

export excel period Wine Beer Cider "Distilled Spirits" ///
    "Total per capita (15+, 100% alc)" ///
    using "data/raw/Cahannes_table.xlsx", ///
    firstrow(variables) replace
restore
```

---

## 3. Time series plot

```stata
* Twoway line plot — four beverage types + total per capita (dashed)
* The 1908 absinthe ban reference line is included

twoway ///
    (line wine     year_mid, lcolor("139 26 26")  lwidth(medthick) lpattern(solid) msymbol(O) msize(small)) ///
    (line beer     year_mid, lcolor("200 134 10")  lwidth(medthick) lpattern(solid) msymbol(S) msize(small)) ///
    (line cider    year_mid, lcolor("58 107 71")   lwidth(medthick) lpattern(solid) msymbol(T) msize(small)) ///
    (line spirits  year_mid, lcolor("43 76 126")   lwidth(medthick) lpattern(solid) msymbol(D) msize(small)) ///
    (line total_pc year_mid, lcolor("80 80 80")    lwidth(medthick) lpattern(dash)  msymbol(X) msize(small)) ///
    , ///
    xline(1908, lpattern(dot) lcolor(black) lwidth(thin)) ///
    text(86 1909 "1908 Absinthe ban", place(e) size(small) color(black) italics) ///
    ytitle("Liters per capita", size(medsmall)) ///
    xtitle("Year (midpoint of averaging period)", size(medsmall)) ///
    title("Swiss Per Capita Alcohol Consumption by Type, 1880–1979", size(medsmall)) ///
    subtitle("Source: Muster (1981) / Cahannes; period averages at midpoint year", size(vsmall)) ///
    legend(order(1 "Wine" 2 "Beer" 3 "Cider" 4 "Distilled spirits" ///
                 5 "Total (per capita, 15+)") ///
           position(1) ring(0) cols(1) size(small)) ///
    xlabel(1880(10)1980, angle(45) labsize(small)) ///
    ylabel(0(10)100, labsize(small)) ///
    graphregion(color(white)) ///
    plotregion(margin(small)) ///
    scheme(s2color)

graph export "figures/cahannes_alcohol_timeseries.png", replace width(2000)
```

> **Note on shading war years** (optional): add the following `twoway` elements before the comma if you want WWI/WWII shading:
> ```stata
>     (rarea zero_line zero_line year_mid if inrange(year_mid,1914,1918), ///
>         color(gs14) base(0)) ///
> ```
> This requires creating a zero variable (`gen zero_line = 0`) and is easier to do in Python/matplotlib if shading is desired. Omitting it keeps the Stata figure clean.

---

## 4. Note on binned time variables

The Cahannes data are **period averages**, not annual observations. Three things to keep in mind:

**For figures** — use the **midpoint year** as the x-axis value (done above). This is the standard convention; state it in the figure caption. Do not use the start year: it shifts the visual representation of the absinthe ban effect leftward by up to 5 years for the earliest bins.

**For the unequal gap (1884→1893)** — there is a 9-year gap between the first and second bins with no data. The midpoint approach handles this correctly: the plotted points land at 1882 and 1897.5, visually showing the gap. Do not interpolate across this gap.

**For regression use** — if Nick wants to use these bins as observations in a regression (e.g., a pre/post comparison), use the midpoint as the time variable and weight by bin width (`1/bin_years`) or cluster on period. Treating each bin as a single annual observation would overstate precision for the wider bins.
