# Protocol and statistical analysis plan

The SAP records the analyses implemented for the BE WELL manuscript and maps all
55 Gamble checklist items. The commented Word document remains in the submission
directory; SAP_content.md is its searchable companion, and review_questions.md
mirrors the 31 Word comments.

Nasal swab collection was removed from the protocol during COVID-19 because the
procedure was classified as aerosol generating and created major logistical
barriers to trial implementation. Nasal inflammatory transcript and nasal
expression-dependent analyses are excluded. A Word comment requests the dated
amendment/version and approval reference; no amendment date has been inferred.

Scripts for unperformed proposed analyses have been deleted. The retained
workflow is 06_manuscript_methods.Rmd with manuscript_methods.R. Original
manuscript scripts/data remain unchanged. Guidance:
[Gamble et al. (2017)](https://doi.org/10.1001/jama.2017.18556).

## Run the manuscript workflow

From this folder:

```r
rmarkdown::render('06_manuscript_methods.Rmd')
```

The notebook reads existing ../data tables and writes reconstructed results to
outputs/manuscript-methods, ignored by Git. Set BEWELL_MANUSCRIPT_OUTPUT to an
authorized absolute directory to change the output location. Do not publish
participant listings or clinical reports.

Required packages: rmarkdown, knitr, readxl, dplyr, tidyr, lme4, vegan and tableone.
HTML rendering also requires Pandoc. Without it, execute through knitr::knit
with an explicit params list to produce Markdown. Seeds added where source code
has no local seed may change permutation P values from saved figures.

The workflow covers Table 1, metabolite paired tests/BH values, the final
median-split polyphenol score, cytokine logistic mixed models, active taxon GLMs,
the source Simpson/Welch path, response grouping/PCA and Bray–Curtis PERMANOVA.
manuscript_method_crosswalk.csv identifies generating sources and unresolved
prose/code differences. No new multiplicity, count-model, gene–microbe or
crossover sensitivity analysis is added.

## Existing inputs

| Input in ../data | Use |
| --- | --- |
| derived/clinical_manuscript.rds | Cohort flags, demographics and visit keys |
| raw/urine-metabolomics/Dan Urine Anthocyanin 11-10-2022.xlsx | Concentration ng mL worksheet and source analyte filter |
| derived/cytokines_avg-results.csv | Processed analyte measurements |
| derived/compliance_cluster_df.csv | Saved polyphenol responder subset |
| derived/RelAbun/RelAbun_*.csv | Seven rank-specific taxon matrices |
| derived/bewell_taxonomy_relAbun.csv | Abundances and participant/visit mapping |
| model_stats_BW.rda | Saved model_res_BW table used for response grouping |

These files do not establish the full screening/randomization, exposure or
adverse-event record. Those reporting details remain Word comments; no extra
clinical analysis is introduced here. Nasal specimens removed from the required
schedule must not be counted as missing required collections.

## Decisions awaiting the completed-trial record

Cytokine multivariate execution is disabled until the final 13/14-analyte matrix
is confirmed. After resolution, use run_cytokine_multivariate and
multivariate_include_il17f for the verified implementation. The separate
Lachnospiraceae display requires its final Activity/cohort manifest with subject,
Activity (Active/Inactive), included (0/1); supply its path through activity_manifest.
These controls resolve source ambiguities and do not specify new analyses.

The saved taxon model table is read as-is; its absent generating formula is not
inferred. Word comments request final taxon models, FDR adjustment and
paired/unpaired diversity-test clarification. Reconstructed results require
comparison with the submitted source outputs.

## Verification

Run Rscript verify.R to parse the retained notebook/helper and check matrix
construction, participant-matched changes, the median responder rule and the
coded microbiome-response boundary. Synthetic fixtures stay in memory.
verification.md records completed checks, including the exact Table 1 and saved
responder-label matches.
