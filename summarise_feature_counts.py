#!/usr/bin/env python

'''
USAGE: python star_scripts/summarise_feature_counts.py STAR_OUTPUT/

DESCRIPTION: concatenating all the feature count (ID_counts_for_R.txt) files. 
	 generated file = mixture matrix for CIBERSORT input?

FOLDERS should be like
/working_dir/
        L____ STAR_OUTPUT (Could be given any name)
        L____ star_scripts
Make sure to call this script (star_scripts/summarise_Log_final_out.py) from working directory as shown above

as of 2019-06-28

OUTPUT: ./STAR_OUTPUT/feature_counts.tsv (will be Cibersort's input)
'''

#import sys
import pandas as pd
import subprocess
import sys


def extract_info(directory,ID):
	df_tmp = pd.read_csv(directory+'counts/'+ID+'_counts_for_R.txt',sep='\t',index_col=0,header=None)
	df_tmp.columns = [ID]
	return df_tmp	

def main():
	directory = sys.argv[1]
	subprocess.call('ls '+directory+' | grep DR > '+directory+'rm_run_folder_list.txt',shell=True)
	df = pd.DataFrame()
	with open (directory+'rm_run_folder_list.txt','r') as f:
		for line in f:
			ID = line.strip() 
			if df.empty:
				df = extract_info(directory,ID)
			else:
				df = pd.concat([df,extract_info(directory,ID)],axis=1,join='inner')#join=inner????
	df = df.sort_index()
	df.index.name = 'Gene'
	df.to_csv(directory+'feature_counts.tsv',sep='\t')
	subprocess.call('rm '+directory+'rm_run_folder_list.txt',shell=True)




if __name__ == '__main__':
	main()

