process PARSE_SPLIT_PIPE_ALL {
    tag "$meta.id"
    label 'process_high'

    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using the Parse split-pipe tool. Please use docker or singularity containers."
    }

    container "002528935177.dkr.ecr.us-west-2.amazonaws.com/parse-split-pipe"

    input:
    tuple val(meta), path(reads)
    path  reference

    output:
    path("outs/*")                                    , emit: outs
    val(meta)                                         , emit: meta
    path "versions.yml"                               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def sample_arg = meta.sample_loc.collect{ "--sample ${it[0]} ${it[1]}" }.join(" ")
    def reference_name = reference.name

    // 'A1:C6' specifies a block as [top-left]:[bottom-right]; A1-A6, B1-B6, C1-C6.
    // 'A1-B6' specifies a range as [start]-[end]; A1-A12, B1-6.
    // 'C4' specifies a single well.
    // Multiple selections are joined by commas (no space), e.g. 'A1-A6,B1:D3,C4'

    """
    split-pipe \\
        --mode all \\
        $sample_arg \\
        --output_dir=outs \\
        --genome_dir=$reference_name \\
        --rseed=42 \\
        --nthreads=$task.cpus \\
        --no-allwell
        --fq1=${reads[0]} \\
        --fq2=${reads[1]} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        split-pipe: \$(echo \$( split-pipe --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*.*\\).*\$/\\1/' )
    END_VERSIONS
    """

    stub:
    """
    mkdir -p "outs/"
    touch outs/fake_file.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        split-pipe: \$(echo \$( split-pipe --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*.*\\).*\$/\\1/' )
    END_VERSIONS
    """
}
