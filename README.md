# Bunching replication

Replication workspace for **“Regulatory Costs of Being Public: Evidence from Bunching Estimation”** by **Michael Ewens, Kairong Xiao, and Ting Xu**. The supplied authors’ package identifies the paper as JFE forthcoming (2023).

Replication package: [Mendeley Data (version 4)](https://data.mendeley.com/datasets/rf4skk7235/4).

## Replication scope and limitations

The repository contains code covering the main numbered Figures 1–7 and Tables 1–8, prepared input data, and supplied reference outputs. It is a useful starting point for replicating the paper, but **an exact, end-to-end replication of every empirical result cannot be confirmed from this package alone**.

According to `replication_package_readme.docx`:

- The main estimation spreadsheets and the heterogeneity split spreadsheets are unscrambled. These support an attempt to reproduce the core bunching and regulatory-cost estimates.
- Many Stata datasets contain scrambled values. In those files, public float, year, CIK, and variables derived from public float are preserved; other variables are scrambled. Results using those other variables should not be expected to match the paper.
- The underlying sources include Compustat/CRSP, SEC EDGAR, VentureSource, I/B/E/S, Thomson Reuters 13F, and the Jay Ritter IPO database. Reconstructing the original data may require licensed access and additional data preparation work.

This is primarily an analysis package operating on prepared inputs, rather than a verified pipeline from raw source data to every published result. Some downstream calculations use supplied bootstrap inputs and hard-coded estimates. Code coverage does not establish numerical reproducibility.

**Current validation status:** files and code have been inspected, but no replication scripts have been run or results compared with the paper on this machine. Existing outputs and `code/master_log_scrambled.smcl` belong to the supplied package.

## Repository layout

| Path | Contents |
| --- | --- |
| `code/` | Stata, MATLAB, R, and LaTeX analysis scripts |
| `code/functions/` | Bunching estimator, MATLAB helpers, and Stata heatmap files |
| `input/` | Prepared estimation samples, scrambled datasets, and bootstrap inputs |
| `output/` | Supplied reference results; scripts also write generated results here |
| `replication_package_readme.docx` | Authors’ data-availability and software notes |

## Code map

| Results | Entry point | Notes |
| --- | --- | --- |
| Figures 1–2 | `code/Figures1&2.do` | Public-float distribution figures |
| Figure 3 | `code/Figure3.tex` | Theoretical diagrams |
| Figure 4 | `code/Figure4.m` | Theoretical simulations |
| Figures 5–7 | Corresponding `code/Figure*.do` files | Figure 5 also calls R through the heatmap integration |
| Table 1 | `code/Table1a.tex`, `code/Table1b.tex` | Regulation summaries |
| Table 2 | `code/Table2.do` | Instrumental-variable regressions |
| Table 3 | `code/Table3.m` | Core bunching estimates and bootstrap standard errors at $25m, $75m, and $700m |
| Table 4 | `code/Table4.do` | Stata calculations |
| Table 5 | `code/Table5a.m`, `code/Table5b.m`, then `code/Table5.do` | Heterogeneity estimates and downstream calculations |
| Tables 6–8 | Corresponding `code/Table*.do` files | IPO and going-private analyses |

`code/functions/FB.m` is the core bunching estimator. It compares pre/post public-float distributions to estimate the marginal bunching range and friction parameter. The MATLAB table scripts translate these estimates into regulatory costs.

## Software requirements

The authors specify Stata 15 or newer, MATLAB R2016b or newer, and R. LaTeX is also needed to compile the supplied `.tex` material.

- **Stata:** `master.do` installs `ivreg2`, `ivreghdfe`, `ranktest`, `mdesc`, and `winsor2`. Other scripts use `eststo`, `esttab`, and `estadd` from `estout`, which the installation block currently omits. Check dependencies of the installed `ivreghdfe` version, including `reghdfe` and `ftools`.
- **MATLAB:** the code calls functions associated with Statistics and Machine Learning Toolbox (`datasample`, `normcdf`, `normpdf`), Optimization Toolbox (`fsolve`, `optimoptions`), and Symbolic Math Toolbox (`syms`, `solve`). Confirm the required toolboxes are available.
- **R / Figure 5:** the authors specify `heatmapEco`; the supplied `heatmap.ado` and `heatmap.sthlp` must be available on Stata’s ado path.

These are requirements inferred from the package and source code, not a tested software environment.

## Setup and execution

1. Preserve the supplied outputs as reference results before running scripts, which can overwrite them.
2. Replace the author-specific Dropbox paths in `code/master.do` with local repository paths. Set the input and output globals and the working directory for `code/`.
3. Update Windows-style paths in the MATLAB scripts for the local platform, preferably using `fullfile`. Run MATLAB scripts from `code/` so the relative function paths resolve.
4. Configure the R installation path in `code/Figure5.do`; it currently selects a Windows R path and includes a commented macOS example.
5. Install and verify the required software packages and toolboxes.
6. Run `Table3.m` to regenerate the main estimates. Run `Table5a.m` and `Table5b.m` before `Table5.do` (or before reaching Table 5 in the Stata master script).
7. Run the Stata workflow through `master.do`, and run/compile the separate MATLAB and LaTeX figure/table files as needed.
8. Compare regenerated results with both the supplied outputs and the paper, recording differences caused by scrambled data, software versions, or code assumptions.

`master.do` orchestrates the Stata scripts only; it does not execute the MATLAB or LaTeX steps. Table 5 currently inserts baseline Table 3 values as constants, so regenerating Table 3 does not automatically update those entries.

The files named `input/bootstrap_1.csv` through `bootstrap_3.csv` are actually legacy Excel binary files, consistent with the code’s use of `import excel`. Do not assume they are plain-text CSV files.

## Data use and attribution

The authors’ package describes the data as intended for academic use and requests citation of Ewens, Xiao, and Xu (2023) when reusing the data or code. Consult the original package notes and applicable source-data terms before reuse or redistribution.
