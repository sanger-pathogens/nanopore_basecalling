#!/usr/bin/env nextflow
// Copyright (C) 2024 Genome Research Ltd.

/*
========================================================================================
    HELP
========================================================================================
*/

def logo = NextflowTool.logo(workflow, params.monochrome_logs)

log.info logo

NextflowTool.commandLineParams(workflow.commandLine, log, params.monochrome_logs)


def printHelp() {
    NextflowTool.help_message("${workflow.ProjectDir}/schema.json", 
                               [],
    params.monochrome_logs, log)
}

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// SUBWORKFLOWS
//
include { MANIFEST_PARSE; 
          cli_parse         } from './subworkflows/input_check.nf'
include { ONT_BASECALLING   } from './assorted-sub-workflows/ont_basecalling/ont_basecalling.nf'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow {
    if (params.help) {
        printHelp()
        exit 0
    }

    if (!params.manifest && !params.raw_read_dir) {
        exit 1, "Must provide either --manifest or --raw_read_dir"
    }

    manifest_reads = params.manifest
        ? MANIFEST_PARSE(channel.fromPath(params.manifest, checkIfExists: true))
        : channel.empty()

    cli_reads = params.raw_read_dir
        ? channel.of(cli_parse(params.raw_read_dir))
        : channel.empty()

    cli_reads.mix(manifest_reads)
    | ONT_BASECALLING

}

workflow.onComplete {
        NextflowTool.summary(workflow, params, log)

        log.info """
                To rerun from ${workflow.launchDir}:
                bsub -q oversubscribed -R "select[mem>4000] rusage[mem=4000]" -M4000 -o ${workflow.runName}_repeat.o -e ${workflow.runName}_repeat.e -J ${workflow.runName}_repeat ${workflow.commandLine}
                """
}
/*
========================================================================================
    THE END
========================================================================================
*/