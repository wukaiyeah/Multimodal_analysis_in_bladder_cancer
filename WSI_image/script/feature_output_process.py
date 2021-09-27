import os
import pandas as pd
import json


if __name__ == '__main__':
    features1_file = '/media/wukai/AI_Team_03/Bladder_project/WSI_image/slices_nuclei_features.csv'
    features2_file = '/media/wukai/AI_Team_03/Bladder_project/WSI_image/slices_plasm_features.csv'
    info_file = '/media/wukai/AI_Team_03/Bladder_project/clinical_info/case_id_info.txt'
    # process case_id
    with open(info_file,'r') as IN:
        IN.readline()
        IN = IN.readlines()
        cases_id_dict = {}
        for line in IN:
            case_id = line.strip().split('\t')[0]
            file_id = line.strip().split('\t')[2]
            cases_id_dict[file_id] = case_id

    features1_table = pd.read_csv(features1_file,index_col=0)
    features2_table = pd.read_csv(features2_file,index_col=0)

    cases_id = [sample_id.split('_')[0] for sample_id in features1_table.index]
    cases_id = [sample_id.replace('TP','') for sample_id in cases_id]
    cases_id = ['-'.join(sample_id.split('-')[0:3]) for sample_id in cases_id]
    cases_id = [cases_id_dict.get(sample_id) for sample_id in cases_id]


    feature_names1 = features1_table.columns.tolist()
    feature_names2 = features2_table.columns.tolist()

    feature_names1 = ['nuclei_'+name for name in feature_names1]
    feature_names2 = ['plasm_'+name for name in feature_names2]

    features1_table.columns = feature_names1
    features2_table.columns = feature_names2
    features_table = pd.concat((features1_table, features2_table), axis=1)
    features_table.insert(0, 'sample_id',features_table.index)
    features_table.insert(0, 'case_id',cases_id) # add case id column
    features_table = features_table.iloc[list(-features_table['case_id'].isna()), :] # remove None line

    features_table.to_csv('/media/wukai/AI_Team_03/Bladder_project/WSI_image/wsi_features_nuclei_plasm.csv',index = False, sep = ',')
    print('OK')