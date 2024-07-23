nextflow.enable.dsl=2

process cell_ranger {
    tag "cell_ranger"

    cpus 12
    memory "84 GB"

    publishDir "${launchDir}/analysis/cellranger", mode: "copy"

    module "cellranger/8.0.0"

    input:
    val(sub_name)
    each(index)
    //path("${launchDir}/rawdata/")

    output:
    path("${sub_name}"), emit: cellranger_out

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
    cell_ranger(ch_reads, reference)
    multiqc(cell_ranger.out.cellranger_out.collect())
}

workflow.onComplete {
	println ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}