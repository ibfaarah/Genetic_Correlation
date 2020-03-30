#!/usr/bin/env nextflow


/*
*
* -------------------------------------------------------
*               nextflow-Genetic-Correlation 
* -------------------------------------------------------
*               Ibrahim Bashe Farah
*/



/* REQUIRMENTS

-1) A single directory - that hold all summary statistics 
-2) (FOR SHIVOM GWAS) Name of each summary stats be name of Pheno ONLY.

*/



// STEP 1 --> Create Channel for input files and values


if (params.ld_reference){
    Channel.fromPath(params.ld_reference)
    .ifEmpty {exit 1, "Cannot find LD Reference files"}
    .set{ld_reference}
}



if (params.input_file){
    Channel.fromPath(params.input_file)
    .splitCsv(header:true, sep: ",")
    //.map{ row -> [file(row.file_summary_stats), row.population_sample_number]}
    .map{ row-> tuple( file(row.file_summary_stats), row.population_sample_number, file(row.reference)) }
    .set {input_file}
}



// STEP 3 --> Convert Shivom Summary Stats file into 'LDSC Style Summary Stats'

process MungeSumStats {
    
    publishDir 'results/ldsc_style_sum_stats', mode: 'copy', overwrite: true

    input:
    set file(file_summary_stats), population_sample_number, file(reference) from input_file
    
    output:
    file("*") into ldsc_sum_stats
    file "${'*'}.sumstats.sumstats.gz" into genetics_correlation_sum_stats
    val "${x}.sumstats.sumstats.gz" into genetics_correlation_sum_stats_id

    script:
    x = "${file_summary_stats.baseName}"

    """
    munge_sumstats.py \
    --sumstats ${file_summary_stats} --N ${population_sample_number} --out ${x} --merge-alleles ${reference} 
    
    
    """
}

genetics_correlation_sum_stats = genetics_correlation_sum_stats.collect()


// STEP 4 --> Compute Genetic Correlation Scores for Two Phenotypes

process GeneticCorrelation {

    publishDir 'results/Genetic_Correlation', mode: 'copy', overwrite: true

    input:
    val(list_file) from genetics_correlation_sum_stats
    file ld_reference from ld_reference
    
    output:
    file "*" into results

    script:
    
    values = list_file.join(',')

    """

    ldsc.py --rg ${values} --ref-ld-chr "${ld_reference}/" --w-ld-chr "${ld_reference}/"  --out genetic_correlation
    """
}




