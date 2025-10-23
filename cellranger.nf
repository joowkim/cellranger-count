nextflow.enable.dsl=2

process cellranger_count {
    tag "${sub_name}"

    cpus 12
    memory "64 GB"

    publishDir "${launchDir}/analysis/cellranger/count/", mode: "copy"

    module "cellranger/9.0.1"

    input:
    val(sub_name)
    each(index)

    output:
    tuple val(sub_name), path("${sub_name}/outs/filtered_feature_bc_matrix.h5"), emit: matrix
    path("${sub_name}"), emit: count_out

    script:
    """
    cellranger count --id=${sub_name} \
        --transcriptome=${index} \
        --fastqs=${launchDir}/rawdata/ \
        --sample=${sub_name} \
        --localcores=${task.cpus} \
        --localmem=${task.memory.toGiga()} \
        --create-bam=false
    """
}


process cellranger_annotate {
    tag "${sub_name}"

    cpus 10
    memory "32 GB"

    publishDir "${launchDir}/analysis/cellranger/annotation/", mode: "copy"

    module "cellranger/9.0.1"

    input:
    tuple val(sub_name), path(filt_matrix)
    //path("${launchDir}/rawdata/")

    output:
    path("${sub_name}"), emit: cellranger_annotation_out

    script:
    """
    cellranger annotate --id=${sub_name} \
        --matrix=${filt_matrix} \
        --cell-annotation-model=auto \
        --localcores=${task.cpus} \
        --localmem=${task.memory.toGiga()} \
        --tenx-cloud-token-path=/home/kimj32/10x-token.txt
    """
}



process multiqc {
    tag "multiqc"

    cpus 2
    memory "2 GB"

    publishDir "${launchDir}/analysis/multiqc"

    module "python/3.11.1"

    input:
    path(cellranger_out)
    //path("${launchDir}/rawdata/")

    output:
    path("*.html")

    script:
    config_yaml = "/home/kimj32/config_defaults.yaml"
    """
    multiqc ${cellranger_out} --filename "multiqc_report.html" --ignore '*STARpass1' --config ${config_yaml}
    """
}

reference = Channel.fromPath(params.index.(params.genome), checkIfExists: true)
ch_samplesheet = Channel.fromPath(params.samplesheet, checkIfExists: true)
ch_reads = ch_samplesheet.splitCsv(header:true).map {

    // This is the read1 and read2 entry
    sub_name = it['Submitted_Name']
}

workflow {
    cellranger_count(ch_reads, reference)
    multiqc(cellranger_count.out.count_out.collect())
    cellranger_annotate(cellranger_count.out.matrix)
}

workflow.onComplete {
	println ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}