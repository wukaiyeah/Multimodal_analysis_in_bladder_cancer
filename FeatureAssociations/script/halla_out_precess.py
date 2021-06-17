import os
import numpy as np
import pandas as pd

if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations/output'
    association_file = os.path.join(base_dir,'all_associations.txt')
    cluster_file = os.path.join(base_dir,'sig_clusters.txt')
    #-process cluster 1
    sig_cluster = pd.read_table(cluster_file, sep = '\t', header=0)
    cluster = sig_cluster.iloc[0,:]
    cluster_x = cluster['cluster_X'].split(';')
    cluster_y = cluster['cluster_Y'].split(';')
    
    #-process association
    association = pd.read_table(association_file, sep = '\t', header=0)
    asso_cluster1 = association.loc[association['X_features'].isin(cluster_x) & association['Y_features'].isin(cluster_y),]
    asso_cluster1.to_csv(os.path.join(base_dir, 'halla_cluster1_asso.csv'), index = False)
    