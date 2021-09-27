'''
filter CT images based on the tumor and bladder segmentation
    去除癌组织体积超过膀胱的样本，这些样本临床研究意义不大
'''
import os
import glob
import SimpleITK as sitk
import numpy as np

def filter_images(label_dir):
    '''
    过滤掉癌组织体积大于膀胱正常组织的样本
    检查segmentation文件中，标签1（正常组织）和标签2（癌组织）个数，将 label_2 >= label_1文件设为False
    '''
    label_sitk = sitk.ReadImage(label_dir)
    array = sitk.GetArrayFromImage(label_sitk)
    label1_num = len(np.where(array == 1)[0])
    label2_num = len(np.where(array == 2)[0])

    if label1_num >= 2 * label2_num:
        return True
    else:
        return False


if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/CT_image'
    source_dir = '/media/wukai/AI_Team_03/Bladder_project/CT_image/images_nii'
    image_files = glob.glob(os.path.join(source_dir, '*_0000.nii.gz'))
    file_ids = [file_dir.split('/')[-1].replace('_0000.nii.gz','') for file_dir in image_files]
    label_files = [os.path.join(source_dir, file_id+'.nii.gz') for file_id in file_ids]
    for label_file in label_files: # check
        assert os.path.exists(label_file), "Can't find File %s"%label_file
    
    with open(os.path.join(base_dir, 'filtered_sample.txt'),'w') as OUT:
        for label_file in label_files:
            sample_id = label_file.split('/')[-1].replace('.nii.gz', '').split('_')[0]
            res = filter_images(label_file)
            OUT.write(sample_id+'\t'+str(res)+'\n')

    pass

