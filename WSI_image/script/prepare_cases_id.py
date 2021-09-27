import os

if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/WSI_image'
    file_dir = os.path.join(base_dir, 'texture_features_radiomics.csv')
    OUT = open(os.path.join(base_dir, 'texture_features_radiomics1.csv'), 'w')
    with open(file_dir, 'r') as IN:
        # deal first line
        first_line = IN.readline()
        new_first_line = 'case_id,sample_id' + first_line
        OUT.write(new_first_line)

        # deal the rest lines
        for line in IN.readlines():
            sample_id = line.strip().split(',')[0]
            case_id = sample_id.split('_')[0]
            new_line = case_id+','+line
            OUT.write(new_line)
    OUT.close()