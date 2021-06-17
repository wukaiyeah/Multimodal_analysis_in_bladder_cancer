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
    return parser.parse_args()

def data_split(x_features, y_label):
    # split case
    SS=StratifiedShuffleSplit(n_splits=1,test_size=0.20,random_state=args.seed)
    for train_index, test_index in SS.split(x_features, y_label):
        X_train, X_test = x_features[train_index], x_features[test_index]#训练集对应的值
        y_train, y_test = y_label[train_index], y_label[test_index]#类别集对应的值
        print("X_train:",len(X_train))
        print("X_test:",len(X_test))
    return  X_test, y_test, test_index

if __name__ == '__main__':
    # add parser
    args = gen_parser()

    # load dataset
    datatable = pd.read_csv('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/classifier/dataset_for_classifer.csv',index_col=0, header=0)
    y_label = np.array(datatable['mol_label']).astype(np.float32)
    x_features = np.array(datatable.iloc[:,2:])
    x_features = scale(x_features).astype(np.float32)
    # split data
    X_test, y_test, test_index = data_split(x_features, y_label)

    # initialize model
    net1 = torch.load('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/classifier/net_2.pth')
    net2 = torch.load('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/classifier/net2_0.pth')
    net3 = torch.load('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/classifier/net3_0.pth')

    # for net1 model test
    net1.eval()
    input_test = torch.tensor(X_test).unsqueeze(1)
    if torch.cuda.is_available():
        input_test = input_test.cuda()
    output_test = net1(input_test)
    proba_net1 = output_test.squeeze().detach().cpu().numpy()
    accuracy = accuracy_score(y_test, [1 if pre > 0.5 else 0 for pre in output_test])
    auc = roc_auc_score(y_test, output_test.squeeze().tolist())
    print('Current test acc %.2f auc %.2f '%(accuracy,auc))

    # save output
    pred_res = pd.DataFrame(np.stack((y_test, output_test.squeeze().detach().cpu().numpy()), axis = 1))
    pred_res.columns = ['mol_subtype','prob']
    pred_res.index = datatable.index[test_index]
    pred_res.to_csv('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/classifier/mol_subtype_pred_res.csv')

    # for net2 model test
    net2.eval()
    input_test = torch.tensor(X_test).unsqueeze(1)
    if torch.cuda.is_available():
        input_test = input_test.cuda()
    output_test = net2(input_test)
    proba_net2 = output_test.squeeze().detach().cpu().numpy()
    accuracy = accuracy_score(y_test, [1 if pre > 0.5 else 0 for pre in output_test])
    auc = roc_auc_score(y_test, output_test.squeeze().tolist())
    print('Current test acc %.2f auc %.2f '%(accuracy,auc))


    # for net3 model test
    net3.eval()
    input_test = torch.tensor(X_test).unsqueeze(1)
    if torch.cuda.is_available():
        input_test = input_test.cuda()
    output_test = net3(input_test)
    proba_net3 = output_test.squeeze().detach().cpu().numpy()
    accuracy = accuracy_score(y_test, [1 if pre > 0.5 else 0 for pre in output_test])
    auc = roc_auc_score(y_test, output_test.squeeze().tolist())
    print('Current test acc %.2f auc %.2f '%(accuracy,auc))

    # save output
    pred_res = pd.DataFrame(np.stack((y_test, proba_net1, proba_net2, proba_net3), axis = 1))
    pred_res.columns = ['mol_subtype','prob_net1', 'prob_net2', 'prob_net3']
    pred_res.index = datatable.index[test_index]
    pred_res.to_csv('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/classifier/mol_subtype_pred_res_multinet.csv')

