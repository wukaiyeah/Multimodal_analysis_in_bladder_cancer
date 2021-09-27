svs_path = "/share/service04/wukai/WSI_image/WSI_beijing"
cut_length = 19
import os, shutil, slide, tiles
""" import os, shutil, slide, tiles
for root, dirs, files in os.walk(svs_path, topdown=False):
    for name in files:
        if os.path.splitext(name)[1] == '.svs':
            shutil.move(os.path.join(root, name), os.path.join(svs_path, name[:cut_length]+".svs"))
        # print(os.path.join(root, name))
    # for name in dirs:
        # print(os.path.join(root, name)) """
# test_file = "TCGA-2F-A9KO-01A-01"
# num_slide,_ = slide.get_training_slides()
# 该函数打开一个切片，返回切片对象，无其他动作
# slide.open_slide(test_file) 
# 该函数将svs转换成jpg等场景格式并调用系统函数展示出来，除此之外无其他动作
# slide.show_slide("F:\\project\\multimodal\\pathology\\TCGA-BLCA\\tissue_slide_images\\TCGA-2F-A9KO-01A-01.svs")
# 该函数显示指定路径下文件的信息，除此之外无其他动作
# slide.slide_info()
# 该函数计算svs的一些统计指标并画图
# slide.slide_stats()
# 该函数将指定索引范围的svs转换成jpg等常用格式，jpg被scale down，由scale_factor参数控制缩放幅度，文件路径在slide文件里面设置
# slide.training_slide_range_to_images(0,76)
slide.training_slide_range_to_images(0,31)

# slide.training_slide_range_to_images(36,38)

# 该函数读取jpg文件并从每个文件tile出50个细胞成分最多的tile
for files in os.listdir(svs_path):
    if files == "filter":
        continue
    tiles.summary_and_tiles(files)

