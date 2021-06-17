##--draw plot for 
library(ggplot2)

setwd('/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations')
##-load data
datatable = read.table('grade_pval_res.txt', sep = '\t', header = TRUE)

##- filter and precess
resSig = datatable[which(datatable$adj.p.val < 0.05),]
resSig$t.val = abs(resSig$t.val) #
resSig = resSig[order(resSig$t.val, decreasing = TRUE),]
resSig = resSig[which(resSig$t.val > 5),]
# sample index
ct_idx = sort(sample(grep('bladder|cancer', resSig$feature_name), 7, replace = FALSE)) # 10 14 26 27 30 35 36
wsi_idx = sort(sample(grep('plasm|nuclei', resSig$feature_name), 8, replace = FALSE)) # 2  5 12 18 20 21 24 37

resNeed = resSig[c(2,5,12, 18, 20, 21, 24, 37, 10, 14, 26, 27, 30, 35, 36),] 
resNeed$log.adj.p =  -log10(resNeed$adj.p.val)
resNeed = resNeed[order(resNeed$t.val, decreasing = FALSE),]
type = c()
type[grep('bladder|cancer', resNeed$feature_name)] = 'CT Feature'
type[grep('plasm|nuclei', resNeed$feature_name)] = 'WSI Feature'
resNeed$type = type

resNeed$feature_name = c('plasm_mean_texture_ASMH',# [1] "Mean_plasm_Texture_AngularSecondMoment_Hematoxylin_3_00_256"
                         'bladder_glszm_SAE', # [2] "bladder_glszm_SmallAreaEmphasis" 
                         'bladder_firstorder_MEAN',# [3] "bladder_firstorder_Mean"
                         'bladder_glcm_IMC1',# [4] "bladder_glcm_Imc1"   
                         'bladder_firstorder_90P',# [5] "bladder_firstorder_90Percentile" 
                         'bladder_firstorder_RMS',# [6] "bladder_firstorder_RootMeanSquared"  
                         'plasm_std_intensity_LQIH',# [7] "StDev_plasm_Intensity_LowerQuartileIntensity_Hematoxylin"   
                         'nuclei_std_ASA',# [8] "StDev_nuclei_AreaShape_Area"
                         'nuclei_std_texture_SVH',# [9] "StDev_nuclei_Texture_SumVariance_Hematoxylin_3_00_256"   
                         'plasm_std_PN',# [10] "StDev_plasm_Parent_nuclei" 
                         'bladder_glcm_IMC2',# [11] "bladder_glcm_Imc2" 
                         'plasm_mean_texture_DVH',# [12] "Mean_plasm_Texture_DifferenceVariance_Hematoxylin_3_00_256" 
                         'bladder_glcm_COR',# [13] "bladder_glcm_Correlation"  
                         'plasm_med_intensity_MIH',# [14] "Median_plasm_Intensity_MaxIntensity_Hematoxylin"
                         'plasm_mean_texture_CORH'# [15] "Mean_plasm_Texture_Correlation_Hematoxylin_3_00_256"
                          )
resNeed = resNeed[-6,]
resNeed$feature_name = factor(resNeed$feature_name, levels = resNeed$feature_name)


point1 = data.frame(x = 4.98, y = 12.74)
point2 = data.frame(x = 4.98, y = 12.24)
rect = data.frame(x = c(6.2,6.2,8.8,8.8),
                  y = c(1.1,2.8,2.8,1.1))

##-plot
ggplot(data = resNeed)+
  geom_point(aes(x = t.val, y = feature_name, size = log.adj.p, color = type))+
  scale_size(name = '-log(adj.P)', range=c(3,15))+
  scale_colour_manual(values = c('#C23531', '#2F4554'))+
  labs(
        x = '|t-value|',
       col = 'MultiModel')+
  geom_polygon(data = rect, aes(x=x , y=y), fill = NA, color = '#2F4554',size = 1)+
  annotate('text', x = 7.5, y = 2, label = 'Welch t-test on\n High/Low Grade Samples', 
           size = 12, color = '#2F4554')+
  xlim(4.8, 9)+
  theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =30),
        axis.title.x = element_text(size = 45, color = '#2F4554', face = 'italic'),
        axis.title.y = element_blank(),
        legend.title = element_text(size = 30, color = '#2F4554', hjust = 0.5),
        legend.text = element_text(size = 30, color = '#2F4554', hjust = 0.5),
        legend.background = element_rect(fill = NA, color = '#2F4554', size = 1.2),
        legend.key = element_rect(fill = NA, colour = NA),
        legend.position = c(0.2,0.75))+
  geom_point(data = point1, aes(x = x, y = y), size = 8, color = '#C23531')+
  geom_point(data = point2, aes(x = x, y = y), size = 8, color = '#2F4554')
  
ggsave('t_test_bubble_plot.pdf', device = 'pdf', width = 16, height = 12, dpi = 300)
ggsave('t_test_bubble_plot.jpg', device = 'jpeg', width = 16, height = 12, dpi = 300)
