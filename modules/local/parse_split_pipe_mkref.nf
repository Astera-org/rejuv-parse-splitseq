process PARSE_SPLIT_PIPE_MKREF {
    tag "$fasta"
    label 'process_high'

    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using the Parse split-pipe tool. Please use docker or singularity containers."
    }

    container "002528935177.dkr.ecr.us-west-2.amazonaws.com/parse-split-pipe"

    input:
    path(fasta)
    path(gtf)
    val(genome_name)

    output:
    path "$genome_name" , emit: index
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def sample_arg = meta.samples.unique().map{ "--sample ${it.name} ${it.wells}" }.join(" ")
    def reference_name = reference.name

    // 'A1:C6' specifies a block as [top-left]:[bottom-right]; A1-A6, B1-B6, C1-C6.
    // 'A1-B6' specifies a range as [start]-[end]; A1-A12, B1-6.
    // 'C4' specifies a single well.
    // Multiple selections are joined by commas (no space), e.g. 'A1-A6,B1:D3,C4'

    """
    split-pipe \\
        --mode mkref \\
        --output_dir=$genome_name \\
        --genome_name=$genome_name \\
        --genes=$gtf \\
        --fasta=$fasta \\
        --nthreads=$task.cpus \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        split-pipe: \$(echo \$( split-pipe --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*.*\\).*\$/\\1/' )
    END_VERSIONS
    """

    stub:
    """
    mkdir -p "$genome_name/"
    touch $genome_name/fake_file.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        split-pipe: \$(echo \$( split-pipe --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*.*\\).*\$/\\1/' )
    END_VERSIONS
    """
}
