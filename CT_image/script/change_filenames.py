import os
import glob
import shutil

if __name__ == '__main__':
    base_dir = '/media/wukai/AI_Team_03/Bladder_project/CT_image/images_nii'


    file_names_dict = {}
    with open(os.path.join(base_dir, 'target_sample_id.txt'), 'r') as IN:
        file_names = IN.readlines()
        for item in file_names:
            patientid = item.strip().split()[0]
            studyid = item.strip().split()[1]
            file_names_dict[studyid] = patientid
    #files_list1 = glob.glob(os.path.join(base_dir, '*.label1.nii.gz'))
    files_list1 = [file_dir for file_dir in glob.glob(os.path.join(base_dir, '*.nii.gz')) if ('_0000' not in file_dir) and ('label1' not in file_dir)]

    for key in file_names_dict.keys():
        ori_file_dir = [file_dir for file_dir in files_list1 if key in file_dir][0]
        print(key+' -> '+file_names_dict[key])
        new_file_dir = os.path.join('/media/wukai/AI_Team_03/Bladder_project', file_names_dict[key]+'_0.nii.gz')
        shutil.copyfile(ori_file_dir, new_file_dir )
