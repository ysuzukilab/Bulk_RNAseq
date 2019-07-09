#!/usr/bin/env python

'''
USAGE: python star_scripts/summarise_mapping_quality.py ./STAR_OUTPUT

DESCRIPTION: summarise mapping/feature count results (mapping rates etc.)
Directory should be like
/working_dir/
	L____ STAR_OUTPUT (made by running star.sh. May be named differently)
	L____ star_scripts
Make sure to call this script from working directory as shown above

OUTPUT: ./STAR_OUTPUT/df_mappeing_featureCounts_quality_summary.csv
'''

import subprocess
import pandas as pd
import numpy as np
import sys
import argparse

def validate_dir(d):
	if d[-1] == '/':
		return d[:-1]
	else: 
		return d

def extract_info(directory,df,ID):
	with open(directory+'/'+ID+'/Log.final.out','r') as f:
		'''
		Input looks like:
		Started job on |       Jun 28 04:55:40
		Started mapping on |       Jun 28 04:57:11
		'''
		for line in f:
			if '|' not in line:
				continue
			l = line.split('|')
			label = l[0].strip()
			value = l[1].strip()
			df.loc[label,ID] = value

	with open(directory+'/'+ID+'/counts.txt.summary','r') as f:
		'''
		Input looks like:
		Status  Aligned.sortedByCoord.out.bam
		Assigned        4788206
		'''
		for line in f:
			l = line.strip().split('\t')
			df.loc[l[0]] = l[1]
	return df


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('input_dir')
	parser.add_argument('--all',help='optional',action='store_true')
	args = parser.parse_args()
	input_dir = validate_dir(args.input_dir)
	subprocess.call('ls '+input_dir+' | grep DR > '+input_dir+'/rm_run_folder_lst.txt',shell=True)
	df = pd.DataFrame()
	with open (input_dir+'/rm_run_folder_lst.txt','r') as f:
		for line in f:
			ID = line.strip()
			df = extract_info(input_dir,df,ID)
	if not args.all:
		df = df[~np.all(df == 0, axis=1)]
		df = df[~np.all(df == '0', axis=1)]
		df = df[~np.all(df == '0%', axis=1)]
		df = df[~np.all(df == '0.00%', axis=1)]
		df = df.drop(['Started job on','Started mapping on','Finished on','Average input read length','Status'])
	df.to_csv(input_dir+'/df_mapping_featureCounts_quality_summary.csv')
	subprocess.call('rm '+input_dir+'/rm_run_folder_lst.txt',shell=True)


if __name__ == '__main__':
	main()


