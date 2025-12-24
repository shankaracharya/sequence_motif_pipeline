nextflow.enable.dsl=2

params.input_dir = "input"
params.query = "ACTGATCGATCG"
params.mismatches = 2
params.upstream = 50
params.downstream = 50
params.outdir = "results"
params.use_docker = true
params.genome = "input/genome/mm39_genome.fa"   // relative path

workflow {

    samples_ch = Channel.fromPath("${params.input_dir}/*.csv")
    samples_ch.set { sample_files }

    // Step 1: Fetch sequences
    process FETCH_SEQUENCES {

        tag { sample_file.baseName }

        container params.use_docker ? 'seqmatcher:latest' : null

        input:
        path sample_file

        output:
        path "${sample_file.baseName}_with_seq.tsv"

        publishDir "${params.outdir}", mode: 'copy'

        script:
        """
        python /usr/local/bin/scripts/fetch_sequence.py \
            -i ${sample_file} \
            -g ${params.genome} \
            -o ${sample_file.baseName}_with_seq.tsv
        """
    }

    // Step 2: Motif matching + logos
    process MATCH_AND_MOTIFS {

        tag { sample_file.baseName }

        container params.use_docker ? 'seqmatcher:latest' : null

        input:
        path sample_file

        output:
        path "*.tsv"
        path "*.png"
        path "*.meme"

        publishDir "${params.outdir}", mode: 'copy'

        script:
        """
        python /usr/local/bin/scripts/sequence_matcher_with_motifs.py \
            -i ${sample_file} \
            -o ${sample_file.baseName}_matches.tsv \
            -q ${params.query} \
            -m ${params.mismatches} \
            --upstream ${params.upstream} \
            --downstream ${params.downstream}
        """
    }

    // Workflow chaining
    samples_ch
        | FETCH_SEQUENCES
        | MATCH_AND_MOTIFS
}
