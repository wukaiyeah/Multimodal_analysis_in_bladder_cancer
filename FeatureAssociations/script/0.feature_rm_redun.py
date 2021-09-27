import pandas as pd
import os
import numpy as np

def identify_redundant(feat_list, corr_table):
    redund_list = []

    for feat in feat_list:
        if feat in redund_list:
            continue

        feat_pattern = '_'.join(feat.split('_')[0:3])
        corr_pairs = corr_table.loc[corr_table['feat1'] == feat,]
        for feat2 in corr_pairs['feat2']:
            if feat_pattern in feat2:
                redund_list.append(feat2)


    return redund_list


if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations'
    high_cor = pd.read_csv(os.path.join(base_dir, 'high_corr_table.csv'))
    feat_list = np.unique(high_cor['feat1'])

    redund_list = identify_redundant(feat_list, high_cor.iloc[:,0:2])
    redund_list = np.unique(redund_list)

    total_feat = pd.read_csv('/media/wukai/AI_Team_03/Bladder_project/ct_wsi_merged_features.csv',header=0, index_col = 0 )
    new_columns = [feat for feat in total_feat.columns if feat not in redund_list]
    new_feat = total_feat[new_columns]
    new_feat.to_csv(os.path.join(base_dir, 'ct_wsi_nonredunt_features.csv'),sep = ',')