import os
import pandas as pd
import json


if __name__ == '__main__':
    features1_file = '/media/wukai/AI_Team_03/Bladder_project/CT_image/total_radiomics_label1.csv'
    features2_file = '/media/wukai/AI_Team_03/Bladder_project/CT_image/total_radiomics_label2.csv'
    features1_table = pd.read_csv(features1_file)
    features2_table = pd.read_csv(features2_file)
    files_id = [image_dir.split('/')[-1].replace('_0000.nii.gz','') for image_dir in features1_table['Image']]

    feature_names = [feature for feature in features1_table.columns.tolist() if 'original' in feature and 'diagnostics' not in feature]
    features1_table = features1_table[feature_names]
    features2_table = features2_table[feature_names]

    features1_table.columns = [name.replace('original', 'bladder') for name in feature_names]
    features2_table.columns = [name.replace('original', 'cancer') for name in feature_names]
    features_table = pd.concat((features1_table, features2_table), axis=1)
    features_table.index = files_id
    features_table.to_csv('/media/wukai/AI_Team_03/Bladder_project/CT_image/texture_features_radiomics.csv',index = True, sep = ',')
    print('OK')