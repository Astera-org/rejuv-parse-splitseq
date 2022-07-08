//
// Uncompress and prepare reference genome files
//

include { GUNZIP as GUNZIP_FASTA            } from '../../modules/nf-core/modules/gunzip/main'

include { UNTAR as UNTAR_INDEX              } from '../../modules/nf-core/modules/untar/main'

include { PARSE_SPLIT_PIPE_MKREF            } from '../../modules/local/parse_split_pipe_mkref'


workflow PREPARE_GENOME {
    main:

    ch_versions = Channel.empty()

    //
    // Uncompress genome fasta file if required
    //
    if (params.fasta.endsWith('.gz')) {
        ch_fasta    = GUNZIP_FASTA ( [ [:], params.fasta ] ).gunzip.map { it[1] }
        ch_versions = ch_versions.mix(GUNZIP_FASTA.out.versions)
    } else {
        if(params.fasta){
            ch_fasta = file(params.fasta)
        }
    }

    if(params.gtf){
        ch_gtf = file(params.gtf)
    }

    //
    // Uncompress index or generate from scratch if required
    //
    ch_index = Channel.empty()
    if(params.index){
        if(params.index.endsWith('.tar.gz')) {
            ch_index = UNTAR_INDEX(params.index).untar
            ch_versions = ch_versions.mix(UNTAR_INDEX.out.versions)
        } else {
            ch_index = file(params.index)
        }
    } else {
        ch_index = PARSE_SPLIT_PIPE_MKREF (
                ch_fasta,
                params.gtf,
                params.genome_name
            ).index
        ch_versions   = ch_versions.mix(PARSE_SPLIT_PIPE_MKREF.out.versions)
    }


    emit:
    fasta            = ch_fasta                  //    path: genome.fasta
    gtf              = ch_gtf                    //    path: genes.gtf
    index            = ch_index                  //    path: genome_dir
    versions         = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
