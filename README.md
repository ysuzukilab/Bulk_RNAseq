# Bulk_RNAseq
Repository for Bulk RNA-seq analysis

## Step 1. Import necessary tools  
`bash preparation.sh`


## Step 2. Download data
Prepare input file wich has all the ftp addresses of the data you want.  
Then run either of the following:  
`qsub -l os7 -cwd ftp_wget.sh your_input_file.txt`   
		OR  
`bash ftp_wget.sh your_input_file.txt &`  

## Step 3. Map against reference (Star mapper)
The following command maps data against reference and runs feature-counting tools.  
`qsub -cwd -l os7 star.sh`  
First time:  
   1. Download reference sequence (from NCBI, DDBJ, EMBL etc.)  
   2. Prepare reference indices.  

## Step 4. Summarise mapping/feature count log info  
`python star_scripts/summarise_feature_counts.py STAR_OUTPUT/`  
  
## Step 5. Generate feature counts matrix
The output may be used as CIBERSORT input mixture matrix.  
`python star_scripts/summarise_mapping_quality.py ./STAR_OUTPUT`  

