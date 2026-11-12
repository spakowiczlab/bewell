# Trial and manuscript information requiring confirmation

1. Confirm the official registry and protocol version/amendment governing the completed trial. The supplied v6 document still contains nasal sampling; provide the amendment removing this procedure and assign the final SAP version/approval date.

2. Provide original SAP versions and signatures, protocol approval dates, database lock date, date and scope of unblinding, dates of interim and final analyses, and who accessed treatment labeled outcomes. Establish the timing of each change rather than backdating this document.

3. Confirm the SAP contributors, affiliations, responsibilities and designated signatories. Supply writer, senior statistician and clinical lead signatures and dates. No signatures have been inferred.

4. Confirm the actual dispensed dose/volume and approved schedule. The manuscript resolves the intended twice daily 170 mL schedule, but protocol sections 3, 8.3 and 8.6 contain inconsistent mass/volume/frequency descriptions. Record any correction or amendment and confirm masking and allocation concealment.

5. Confirm the intended exact feasibility decision rule: the statement 26 of 42, the 60% rate criterion, and the 40% null hypothesis with 10% error/90% power are not mathematically interchangeable. The scripts report all three separately and do not claim the stated operating characteristics are validated.

6. Confirm whether any efficacy/futility interim analyses occurred, any statistical stopping rules or alpha adjustments, and whether the protocol safety stopping rule was invoked. Safety review is not an efficacy interim analysis.

7. Specify actual final analysis date, accepted visit windows, handling of repeated/rescheduled collections, and laboratory release dates. Freeze a sample selection manifest with one selected sample per participant, assay and nominal visit; report actual timing and deviations.

8. Resolve the manuscript differential-abundance BH claim against the inspected code. Provide the final adjustment code, full model tables and hypothesis families. Nominal exploratory selections are not FDR-controlled discoveries. Identify confidence intervals actually reported; the SAP does not add a new interval-based analysis.

9. Confirm the authoritative randomized denominator and assay-specific analyzed subject counts. The public RDS has 96 consented and 33 flagged visit completers, but these flags do not verify randomization or all assay completeness. Include replacements and withdrawn participants in trial disposition; do not use the completer cohort as the recruitment denominator.

10. Confirm that the exported median-split compliance_cluster_df.csv is the final adherence/responder definition used for the cytokine subset. An earlier hclust/cutree(k=2) block is overwritten. Supply self-report/returned-container denominators and the external sources for adherence and return-rate panels. A data-derived polyphenol responder is not a fixed threshold of beverage compliance.

11. Supply the deviation adjudication SOP, major/minor criteria and trial deviation summary. Identify the approved amendment and effective date for nasal sampling removal so it is not counted as participant nonadherence or an uncollected required specimen.

12. Provide retained approached/non-enrollment counts. Section 4.3 states nonparticipant recruitment information is deleted; determine whether deidentified aggregate logs remain. Social media impressions or clicks are not unique approached eligible participants.

13. Confirm HEI-2015 versus HEI-2010: the manuscript methods says HEI-2010 but the data and Table 1 script use HEI2015. The implemented HEI categories leave 50, (50,51), (79,80] unclassified; confirm treatment of those boundaries. The implemented age group extends through 79 although protocol eligibility ends at 77. BMI is absent from the public data.

14. Provide the completed-trial feasibility calculations and source denominators. The original feasibility criteria remain design targets; no additional hypothesis test, interval calculation or revised decision rule is introduced by this SAP.

15. Supply the final required-specimen schedule, amendment effective date, and denominator rules used for the completed-trial return-rate figures, including withdrawals and any earlier nasal collections. Do not assume every original-protocol collection remained required.

16. Confirm which final results, if any, estimate a BRB-versus-placebo crossover contrast. The available cytokine code restricts to BRB pre/post; the taxon GLM classifies post-BRB against all other visit labels. Describe those differences from the protocol treatment contrast explicitly.

17. Provide the amendment number/version, effective date and IRB approval reference documenting nasal sampling removal. Confirm how any specimens collected before removal were handled; analyses requiring nasal expression data are not part of this SAP. The rationale for removal has been supplied by the study investigator.

