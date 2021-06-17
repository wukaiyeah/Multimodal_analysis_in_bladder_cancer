import os
import glob
import numpy as np
import pandas as pd



if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/Genome'
    total_tpm_file = os.path.join(base_dir, 'total_rnaseq_tpm.csv')
    mol_subtype_file = os.path.join(base_dir, 'tcga_blca_molecular_subtype.csv')
    tcga_marker_gene_file = os.path.join(base_dir, 'tcga_blca_marker_gene.txt')

    tpm_table = pd.read_csv(total_tpm_file, header=0, index_col=0, sep = ',')
    marker_gene = list(pd.read_table(tcga_marker_gene_file, header=None, index_col=None)[0])
    for i,gene_name in enumerate(marker_gene):
        if i == 0:
            marker_gene_tpm_table = tpm_table[tpm_table.Gene_name == gene_name]
        else:
            marker_gene_tpm_table = pd.concat((marker_gene_tpm_table,tpm_table[tpm_table.Gene_name == gene_name]), axis=0)    
    marker_gene_tpm_table.to_csv(os.path.join(base_dir, 'total_tcga_mol_subtype_tpm.csv'),sep = ',')  