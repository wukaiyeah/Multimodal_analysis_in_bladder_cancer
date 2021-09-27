test_path = "F:\\project\\multimodal\\pathology\\TCGA-BLCA\\tiles_jpg\\TCGA-DK-AA6W-01A-01.svs"
num_imshow = 9

from skimage import io
import matplotlib.pyplot as plt
import numpy as np
import os
i = 0
# 本程序计算空白区域占整个tile的比例，变量为ratio，如果大于0.75，则显示出该图片
reference = np.full((1024, 1024, 3), 230, dtype=int)
for files in os.listdir(test_path):
    moon = io.imread(test_path + "\\" +files)
    compare = (moon > reference).sum(axis = 2)
    ratio = sum(sum(compare))/3145729
    if ratio > 0.75:
        i = i + 1
        plt.subplot(3,3,i)
        plt.imshow(moon)
        if i==9:
            break
plt.show()