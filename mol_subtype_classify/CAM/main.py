'''
@Author: Kai Wu
My Score-CAM script for Conv1d-net
Part of code borrows from https://github.com/haofanwang/Score-CAM and
 https://github.com/1Konny/gradcam_plus_plus-pytorch
'''
import os
import pandas as pd
import numpy as np
from sklearn.preprocessing import scale
from sklearn.model_selection import StratifiedShuffleSplit
import torch
import torch.nn.functional as F
from cam.scorecam import *
# from utils import *

def data_split(x_features, y_label):
    # split case
    SS=StratifiedShuffleSplit(n_splits=1,test_size=0.20,random_state=1234)
    for train_index, test_index in SS.split(x_features, y_label):
        train_index = np.sort(train_index)
        X_train = x_features[train_index]#训练集对应的值
        y_train = y_label[train_index]#类别集对应的值
    return X_train, y_train, train_index


if __name__  == '__main__':
    # load dataset
    datatable = pd.read_csv('/media/wukai/AI_Team_03/Bladder_project/script/classifier/dataset_for_classifer.csv',index_col=0, header=0)
    y_label = np.array(datatable['mol_label']).astype(np.float32)
    x_input = np.array(datatable.iloc[:,2:])
    x_input = scale(x_input).astype(np.float32)
    x_input, y_label, train_index = data_split(x_input, y_label) # only training case
    
    
    # load model
    net = torch.load('/media/wukai/AI_Team_03/Bladder_project/script/classifier/net_2.pth').eval()
    # initiate CAM
    model_dict = dict(type='mynet', arch=net, layer_name='conv5',input_size = x_input.shape[1])
    net_scorecam = ScoreCAM(model_dict)

    # run
    scorecam_list = []
    for input_, class_ in zip(x_input, y_label):
        input_ = torch.from_numpy(input_).unsqueeze(0).unsqueeze(0)
        if torch.cuda.is_available():
            input_ = input_.cuda()
            net = net.cuda()
        scorecam_map = net_scorecam(input = input_, class_idx = class_)
        scorecam_map = scorecam_map.squeeze().squeeze().cpu().numpy()
        scorecam_list.append(scorecam_map)
    scorecam_matrix = pd.DataFrame(np.stack(scorecam_list, axis=0))
    scorecam_matrix.index = datatable.index[train_index]
    clin_info_table = datatable.iloc[train_index,0:2]
    scorecam_matrix = pd.concat((clin_info_table,scorecam_matrix), axis=1, join='inner')
    scorecam_matrix.columns = datatable.columns
    scorecam_matrix.to_csv('/media/wukai/AI_Team_03/Bladder_project/script/CAM/scorecam_matrix.csv')
    pass