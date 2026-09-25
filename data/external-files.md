# Files stored outside this repository

These paths are on the Ohio Supercomputer Center and are not included here because the files are large. A public download link can be added when one is available.

## Sequencing reads and intermediate FASTQ files

Raw reads, trimmed reads, human-filtered reads, and alignments:

- `/fs/ess/PAS1695/projects/bewell/data/fastqs/fastqs/`
- `/fs/ess/PAS1695/projects/bewell/data/fastqs/fastp/`
- `/fs/ess/PAS1695/projects/bewell/data/fastqs/sra-scrubbed/`
- `/fs/ess/PAS1695/projects/bewell/data/fastqs/bowties/`
- `/fs/ess/PAS1695/projects/bewell/data/fastqs/ultra-filtered/`
- `/fs/ess/PDE0023/bewell/fastqs/`

## Taxonomic and functional profiles

Per-sample MetaPhlAn profiles and HUMAnN3 output. The aggregated HUMAnN3 table is already in this repository at `data/2024-02-01_humann3-aggregate.csv`.

- `/fs/ess/PAS1695/projects/bewell/data/profiled/` (`profiled_*.txt`)
- `/fs/ess/PAS1695/projects/bewell/data/humann3/`
- `/fs/ess/PAS1695/projects/bewell/data/2024-02-01_mpa-aggregate.csv`
- `/fs/ess/PAS1695/projects/bewell/data/2024-02-01_humann3-aggregate.csv`
- `/fs/ess/PAS1695/projects/bewell/data/bewell_taxonomy_relAbun.csv`
- `/fs/ess/PAS1695/projects/bewell/data/2024-02-01_bewell_taxonomy_relAbun.csv`
- `/fs/ess/PAS1695/projects/bewell/data/RelAbun/` (`RelAbun_*.csv` and `2024-02-01_RelAbun_*.csv`)
- `/fs/ess/PAS1695/projects/bewell/data/bewell_akkermansia.csv`
- `/fs/ess/PAS1695/projects/bewell/data/rankedDeltaMicrobe.csv`
- `/fs/ess/PAS1695/projects/bewell/data/cytokineChange_ranked.csv`

## Sample sheets kept with the sequencing project

- `/fs/ess/PAS1695/projects/bewell/data/participants/bewell_barcodes.csv`
- `/fs/ess/PAS1695/projects/bewell/data/participants/bewell_subjects.csv`

## Reference databases used to filter reads and profile functions

These are public reference collections, not study data.

- `/fs/ess/PAS1695/db/bowtie2-ultrafiltering/merged_ref`
- `/fs/ess/PAS1695/db/chocophlan/chocophlan`
- `/fs/ess/PAS1695/db/chocophlan/uniref`

## Batch scripts and logs

- `/fs/ess/PAS1695/projects/bewell/scripts/pbs/`
- `/fs/ess/PAS1695/projects/bewell/scripts/batch/`
- `/fs/ess/PAS1695/projects/bewell/scripts/logs/`
