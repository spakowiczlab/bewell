# Verification on 8 October 2026

The retained workflow is 06_manuscript_methods.Rmd with manuscript_methods.R.
All five earlier feasibility/proposed-analysis notebooks and their common/config
files were deleted at the investigator's request. Nasal expression-dependent
analyses are excluded following the COVID-19 removal of nasal sampling.
The investigator supplied the rationale; the dated amendment remains to be cited.

## Completed manuscript checks

Sources were inspected at repository commit
087c1d6f852cad35eb66d0cf527e0e1b5d602c74. The retained notebook executed against
repository data using knitr and temporary outputs under /tmp. Source data and
manuscript outputs were unchanged. Pandoc was unavailable for HTML conversion.

- Table 1 exactly matched manuscript/tables/table1_baseline.csv.
- The final median-split polyphenol score matched all 20 saved responder labels,
  including 10 responders and 10 nonresponders.
- All 14 all-participant and 14 responder cytokine fits produced native model
  outputs/diagnostics. All reconstructed all-participant fits were singular;
  this does not verify identifiability of their random-intercept variance.
- Active taxon code produced 534 binomial-GLM feature results across seven ranks;
  this does not establish the formula behind saved model_res_BW.
- The source Simpson/Welch, response grouping, baseline PCA/Bray–Curtis PERMANOVA,
  activity PERMANOVA and dispersion paths executed. Added rerun seeds can change
  permutation P values from source panels without a local seed.
- Cytokine CCA/PCA awaits the 13/14-analyte matrix decision. The separate
  Lachnospiraceae display needs its final Activity/cohort manifest. Final taxon
  model/FDR code and missing panel sources remain Word comments.

The deleted workflows are not part of the current verification record. Added
cytokine Wald interval derivations were also removed; native model outputs and
fit diagnostics remain. After cleanup, verify.R parses the retained code and
checks matrix construction, participant pairing, median response and the coded
pseudocount boundary with in-memory fixtures.

The final Word document is rendered with bundled LibreOffice and visually
checked. Comment anchor ranges/references, relationship and content type are
verified structurally. All 55 checklist items remain mapped.
