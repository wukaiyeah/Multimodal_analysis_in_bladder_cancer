import os
import glob
import numpy as np
import pandas as pd

def  counts_to_tpm(datatable, sample_name):
    '''
    convert read counts to TPM (transcripts per million)
    return: TPM
    '''
    sample_reads = datatable.loc[:,sample_name].copy()
    gene_len = datatable.loc[:,'Length']
    rate = sample_reads.values/gene_len.values
    tpm = rate/np.sum(rate, axis=0).reshape(1, -1)*1e6
    tpm_table = pd.DataFrame(tpm[0])
    tpm_table.columns = [sample_name]
    tpm_table.index = datatable.index
    return tpm_table



if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/Genome'
    counts_file = os.path.join(base_dir, 'total_rnaseq_counts.csv')
    gene_info_file = os.path.join(base_dir, 'gene_length_info.tsv')
    marker_gene_file = os.path.join(base_dir, 'luminal_basal_marker_gene.txt')
    counts_table = pd.read_csv(counts_file, sep = ',', header=0, index_col=0)
    gene_info_table = pd.read_table(gene_info_file, sep = '\t', header=0, index_col=None)
    gene_info_table = gene_info_table.drop_duplicates(subset = 'Gene')
    gene_info_table = gene_info_table.set_index('Gene')
    datatable = pd.concat((gene_info_table, counts_table),axis=1, join='inner')

    tpm_table = datatable.iloc[:,0:2]
    for sample_name in datatable.columns[2:]:
        tpm_table = pd.concat((tpm_table, counts_to_tpm(datatable, sample_name)),axis=1, join='inner')
    tpm_table.to_csv(os.path.join(base_dir,'total_rnaseq_tpm.csv'), sep = ',')

          
