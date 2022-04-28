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

    """
    split-pipe \\
        --mode mkref \\
        --rseed=42 \\
        --nthreads=$task.cpus \\
        --output_dir=$genome_name \\
        --genome_name=$genome_name \\
        --genes=$gtf \\
        --fasta=$fasta \\
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
