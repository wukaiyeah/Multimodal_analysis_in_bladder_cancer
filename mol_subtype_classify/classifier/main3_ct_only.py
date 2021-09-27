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
from model import Net3
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
    parser.add_argument('--fold', type=int, default=0, help='[0,1,2,3,4]')
    return parser.parse_args()

def data_split(x_features, y_label,args):
    # split case
    SS=StratifiedShuffleSplit(n_splits=5,test_size=0.20,random_state=args.seed)
    split_idx_list = list(SS.split(x_features, y_label))
    train_index = split_idx_list[args.fold][0]
    test_index = split_idx_list[args.fold][1]

    X_train, X_test = x_features[train_index], x_features[test_index]#训练集对应的值
    y_train, y_test = y_label[train_index], y_label[test_index]#类别集对应的值
    return X_train, X_test, y_train, y_test

if __name__ == '__main__':
    # add parser
    args = gen_parser()

    # load dataset
    # load dataset
    data_dir = '/media/wukai/Data01/Multimodal_analysis_in_bladder_cancer/mol_subtype_classify/classifier'
    datatable = pd.read_csv(os.path.join(data_dir,'dataset_for_classifer.csv'),index_col=0, header=0)
    
    y_label = np.array(datatable['mol_label']).astype(np.float32)
    x_features = np.array(datatable.iloc[:,2:])
    x_features = scale(x_features).astype(np.float32)
    # split data
    X_train, X_test, y_train, y_test = data_split(x_features, y_label,args)
    # dataloader
    dataset = MyDataset([X_train,y_train])
    dataloader = DataLoader(dataset, batch_size=4, shuffle=True, num_workers=0, drop_last =False)

    # initialize model
    net = Net3(n_class = 1) # 二元分类
    torch.manual_seed(args.seed)#为CPU设置随机种子 
    if torch.cuda.is_available(): 
        torch.cuda.manual_seed(args.seed)#为当前GPU设置随机种子 
        torch.cuda.manual_seed_all(args.seed)#为所有GPU设置随机种子
    #nn.init.normal_(tensor, mean=0.0, std=1.0)
    for n in net.modules():
        if isinstance(n, (nn.Conv1d, nn.Linear)):
            nn.init.xavier_uniform_(n.weight)

    train_params = list(filter(lambda p: p.requires_grad, net.parameters()))
    criterion = nn.BCELoss()
    optimizer = optim.Adam(params = train_params, lr=args.lr, weight_decay=args.wd, betas=(0.99,0.999))
    scheduler = lr_scheduler.MultiStepLR(optimizer, args.lr_decay_steps, gamma = 0.1) # 调整学习率
    best_acc = 0.
    best_auc = 0.
    for epoch in range(args.epochs):
        net.train()
        start_epoch = time.time()
        running_loss = 0.
        for i,batch in enumerate(dataloader):
            start_batch = time.time()
            if len(batch[0].shape) == 2:
                batch[0] = batch[0].unsqueeze(1) # (b, 1229) -> (b,1,1229)
            if torch.cuda.is_available():
                x_input, target = batch[0].cuda(), batch[1].cuda()
                net = net.cuda()

            optimizer.zero_grad()
            output = net(x_input)
            loss = criterion(output.squeeze(), target)
            loss.backward()
            running_loss += loss.tolist()
            optimizer.step()

        # test
        net.eval()
        input_test = torch.tensor(X_test).unsqueeze(1)
        if torch.cuda.is_available():
            input_test = input_test.cuda()
        output_test = net(input_test)
        accuracy = accuracy_score(y_test, [1 if pre > 0.5 else 0 for pre in output_test])
        auc = roc_auc_score(y_test, output_test.squeeze().tolist())

        if np.mean([accuracy,auc]) > np.mean([best_acc,best_auc]):
            best_acc = accuracy
            best_auc = auc
            torch.save(net, os.path.join(data_dir,'net_ct_fold%s.pth'%args.fold))

        print('Epoch %d elapse %.2fs average loss %.2f Current test acc %.2f auc %.2f Best test acc %.2f auc %.2f'%(epoch, time.time() - start_epoch, running_loss/20,accuracy,auc, best_acc, best_auc ))
        scheduler.step()


