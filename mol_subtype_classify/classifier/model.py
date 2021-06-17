import torch
import torch.nn as nn
import torch.nn.functional as F


class Net(nn.Module):
    '''
    Convolutional Network for fused features as input
    '''
    def __init__(self, n_class, drop_out = 0.2):
        super(Net, self).__init__()
        self.conv1 = nn.Conv1d(1, 16, kernel_size = 5, stride=2) #16
        self.bn1 = nn.BatchNorm1d(16)
        self.conv2 = nn.Conv1d(16, 16, kernel_size = 5, stride=2)
        self.bn2 = nn.BatchNorm1d(16)

        self.conv3 = nn.Conv1d(1, 16, kernel_size = 5,stride=2)
        self.bn3 = nn.BatchNorm1d(16)
        self.conv4 = nn.Conv1d(16, 16, kernel_size = 5,stride=2)
        self.bn4 = nn.BatchNorm1d(16)
        self.conv5 = nn.Conv1d(16, 16, kernel_size = 5,stride=2)
        self.bn5 = nn.BatchNorm1d(16)
        
        self.fc1 = nn.Linear(1376, 128)
        self.fc2 = nn.Linear(128, 32)
        self.fc3 = nn.Linear(32, n_class)
        self.dropout = nn.Dropout(p=drop_out)

    def forward(self,x):
        x_1 = x[:,:,200:] # WSI_features: (b,1,1029)
        x_2 = x[:,:,0:200] # CT_features: (b,1,200)
        # for WSI
        out_1 = F.leaky_relu(self.bn1(self.conv1(x_1)))
        out_1 = F.leaky_relu(self.bn2(self.conv2(out_1)))
        # for CT
        out_2 = F.leaky_relu(self.bn3(self.conv3(x_2)))
        # fuse
        out = torch.cat((out_1, out_2), dim = 2) 
        # 
        out = F.leaky_relu(self.bn4(self.conv4(out)))
        out = F.leaky_relu(self.bn5(self.conv5(out)))
        # full connect
        out = out.view(out.size()[0],-1)
        out = F.leaky_relu(self.fc1(out))
        out = F.leaky_relu(self.fc2(out))
        out = F.leaky_relu(self.fc3(out))
        out = torch.sigmoid(out)
        return out



class Net2(nn.Module):
    '''
    Convolutional Network for WSI as input
    '''
    def __init__(self, n_class, drop_out = 0.2):
        super(Net2, self).__init__()
        self.conv1 = nn.Conv1d(1, 16, kernel_size = 5, stride=2) #16
        self.bn1 = nn.BatchNorm1d(16)
        self.conv2 = nn.Conv1d(16, 16, kernel_size = 5, stride=2)
        self.bn2 = nn.BatchNorm1d(16)

        self.conv3 = nn.Conv1d(1, 16, kernel_size = 5,stride=2)
        self.bn3 = nn.BatchNorm1d(16)
        self.conv4 = nn.Conv1d(16, 16, kernel_size = 5,stride=2)
        self.bn4 = nn.BatchNorm1d(16)
        self.conv5 = nn.Conv1d(16, 16, kernel_size = 5,stride=2)
        self.bn5 = nn.BatchNorm1d(16)
        
        self.fc1 = nn.Linear(976, 128)
        self.fc2 = nn.Linear(128, 32)
        self.fc3 = nn.Linear(32, n_class)
        self.dropout = nn.Dropout(p=drop_out)

    def forward(self,x):
        x_1 = x[:,:,200:] # WSI_features: (b,1,1029)
        # for WSI
        out_1 = F.leaky_relu(self.bn1(self.conv1(x_1)))
        out_1 = F.leaky_relu(self.bn2(self.conv2(out_1)))

        out = F.leaky_relu(self.bn4(self.conv4(out_1)))
        out = F.leaky_relu(self.bn5(self.conv5(out)))
        # full connect
        out = out.view(out.size()[0],-1)
        out = F.leaky_relu(self.fc1(out))
        out = F.leaky_relu(self.fc2(out))
        out = F.leaky_relu(self.fc3(out))
        out = torch.sigmoid(out)
        return out


class Net3(nn.Module):
    '''
    Convolutional Network for CT as input
    '''
    def __init__(self, n_class, drop_out = 0.2):
        super(Net3, self).__init__()
        self.conv1 = nn.Conv1d(1, 16, kernel_size = 5, stride=2) #16
        self.bn1 = nn.BatchNorm1d(16)
        self.conv2 = nn.Conv1d(16, 16, kernel_size = 5, stride=2)
        self.bn2 = nn.BatchNorm1d(16)

        self.conv3 = nn.Conv1d(1, 16, kernel_size = 5,stride=2)
        self.bn3 = nn.BatchNorm1d(16)
        self.conv4 = nn.Conv1d(16, 16, kernel_size = 5,stride=2)
        self.bn4 = nn.BatchNorm1d(16)
        self.conv5 = nn.Conv1d(16, 16, kernel_size = 5,stride=2)
        self.bn5 = nn.BatchNorm1d(16)
        
        self.fc1 = nn.Linear(352, 128)
        self.fc2 = nn.Linear(128, 32)
        self.fc3 = nn.Linear(32, n_class)
        self.dropout = nn.Dropout(p=drop_out)

    def forward(self,x):
        x_1 = x[:,:,200:] # WSI_features: (b,1,1029)
        x_2 = x[:,:,0:200] # CT_features: (b,1,200)

        # for CT
        out_2 = F.leaky_relu(self.bn3(self.conv3(x_2)))

        out = F.leaky_relu(self.bn4(self.conv4(out_2)))
        out = F.leaky_relu(self.bn5(self.conv5(out)))
        # full connect
        out = out.view(out.size()[0],-1)
        out = F.leaky_relu(self.fc1(out))
        out = F.leaky_relu(self.fc2(out))
        out = F.leaky_relu(self.fc3(out))
        out = torch.sigmoid(out)
        return out
