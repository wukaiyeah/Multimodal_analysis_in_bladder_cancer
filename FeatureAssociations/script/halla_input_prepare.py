import os
import pandas as pd

if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations'
    input_file = '/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations/ct_wsi_nonredunt_features.csv'

    datatable = pd.read_csv(input_file, header=0, index_col=0)
    datatable = datatable.T

    CT_features_names = [name for name in datatable.index if 'bladder' in name or 'cancer' in name]
    CT_features_table = datatable.loc[CT_features_names,:]
    CT_features_table.to_csv(os.path.join(base_dir, 'X_ct_features.txt'), sep = '\t', index=True, header=True)

    WSI_features_names = datatable.index[202:]
    WSI_features_table = datatable.loc[WSI_features_names,:]
    WSI_features_table.to_csv(os.path.join(base_dir, 'Y_wsi_features.txt'), sep = '\t', index=True, header=True)


    pass


