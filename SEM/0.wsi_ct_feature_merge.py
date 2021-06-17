import os
import pandas as pd
import numpy as np

def gen_ct_feature(file_dir):
    feature_table = pd.read_csv(file_dir, sep = ',', header=0, index_col=0)
    feature_table = feature_table.drop('sample_id',axis = 1)
    return feature_table


def gen_wsi_feature(file_dir):
    feature_table = pd.read_csv(file_dir, sep = ',', header=0, index_col=0)
    cases_id = [path.split('_')[0].replace('TP','') for path in feature_table.columns]
    cases_id = ['-'.join(case_id.split('-')[0:3]) for case_id in cases_id]
    feature_table.columns = cases_id
    feature_table = feature_table.T
    return feature_table   

def gen_patho_dict(feature_table):
  
    patho_to_caseid = {}
    for case_id in feature_table.index:
        patho_id = feature_table.loc[case_id,'patho_id']
        patho_to_caseid[patho_id] = case_id
    return patho_to_caseid 

def gen_clin_feature(file_dir):
    feature_table = pd.read_table(file_dir, index_col=0, header=0)
    feature_table.columns = ['rad_id', 'patho_id', 'grade_label', 'invas_label']
    feature_table = feature_table.drop('rad_id',axis = 1)
    return feature_table


if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project'
    ct_file = os.path.join(base_dir, 'CT_image/texture_features_radiomics1.csv')
    wsi_file = os.path.join(base_dir, 'WSI_image/slices_image_features.csv')
    clin_file = os.path.join(base_dir, 'clinical_info/case_id_info.txt')
    
    ct_feature = gen_ct_feature(ct_file)
    wsi_feature = gen_wsi_feature(wsi_file)
    clin_feature = gen_clin_feature(clin_file)
    patho_to_caseid = gen_patho_dict(clin_feature)

    wsi_feature.index = [patho_to_caseid[patho_id] for patho_id in wsi_feature.index] # change to case name
    clin_feature = clin_feature.drop('patho_id',axis = 1)
    merged_feature = pd.concat([clin_feature, ct_feature, wsi_feature],axis=1,join='inner')
    merged_feature.to_csv(os.path.join(base_dir, 'ct_wsi_merged_features.csv'), sep = ',')