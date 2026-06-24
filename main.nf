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

    if (params.read_dir_manifest) {
        raw_reads = READ_MANIFEST_OF_DIRS(params.read_dir_manifest)
    } else {
        raw_reads = Channel.fromPath("${params.raw_read_dir}/*.{fast5,pod5}", checkIfExists: true)
    }

    ONT_BASECALLING(raw_reads)

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