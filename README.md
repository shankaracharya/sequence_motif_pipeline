# Sequence Motif Analysis Pipeline (Nextflow)

This Nextflow pipeline performs:

1. Genome sequence extraction from FASTA
2. Approximate motif matching with mismatches
3. Strand-aware upstream/downstream analysis
4. Motif logo and PSSM generation

## Requirements
- Nextflow ≥ 22
- Python ≥ 3.8
- Biopython, pandas, logomaker

## Run
```bash
nextflow run main.nf

