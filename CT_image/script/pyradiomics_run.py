import os
import glob
import json

def prepare_files_dir(source_dir):
    images_dir = glob.glob(os.path.join(source_dir, '*_0000.nii.gz'))
    files_dir_list = []
    for image_dir in images_dir:
        label_dir = image_dir.replace('_0000','_label1')
        assert os.path.exists(label_dir),'Can not find lable file %s'%label_dir
        files_dir_list.append([image_dir, label_dir])
    return files_dir_list


def prepare_files_dir2(source_dir):
    images_dir = glob.glob(os.path.join(source_dir, '*_0000.nii.gz'))
    files_dir_list = []
    for image_dir in images_dir:
        label_dir = image_dir.replace('_0000','')
        assert os.path.exists(label_dir),'Can not find lable file %s'%label_dir
        files_dir_list.append([image_dir, label_dir])
    return files_dir_list


def write_input_csv(files_dir_list, csv_dir):
    with open(csv_dir,'w') as OUT:
        OUT.write('Image,Mask\n')
        for i in range(len(files_dir_list)):
            OUT.write(files_dir_list[i][0]+','+files_dir_list[i][1]+'\n')

    
def run(csv_dir, para_dir, output_dir):
    cmd = 'pyradiomics %s --p %s --jobs %d -o %s -f csv' % ( csv_dir, para_dir, 10, output_dir)
    os.system(cmd)


# pyradiomics <path/to/input> -o results.csv -f csv


if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/CT_image'
    param1_dir = '//media/wukai/AI_Team_03/Bladder_project/CT_image/script/Params.yaml'
    param2_dir = '/media/wukai/AI_Team_03/Bladder_project/CT_image/script/Params_label2.yaml'
    source_dir1 = '/media/wukai/AI_Team_03/Bladder_project/CT_image/images_nii'


    files_dir_list = prepare_files_dir(source_dir1)
    print('Find %d files'%(len(files_dir_list)))
    csv_dir1 = os.path.join(base_dir, 'file_dir1.csv')
    write_input_csv(files_dir_list, csv_dir1)

    files_dir_list2 = prepare_files_dir2(source_dir1)
    print('Find %d files'%(len(files_dir_list2)))
    csv_dir2 = os.path.join(base_dir, 'file_dir2.csv')
    write_input_csv(files_dir_list2, csv_dir2)
    
    run(csv_dir1, param1_dir, os.path.join(base_dir, 'total_radiomics_label1.csv'))
    run(csv_dir2, param2_dir, os.path.join(base_dir, 'total_radiomics_label2.csv'))