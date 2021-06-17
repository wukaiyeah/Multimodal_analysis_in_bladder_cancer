import os
import re
import glob
import numpy as np
import pandas as pd

def process_tcga_table(datatable):
    datatable.index = [index.split('.')[0] for index in datatable.index]
    colnames = [sample_id for sample_id in datatable.columns if '11A' not in sample_id and '.1' not in sample_id]
    colnames = np.unique(colnames)
    datatable = datatable.loc[:,colnames]
    datatable = datatable.T
    datatable = datatable.reset_index()
    datatable.index = datatable.loc[:,'index']
    datatable.loc[:,'index'] = ['-'.join(sample_id.split('-')[0:3]) for sample_id in datatable.loc[:,'index']]
    datatable = datatable.drop_duplicates(subset = 'index')
    datatable = datatable.drop(['index'],axis = 1)
    datatable = datatable.T
    return datatable


if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/Genome'
    tcga_counts_table = pd.read_table(os.path.join(base_dir,'TCGA.htseq.counts.tsv'), sep = '\t', index_col=0, header=0)
    beijing_counts_table =  pd.read_csv(os.path.join(base_dir, 'raw_counts_beijing_participant.csv'), sep = ',', index_col=0, header=0)

    tcga_counts_table = process_tcga_table(tcga_counts_table)
    total_counts_table = pd.concat([beijing_counts_table, tcga_counts_table], axis=1, join='inner')
    total_counts_table.to_csv(os.path.join(base_dir, 'total_rnaseq_counts.csv'), sep = ',')
    need_ids = pd.read_csv('/media/wukai/AI_Team_03/Bladder_project/clinical_info/case_id_info.csv', sep = ',', header=0, index_col=None)
    need_ids = list(need_ids.iloc[:,0])
    merged_id = [need_id for need_id in need_ids if need_id in total_counts_table.columns]
    needed_counts_table = total_counts_table.loc[:,merged_id]
    needed_counts_table.to_csv(os.path.join(base_dir, 'blca_rnaseq_counts.csv'), sep = ',')
    pass
    
