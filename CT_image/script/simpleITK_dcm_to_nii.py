import os
import sys
import glob
import SimpleITK as sitk
import numpy as np


def dcm_to_nii(file_dir, output_dir):
    assert os.path.exists(file_dir), 'Can not find %s'%(file_dir) 
    if len(glob.glob(os.path.join(file_dir,'*'))) > 20: # file with more than 20 image slices will be transform into nii
        file_id = file_dir.split('/')[-1]
        print('process file id %s'%(file_id))
        series_ids = sitk.ImageSeriesReader.GetGDCMSeriesIDs(file_dir)
        assert series_ids,  "ERROR: given directory dose not a DICOM series."
        
        series_file_names = sitk.ImageSeriesReader.GetGDCMSeriesFileNames(file_dir, series_ids[0])
        series_reader = sitk.ImageSeriesReader()
        series_reader.SetFileNames(series_file_names)
        try:
            image = series_reader.Execute()
            sitk.WriteImage(image, output_dir)

            if os.path.getsize(output_dir) < 10000: #文件过小就删除
                os.remove(output_dir)
        except:
            print('PASS: some thing wrong in file %s'%(file_id))


if __name__ == '__main__':
    base_dir = '/media/wukai/DATA1/TCGA-BLCA_images'
    source_dir = '/media/wukai/DATA1/TCGA-BLCA_images/TCGA-BLCA'
    output = '/media/wukai/DATA1/TCGA-BLCA_images/TCGA-BLCA_images'
    if not os.path.exists(output):
        os.mkdir(output)
    # get total cases id
    cases_id = [case_id for case_id in os.listdir(source_dir) if os.path.isdir(os.path.join(source_dir, case_id))]
    for case_id in cases_id:
        images_dir = []
        sub_ids = os.listdir(os.path.join(source_dir, case_id))
        for sub_id in sub_ids:
            images_dir += glob.glob(os.path.join(source_dir, case_id+'/'+sub_id+'/*'))
        assert len(images_dir) != 0, 'There is no image file in %s'%(case_id)
        for i, image_dir in enumerate(images_dir):
            output_dir = os.path.join(os.path.join(output,case_id+'_%d.nii.gz'%(i)))
            dcm_to_nii(image_dir, output_dir) # transform into nifti file
    