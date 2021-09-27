import os
import glob
import json
import SimpleITK as sitk
import numpy as np

def mask_label_trans(label_dir):
    file_id = label_dir.split('/')[-1].replace('.nii.gz', '')
    print('process %s'%file_id)
    image_sitk = sitk.ReadImage(label_dir)
    array = sitk.GetArrayFromImage(image_sitk)
    array[np.where(array == 2)] = 1
    origin = image_sitk.GetOrigin()
    spacing = image_sitk.GetSpacing()
    direction = image_sitk.GetDirection()

    new_sitk = sitk.GetImageFromArray(array)
    new_sitk.SetOrigin(origin)
    new_sitk.SetSpacing(spacing)
    new_sitk.SetDirection(direction)
    sitk.WriteImage(new_sitk, label_dir.replace('.nii.gz','.label1.nii.gz'))


if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03'
    source_dir = '/media/wukai/AI_Team_03'

    labels_dir = [label_dir for label_dir in glob.glob(os.path.join(source_dir, '*.nii.gz')) if '_0000' not in label_dir]
    print('Find %d label files'%len(labels_dir))
    for label_dir in labels_dir:
        mask_label_trans(label_dir)
