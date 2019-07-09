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




