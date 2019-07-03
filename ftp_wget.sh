#!/bin/sh
#$ -S /bin/sh
#$ -l s_vmem=75G
#$ -l mem_req=75G

<< COMMENT
USAGE: qsub -l os7 -cwd ftp_wget.sh your_input_file.txt
		OR
	bash ftp_wget.sh your_input_file.txt &
DESCRIPTION:
	Retrieve (fastq) files from DDBJ etc. via their ftp addresses 
	Use when working with multiple fastq files.
INPUT_FILE:
	A file that consists of a ftp address list
	(a single address per line)
	File name may be anything.
COMMENT


while read line
do
	wget -P ./ftp_data/ $line
done < ${1}

