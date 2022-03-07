#!/usr/bin/env nextflow
/*
========================================================================================
    nf-core/parseseq
========================================================================================
    Github : https://github.com/nf-core/parseseq
    Website: https://nf-co.re/parseseq
    Slack  : https://nfcore.slack.com/channels/parseseq
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    GENOME PARAMETER VALUES
========================================================================================
*/

params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')

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

include { PARSESEQ } from './workflows/parseseq'

//
// WORKFLOW: Run main nf-core/parseseq analysis pipeline
//
workflow NFCORE_PARSESEQ {
    PARSESEQ ()
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
    NFCORE_PARSESEQ ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
