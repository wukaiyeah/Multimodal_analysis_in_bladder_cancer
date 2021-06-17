import os
import re
import glob
import numpy as np
import pandas as pd

def make_counts_table(file_dir):
    sample_id = file_dir.split('/')[-1].split('_')[0]
    sample_id = re.sub(r'T$','',sample_id)
    datatable = pd.read_table(file_dir, index_col=0, header= None)
    datatable = pd.DataFrame(datatable.loc[:,3])
    datatable.columns = [sample_id]
    datatable.index = [index.split('.')[0] for index in datatable.index]
    datatable = datatable.reset_index()
    datatable = datatable.drop_duplicates(subset = 'index')
    datatable = datatable.set_index('index')
    return datatable 


if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/Genome'
    rawCounts_files = glob.glob(os.path.join(base_dir,'RawData','*.tab'))
    for i,counts_file in enumerate(rawCounts_files):
        if i == 0:
            counts_table = make_counts_table(counts_file)
        else:
            counts_table = pd.concat((counts_table, make_counts_table(counts_file)), axis=1,join='inner')
    counts_table.to_csv(os.path.join(base_dir, 'raw_counts_beijing_participant.csv'),sep = ',')