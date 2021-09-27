'''
for filter the densely associated clusters
'''
import os
import pandas as pd
from pandas.core import base
from pandas.core.arrays.integer import integer_array

if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations/output'
    clusters = pd.read_table(os.path.join(base_dir, 'sig_clusters.txt'), header=0, index_col=0, sep = '\t')
    cluster_rank = []
    for index, row in clusters.iterrows():
        x_num = len(row['cluster_X'].split(';'))
        y_num = len(row['cluster_Y'].split(';'))
        if x_num >= 2 and y_num >= 2:
            cluster_rank.append(index)
    filtered_clusters = clusters.loc[cluster_rank, :]
    filtered_clusters.to_csv(os.path.join(base_dir, 'sig_clusters_filtered.csv'), sep = ',')