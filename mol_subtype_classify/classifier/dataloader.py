from torch.utils.data import DataLoader, Dataset


class MyDataset(Dataset):
    def __init__(self, loader):
        self.features = loader[0]
        self.target = loader[1]

    def __getitem__(self, index):
        x_input = self.features[index]
        y_output = self.target[index]
        return x_input, y_output

    def __len__(self):
        return len(self.target)