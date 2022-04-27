#!/usr/bin/env nextflow
/*
========================================================================================
    Astera-org/rejuv-parse-splitseq
========================================================================================
    Github : https://github.com/Astera-org/rejuv-parse-splitseq
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    GENOME PARAMETER VALUES
========================================================================================
*/

params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')
params.gtf   = WorkflowMain.getGenomeAttribute(params, 'gtf')

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { PARSE_SPLITSEQ } from './workflows/parse-splitseq'

//
// WORKFLOW: Run main Astera-org/rejuv-parse-splitseq analysis pipeline
//
workflow NFCORE_PARSE_SPLITSEQ {
    PARSE_SPLITSEQ ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    NFCORE_PARSE_SPLITSEQ ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