18. Confirm serum/plasma specimen terminology and analyte units: preprocessing adds IL17F from a plasma worksheet labeled pg/mL, whereas plots label cytokines ng/mL. Confirm urine concentration versus volume-normalized 24-hour excretion. Do not silently relabel or rescale stored values.

19. Confirm that zero replacement represents true undetectable concentrations rather than missing samples/QC failure. The script filters on one specimen column (21-V2), so supply the final analyte inclusion list and omitted-row rationale. Confirm the pairing in ggpubr figure annotations; the explicit tabulated metabolite tests do pair by subject.

20. Confirm the final 14-analyte panel and the model formula in the submitted results. The responder file is referenced but not actually read in the active cytokine block; provide the loaded object/file hash. Document singularity, separation and failed-fit handling. The code does not apply BH to these model P values, despite broader manuscript multiple-testing language.

21. Resolve the cytokine feature matrix: the heatmap construction spans ALCAM through vWF A2 and excludes appended IL17F, but downstream multivariate code requests all 14 analytes including IL17F, which cannot run from that matrix without repair. Confirm the final complete-case cohort, the row-sum exclusion, positive shift and CCA input. The F statistic is a term test statistic, not a causal effect size; PC1 sign is arbitrary, so high/low labels refer to its fitted orientation.

22. The manuscript describes mixed-effects/linear differential-abundance models, but the active fig4B generator is glm(binomial) without random effects. The saved model_res_BW contains a different table with degrees of freedom, and its generating model code is absent. Obtain the final fitting script/formula, sample contrasts, covariates, random effects and BH table before claiming one final differential-abundance method. The manuscript PCA selector does not require a positive coefficient, even though prose calls the features BRB-enriched.

23. Reconcile default unpaired Welch tests with the manuscript claim of paired alpha-diversity tests. The Simpson input concatenates nested taxonomic ranks and counts the same community repeatedly; confirm whether the final panel instead used a single rank. Do not silently rewrite the implemented method as paired or single-rank. PCA may fail on zero-variance columns; confirm the final retained features and exact model table behind the outcome-derived response groups.

24. Confirm activity coding: ACSgrant_IPAQbrb.Rmd creates several activity definitions but later uses Activity, which is not present in the public subject table. The barplot sums rows whose taxonomy contains f__Lachnospiraceae, while earlier exact-family code and Fisher tests use a separate absolute-change threshold of 3. These populations and rules are not interchangeable. Supply the final activity field, low-cyanidin exclusion and any Fisher-test table used for the manuscript. Clarify whether the 9-unit rule is in percentage points.

25. Add the dated protocol amendment and approval reference for the removal. Record the implementation date and whether any nasal collections occurred beforehand. The SAP documents the investigator-provided explanation without assigning an unverified date or amendment number.

26. Provide the final per-panel subject/sample manifests and the reason for any unmatched sample, missing assay, dropout or complete-case exclusion. Public timepoint keys include participants with missing assay samples. Do not claim all 33 visit completers contribute to every scientific test.

27. Confirm batch-specific assay QC and whether the pooled CV quantile, removal of < or > markers and batch-4 NaN-to-zero conversion were intentional. Obtain censoring/LOD/LOQ rules. These coded operations must not be described as a generic missing-at-random or laboratory-validated method without supporting records.

28. Confirm whether any period/sequence/carryover analyses were actually used outside manuscript/scripts. If none were performed, report that limit when interpreting pre/post associations. This comment requests the completed-trial record and does not propose a new analysis.

29. Provide final code for the vanillic acid–CRP association (including test type, adjustment family and covariates), HEI/smoking/baseline-PC1 univariate PERMANOVA panel, and any other manuscript panels without a generating script. Confirm final figure numbering: repository fig3 files describe cytokines and fig4 files describe microbiome, whereas the current Word manuscript reverses that order.

30. Provide adjudicated adverse-event data, exposure dates, event coding vocabulary, onset/end dates, seriousness, causality, expectedness and an exposure-based attribution rule. Confirm surveillance completeness and delayed event handling. The scripts require explicit zero-event ascertainment for exposed participants.

31. Supply the Data Management Plan, trial and statistical master file locations, access/retention policies and SOP identifiers for randomization, sample handling, assay QC, data validation and statistical review. Confirm the authoritative protocol PDF matches the supplied version 6 Word document.