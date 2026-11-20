# Bunching replication

Replication workspace for **“Regulatory Costs of Being Public: Evidence from Bunching Estimation”** by **Michael Ewens, Kairong Xiao, and Ting Xu**. Published in *Journal of Financial Economics* **153** (2024), article **103775**. The supplied replication-package notes predate publication and refer to the 2023 forthcoming version.

Replication package: [Mendeley Data (version 4)](https://data.mendeley.com/datasets/rf4skk7235/4).

Additional source data: [public_float_regulation](https://github.com/michaelewens/public_float_regulation), downloaded into `data/`.

## Replication scope and limitations

The repository contains code covering the main numbered Figures 1–7 and Tables 1–8, prepared input data, and supplied reference outputs. It is a useful starting point for replicating the paper, but **an exact, end-to-end replication of every empirical result cannot be confirmed from this package alone**.

According to `replication_package_readme.docx`:

- The main estimation spreadsheets and the heterogeneity split spreadsheets are unscrambled. These support an attempt to reproduce the core bunching and regulatory-cost estimates.
- Many Stata datasets contain scrambled values. In those files, public float, year, CIK, and variables derived from public float are preserved; other variables are scrambled. Results using those other variables should not be expected to match the paper.
- The underlying sources include Compustat/CRSP, SEC EDGAR, VentureSource, I/B/E/S, Thomson Reuters 13F, and the Jay Ritter IPO database. Reconstructing the original data may require licensed access and additional data preparation work.

This is primarily an analysis package operating on prepared inputs, rather than a verified pipeline from raw source data to every published result. Some downstream calculations use supplied bootstrap inputs and hard-coded estimates. Code coverage does not establish numerical reproducibility.

**Current validation status:** files and code have been inspected, but no replication scripts have been run or results compared with the paper on this machine. Existing outputs and `code/master_log_scrambled.smcl` belong to the supplied package.

## Repository layout

Every current root-level file and folder is documented below, including hidden entries. Paths are relative to the repository root.

| Root entry | Purpose and handling |
| --- | --- |
| `README.md` | This project guide: sources, directory inventory, replication limits, software requirements, and execution steps. |
| `Regulatory Costs of Being Public:  Evidence from BunchingEstimation.pdf` | Local paper PDF, previously named `fullDraft100823.pdf`; use for checking methods and results. The filename contains two spaces after the colon. The file’s version has not been checked against the published article. |
| `replication_package_readme.docx` | Original authors’ replication-package notes, including data sources, scrambling, software, and execution requirements. Preserve as source documentation. |
| `code/` | Supplied Stata `.do`, MATLAB `.m`, R, and LaTeX analysis code, plus the supplied `master_log_scrambled.smcl`. `master.do` runs the Stata portion; `functions/` contains the estimator, MATLAB helpers, and Stata heatmap integration. Paths still need local configuration. |
| `input/` | Authors’ prepared analysis inputs: threshold samples, main estimation spreadsheets, heterogeneity splits, bootstrap inputs, and IPO/going-private datasets. Some variables are scrambled. Preserve these inputs for the package-replication baseline. |
| `data/` | Additional downloaded source data from `public_float_regulation`, with its README and license. Contains archives and extracted CSVs; currently separate from the analysis workflow. Treat downloaded files as immutable source inputs. |
| `output/` | Supplied reference figures, tables, bootstrap results, and intermediate files. Existing scripts also write here and may overwrite them. Preserve reference copies or redirect new runs before execution. |
| `.git/` | Local Git metadata: history, branches, index, and configuration. Managed by Git; not analysis data. |
| `.DS_Store` | macOS Finder metadata, currently tracked in Git. Not required for replication; recommended for removal from tracking and exclusion in a future `.gitignore`. |

There is currently no root `.gitignore`. A separate location for new run outputs and `data/derived/` for cleaned/merged data are recommended but have not yet been created. Keeping ZIPs and extracted CSVs is convenient locally; choose a consistent Git storage policy to avoid versioning redundant copies.

## Additional source-data inventory

The following files are currently present in `data/`:

| File | Contents |
| --- | --- |
| `README.md` | Upstream source descriptions, variable definitions, and the published paper citation. |
| `LICENSE` | Upstream MIT license; retain with the downloaded material. This does not replace terms applicable to other data sources. |
| `public_float.csv.zip` | Downloaded archive of the public-float panel. |
| `public_float.csv` | Extracted public-float panel: CIK, filing links, commission file number, reporting date, float year, and public float in millions. |
| `length10K_less25m_float.csv` | Disclosure-length data for small firms, including filing type, fiscal year, small-business-issuer status, section lengths, and missing-section indicators. |
| `sec_10Klinks_all.csv.zip` | Downloaded archive of SEC filing metadata and links. |
| `sec_10Klinks_all.csv` | Extracted filing metadata: CIK, filing/reporting dates, form, company name, and filing URL. |
| `.DS_Store` | Local macOS Finder metadata; not part of the upstream research data. |

### Local validation (20 November 2026)

- Both ZIP archives pass CRC integrity checks. Each extracted CSV is byte-for-byte identical to its archived counterpart. This checks local extraction integrity, not identity with a separately fetched upstream commit.
- `public_float.csv` has **224,386 rows**, covering **1994–2018**. The pair `cik` + `publicfloat_year` is unique, with no blank keys.
- Its public-float values include **164,773 positive values**, **57,884 zeros**, and **1,729 blanks**. This differs from the upstream README’s description of a positive-float-only dataset. Explicitly document the treatment of zeros and blanks when constructing samples; do not silently treat them as positive observations.
- `length10K_less25m_float.csv` has **11,565 rows**; `sec_10Klinks_all.csv` has **301,118 rows**. Both parse as CSV and contain the expected column names. Their substantive contents and key uniqueness have not been fully validated.
- The upstream commit and download date have not yet been recorded. Record them if recoverable; file modification times alone do not establish provenance.

### Integration with the replication inputs

The current analysis scripts use `input/`; downloading files into `data/` does not connect them to the workflow. No merge has been performed.

For initial validation, compare `data/public_float.csv` against the prepared threshold samples using `cik` + `publicfloat_year`. Standardize key types, verify uniqueness on both sides, retain both versions of public float, and report unmatched records and value differences before changing any analysis input. Preserve existing sample restrictions and treatment indicators during this comparison.

Do not assume every dataset has an equivalent year key. In particular, inspected records in `input/table2.dta` contain `fyear` values such as 6, 8, and 4; investigate these before attempting a calendar-year merge. The source public-float panel cannot restore scrambled financial controls or outcomes. A complete raw-data reconstruction still requires the relevant original sources and sample-construction rules.

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

The original package describes the data as intended for academic use and requests citation when reusing the data or code. The additional source repository supplies the following published citation:

Ewens, Michael, Kairong Xiao, and Ting Xu. “Regulatory costs of being public: Evidence from bunching estimation.” *Journal of Financial Economics* 153 (2024): 103775.

Retain `data/README.md` and `data/LICENSE`. Consult the original package notes and applicable source-data terms before reuse or redistribution.
