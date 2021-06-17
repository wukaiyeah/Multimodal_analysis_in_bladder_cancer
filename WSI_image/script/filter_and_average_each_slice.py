import glob
import numpy as np
import pandas as pd
from multiprocessing import Pool
from functools import partial

def filter_and_average(slice_id,slicetable):
    '''
    filter object by remove the outlier
    and average the rest
    '''
    dataframe = slicetable[slice_id]
    valueframe = dataframe.iloc[:,4:]
    mean_value = valueframe.mean()
    std_value = valueframe.std()
    valueframe = valueframe[mean_value.index]

    non_outlier = []
    for index,line in valueframe.iterrows():
        if sum(line >= (mean_value - 3*std_value)) == len(line):
            if sum(line <= (mean_value + 3*std_value)) == len(line):
                non_outlier.append(True)
            else:
                non_outlier.append(False)
        else:
            non_outlier.append(False)
    # remove outlier object
    new_valueframe = valueframe[non_outlier]
    result_dict = {}
    result_dict[slice_id] = new_valueframe.mean()
    return result_dict

def standardization(data):
    mu = np.mean(data, axis=0)
    sigma = np.std(data, axis=0)
    return (data - mu) / sigma
    

def filter_features(datatable):
    '''
    filter by remove the column(Standard Deviation == 0)
    '''
    
    filtered_feature_names = ['FileName_DNA']
    for feature, ser in datatable.items():
        try:
            if ('Mean_' in feature) or ('Median_' in feature) or ('StDev_' in feature) or ('Texture_' in feature):
                if np.std(ser) > 0:
                    filtered_feature_names.append(feature)
        except:
            pass
    new_datatable = datatable[filtered_feature_names]
    return new_datatable


if __name__ == '__main__':
    file1_path = '/media/wukai/AI_Team_03/Bladder_project/WSI_image/MyExpt_image.csv'
    datatable = pd.read_csv(file1_path, header = 0)

    slices_id = [path.split('\\')[-1].replace('.svs','') for path in np.unique(datatable['PathName_DNA'])]
    datatable = filter_features(datatable)

    datatable.T.to_csv('/media/wukai/AI_Team_03/Bladder_project/WSI_image/MyExpt_image2.csv', sep = ',',header = 0)

    # 按照切片样本拆分
    slicetable = {}
    for slice_id in slices_id:
        slicetable[slice_id] = datatable[datatable['PathName_DNA'].str.contains(slice_id)]
    
    # filter

    #for slice_id in slicetable.keys():
    #    slicetable[slice_id] = filter_and_average_image(slicetable[slice_id])
    
    with Pool(10) as pool:
        slicefeature_list = pool.map(partial(filter_and_average, slicetable = slicetable), slicetable.keys())  # 并行
        pool.close() 
        pool.join()

    slices_name = []
    for i,slicefeature in enumerate(slicefeature_list):
        if i == 0:
            slices_name.append(list(slicefeature.keys())[0])
            slices_feature = pd.DataFrame(list(slicefeature.values())[0])
        else:
            slices_name.append(list(slicefeature.keys())[0])
            slices_feature = pd.concat((slices_feature, pd.DataFrame(list(slicefeature.values())[0])), axis=1)
    slices_feature.columns = slices_name # 添加sample名
    slices_feature = slices_feature.T# dataframe 转置
    slices_feature.to_csv('/media/wukai/AI_Team_03/Bladder_project/WSI_image/slices_image_features.csv', sep = ',')
