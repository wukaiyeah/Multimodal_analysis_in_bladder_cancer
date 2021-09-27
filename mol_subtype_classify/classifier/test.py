# -*- coding: utf-8 -*-
# @Author: Kai Wu

import time
import os
import sys
import argparse
import random
from sklearn.model_selection import StratifiedShuffleSplit
from sklearn.preprocessing import scale
from sklearn.metrics import accuracy_score, roc_auc_score
import pandas as pd
import torch
from torch.utils.data import DataLoader
import torch.optim.lr_scheduler as lr_scheduler
from torch.nn.parameter import Parameter
import torch.nn as nn
import torch.optim as optim
import numpy as np
from model import Net
from dataloader import MyDataset

def gen_parser():
    # Experiment parameters
    parser = argparse.ArgumentParser(description='Deep learning')
    parser.add_argument('--lr', type=float, default=0.005, help='learning rate')
    parser.add_argument('--lr_decay_steps', type=str, default='25,35', help='learning rate')
    parser.add_argument('--wd', type=float, default=1e-4, help='weight decay')
    parser.add_argument('-d', '--dropout', type=float, default=0.1, help='dropout rate')
    parser.add_argument('-f', '--filters', type=str, default='64,64,64', help='number of filters in each layer')
    parser.add_argument('-K', '--filter_scale', type=int, default=1, help='filter scale (receptive field size), must be > 0; 1 for GCN, >1 for ChebNet')
    parser.add_argument('--epochs', type=int, default=1000, help='number of epochs')
    parser.add_argument('-b', '--batch_size', type=int, default=4, help='batch size')
    parser.add_argument('--seed', type=int, default=1234, help='random seed')
    parser.add_argument('--fold', type=int, default=4, help='[0,1,2,3,4]')
    return parser.parse_args()

def data_split(x_features, y_label,args):
    # split case
    SS=StratifiedShuffleSplit(n_splits=5,test_size=0.20,random_state=args.seed)
    split_idx_list = list(SS.split(x_features, y_label))
    train_index = split_idx_list[args.fold][0]
    test_index = split_idx_list[args.fold][1]

    X_train, X_test = x_features[train_index], x_features[test_index]#训练集对应的值
    y_train, y_test = y_label[train_index], y_label[test_index]#类别集对应的值
    return X_train, X_test, y_train, y_test,test_index

if __name__ == '__main__':
    # add parser
    args = gen_parser()
    data_dir = '/media/wukai/Data01/Multimodal_analysis_in_bladder_cancer/mol_subtype_classify/classifier'
    # load dataset
    datatable = pd.read_csv(os.path.join(data_dir,'dataset_for_classifer.csv'),index_col=0, header=0)
    y_label = np.array(datatable['mol_label']).astype(np.float32)
    x_features = np.array(datatable.iloc[:,2:])
    x_features = scale(x_features).astype(np.float32)
    # split data
    print('---------Training Start at fold', args.fold,'----------')
    X_train, X_test, y_train, y_test,test_index = data_split(x_features, y_label, args)

    # initialize model
    net0 = torch.load('/media/wukai/Data01/Multimodal_analysis_in_bladder_cancer/mol_subtype_classify/classifier/net_0_fold%s.pth'%args.fold)

    # test
    net0.eval()
    input_test = torch.tensor(X_test).unsqueeze(1)
    if torch.cuda.is_available():
        input_test = input_test.cuda()
    output_test = net0(input_test)
    proba_net = output_test.squeeze().detach().cpu().numpy()
    accuracy = accuracy_score(y_test, [1 if pre > 0.5 else 0 for pre in output_test])
    auc = roc_auc_score(y_test, output_test.squeeze().tolist())
    print('Current test acc %.2f auc %.2f '%(accuracy,auc))
    
    # save output
    pred_res = pd.DataFrame(np.stack((y_test, output_test.squeeze().detach().cpu().numpy()), axis = 1))
    pred_res.columns = ['mol_subtype','prob']
    pred_res.index = datatable.index[test_index]
    pred_res.to_csv(os.path.join(data_dir,'mol_subtype_pred_net0_fold%d.csv'%args.fold))

    print('Complete')

        



