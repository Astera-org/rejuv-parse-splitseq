//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

import org.yaml.snakeyaml.Yaml

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:'\t' )
        .map { create_fastq_channels(it) }
        .set { reads }

    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

def parseFASTQColumn(column) {
    Yaml parser = new Yaml()
    def result = parser.load(column)
    if(result.class == String) {
        return [result]
    } else {
        return result
    }
}

def parseSampleLoc(column) {
    Yaml parser = new Yaml()
    return parser.load(column)
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id           = row.library
    meta.sample       = row.library
    meta.sample_loc   = parseSampleLoc(row.sample_loc)
    meta.single_end   = row.single_end.toBoolean()

    def fastq_1 = parseFASTQColumn(row.fastq_1)
    def fastq_2 = parseFASTQColumn(row.fastq_2)
    def array = []
    for(it in fastq_1) {
        if(!file(it).exists()) {
            throw new Exception("FASTQ file does not exist: ${it}")
            exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${it}"
        }
    }

    if (meta.single_end) {
        array = [ meta, [ fastq_1 ] ]
    } else {
        for(it in fastq_2) {
            if(!file(it).exists()) {
                throw new Exception("FASTQ file does not exist: ${it}")
                exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${it}"
            }
        }
        array = [ meta, [ fastq_1, fastq_2 ] ]
    }
    return array
}
