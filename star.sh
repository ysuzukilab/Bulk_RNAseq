#!/bin/sh
#$ -S /bin/sh
#$ -l s_vmem=75G
#$ -l mem_req=75G

<<COMMENT
USAGE: qsub -cwd -l os7 star.sh
DESCRIPTION:
	Input: RNA seq data (fastq file)
	1. quality check
		filter/remove low quality reads [fastqc]
	2. Map to reference 
		Option of initialising reference indices available [Star mapper]
	3. Feature counting
		Count the number of reads per gene [subread featureCounts]
	Output: Feature counts matrix (gene_num*1 matrix)
COMMENT

module use /usr/local/package/modulefiles
module load fastqc
module load samtools
module load fastx-toolkit

export PATH=/home/nina/tools/STAR-2.7.1a/bin/Linux_x86_64/:$PATH
export PATH=/home/nina/tools/subread-1.6.4-Linux-x86_64/bin/:$PATH


preparation(){
	FOLDER='STAR_OUTPUT'
	mkdir $FOLDER
	cd $FOLDER
	mkdir counts
}


quality_check(){
	ID=${1}
	bzip2 -dk ${ID}.fastq.bz2
	fastqc ${ID}.fastq
	fastq_quality_trimmer -Q33 -t 20 -l 18 -i ${ID}.fastq| fastq_quality_filter -Q33 -q 20 -p 80 -o ${ID}.fastq_filtered.fastq
	fastqc ${ID}.fastq_filtered.fastq 
	mv ${ID}.fastq /archive/data/hgc0708/nyoshitake/human_bulk
}


STAR_index(){
	#make STAR's indices; run this if necessary (like for a new set of reference)
	STAR	--runThreadN 12 \
		--runMode genomeGenerate \
		--genomeDir /home/nina/data/reference/Homo_sapiens/star/ \
		--genomeFastaFiles /home/nina/data/reference/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa \
		--sjdbGTFfile /home/nina/data/reference/Homo_sapiens/UCSC/hg38/Annotation/Genes/genes.gtf \
		--limitGenomeGenerateRAM 34000000000 \
		--genomeSAindexNbases 8 
}


STAR_mapping(){
	#map via STAR
	ID=$1
	STAR --runThreadN 4 \
		--genomeDir /home/nina/data/reference/Homo_sapiens/star/ \
		--readFilesIn ${ID}.fastq_filtered.fastq \
		--genomeLoad NoSharedMemory \
		--outFilterMultimapNmax 1 \
		--outSAMtype BAM SortedByCoordinate \
		--outWigType wiggle read1_5p \
		--sjdbGTFfile /home/nina/data/reference/Homo_sapiens/UCSC/hg38/Annotation/Genes/genes.gtf
}

#featureCount (subread package)
#input: STAR's output (sam file)
feature_counts(){
	ID=$1
	featureCounts -T 8 \
			-t exon \
			-g gene_id \
			-s 1 \
			-R BAM Aligned.sortedByCoord.out.bam \
			-a /home/nina/data/reference/Homo_sapiens/UCSC/hg38/Annotation/Genes/genes.gtf \
			-o counts.txt 

	sed -e "1,2d" counts.txt | cut -f1,7 > ${ID}_counts_for_R.txt
	cp ${ID}_counts_for_R.txt ../counts/
}

func(){
	ID=$1
	mkdir $ID
	cd $ID
	cp ../../ftp_data/${ID}.fastq.bz2 ./
	echo $ID
	quality_check $ID
	#STAR_index #for the first time using STAR for a reference, run this
	STAR_mapping $ID
	feature_counts $ID
	cd ../
}

main () {
	preparation STAR_output
	
	#Loop through all 100+ data
	while read line
	do	
		ID=$line
		func $ID ftp_data/bz2_lst.txt
	done < ftp_data/bz2_lst.txt
	
}

main

exit;
 
