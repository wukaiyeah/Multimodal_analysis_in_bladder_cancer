import os 
import numpy as np
import pandas as pd
import json
import itertools


def gen_cases_id(path_list):
    # 对tile路径进行删减，返回样本编号
    slices_id = [path.split('_')[0] for path in path_list]
    cases_id = [slice_id.split('_')[0].replace('TP','') for slice_id in slices_id]
    cases_id = ['-'.join(case_id.split('-')[0:3]) for case_id in cases_id]
    return np.unique(cases_id)

def gen_tiles_dict(tiles_path, cases_id):
    # 生成dict
    tiles_dict = {}
    for case_id in cases_id:
        path_list = []
        for path in tiles_path:
            if case_id in path:
                path_list.append(path)
        tiles_dict[case_id] = path_list
    return tiles_dict

def standardization(data):
    mu = np.mean(data, axis=0)
    sigma = np.std(data, axis=0)
    return (data - mu) / sigma

def gen_clinical_dict(clinical_file):
    grade_dict = {}
    with open(clinical_file, 'r') as IN:
        IN.readline()
        clin_info = IN.readlines()
        for line in clin_info:
            case_id = line.strip().split('\t')[2]
            label = line.strip().split('\t')[3]
            grade_dict[case_id] = label
    return grade_dict




def loss(table, label):
    '''
    
    '''
    label = np.array(label)
    table0 = table.loc[table.index[label == 0],:]
    table1 = table.loc[table.index[label == 1],:]

    var_inner = np.sum(np.std(table0,axis=0)) + np.sum(np.std(table1,axis=0))
    var_outer = np.linalg.norm((np.mean(table0,axis=0) - np.mean(table1,axis = 0)), axis = 0)

    loss = var_inner - 100*var_outer
    return loss




if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/WSI_image'
    datatable = pd.read_csv(os.path.join(base_dir,'MyExpt_image2.csv'),sep = ',', index_col=0,header=0)
    clincal_dict = gen_clinical_dict('/media/wukai/AI_Team_03/Bladder_project/clinical_info/case_id_info.txt')

    feat_array = np.array(datatable.T)
    feat_array_norm = standardization(feat_array)
    tiles_id = [path.split('\\')[-1] for path in datatable.columns]
    feat_array_norm = pd.DataFrame(feat_array_norm, index=tiles_id)

    cases_id = gen_cases_id(tiles_id)
    cases_id = [case_id for case_id in cases_id if case_id in clincal_dict.keys()]
    tiles_dict = gen_tiles_dict(tiles_id, cases_id)

    #test_list = itertools.product(*tiles_dict.values())
    # init
    test_tile_dict = {}
    clin_label = []
    for case_id in tiles_dict.keys():
        test_tile_dict[case_id] = tiles_dict[case_id][0]
        clin_label.append(int(clincal_dict[case_id]))
    best_array = feat_array_norm.loc[test_tile_dict.values(),:]
    best_tile_dict = test_tile_dict
    best_loss = loss(best_array, clin_label)


    for i in range(1000):
        # 1000 epochs   
        for case_id in tiles_dict.keys():
            scan_tiles_id = tiles_dict[case_id]
            for tile_id in scan_tiles_id:
                test_tile_dict[case_id] = tile_id
                test_array = feat_array_norm.loc[test_tile_dict.values(),:]
                current_loss = loss(test_array, clin_label)
                print('epoch %d scan: %s current loss: %f'%(i, tile_id, current_loss))
                if current_loss < best_loss:
                    best_tile_dict = test_tile_dict
                    best_loss = current_loss
                    with open(os.path.join(base_dir,'best_tile_id.json'),"w") as f:
                        json.dump(best_tile_dict,f)
                else:
                    test_tile_dict = best_tile_dict

    with open(os.path.join(base_dir,'best_tile_id.json'),"r") as f:
        best_tile_dict = json.load(f)
    best_array = datatable.loc[:,best_tile_dict.values()]
    best_array.to_csv(os.path.join(base_dir,'slices_image_features.csv'),header = True, sep = ',', index = True)