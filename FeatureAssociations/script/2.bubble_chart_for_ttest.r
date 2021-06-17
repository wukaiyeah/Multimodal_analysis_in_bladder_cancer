##--draw plot for 
library(ggplot2)

setwd('F:/Bladder_project/FeatureAssociations')
##-load data
datatable = read.table('grade_pval_res.txt', sep = '\t', header = TRUE)

##- filter and precess
resSig = datatable[which(datatable$adj.p.val < 0.05),]
resSig$t.val = abs(resSig$t.val) #
resSig = resSig[order(resSig$t.val, decreasing = TRUE),]

##--load the block 1 data
cluster = read.csv('./output/halla_cluster1_asso.csv', header = TRUE, sep = ',')
feature_names = unique(c(cluster$X_features, cluster$Y_features))

#- merge and filter
resSig_block1 = resSig[resSig$feature_name %in% feature_names,]

# sample index
ct_idx = sort(sample(grep('bladder|cancer', resSig_block1$feature_name), 6, replace = FALSE)) #  23 32 37 38 41 45
wsi_idx = sort(sample(grep('plasm|nuclei', resSig_block1$feature_name), 8, replace = FALSE)) # 2 11 15 16 33 34 48 55

resNeed = resSig_block1[c(2,11,15,16,23,32,33,34,37,38,41,45,48,55),] 
resNeed$log.adj.p =  -log10(resNeed$adj.p.val)
resNeed = resNeed[order(resNeed$t.val, decreasing = FALSE),]
type = c()
type[grep('bladder|cancer', resNeed$feature_name)] = 'CT Feature'
type[grep('plasm|nuclei', resNeed$feature_name)] = 'WSI Feature'
resNeed$type = type

resNeed$feature_name = c(
                         'nuclei_med_Radial_DFH1',# [1] "Median_nuclei_RadialDistribution_FracAtD_Hematoxylin_1of4"   
                         'plasm_med_Intensity_MIEH',# [2] "Median_plasm_Intensity_MinIntensityEdge_Hematoxylin"         
                         'cancer_glszm_SZNU',# [3] "cancer_glszm_SizeZoneNonUniformity"                          
                         'cancer_glszm_ZV',# [4] "cancer_glszm_ZoneVariance"                                   
                         'cancer_glrlm_RLNU',# [5] "cancer_glrlm_RunLengthNonUniformity"                         
                         'cancer_shape_M2DDS',# [6] "cancer_shape_Maximum2DDiameterSlice"                         
                         'nuclei_std_Texture_CORH3',# [7] "StDev_nuclei_Texture_Correlation_Hematoxylin_3_00_256"       
                         'nuclei_std_Radial_ZPH0',# [8] "StDev_nuclei_RadialDistribution_ZernikePhase_Hematoxylin_4_0"
                         'cancer_shape_SVR',# [9] "cancer_shape_SurfaceVolumeRatio"                             
                         'cancer_shape_M2DDR',# [10] "cancer_shape_Maximum2DDiameterRow"                           
                         'plasm_std_Intensity_LQIH',# [11] "StDev_plasm_Intensity_LowerQuartileIntensity_Hematoxylin"    
                         'nuclei_mean_Intensity_IIH',# [12] "Mean_nuclei_Intensity_IntegratedIntensity_Hematoxylin"       
                         'plasm_std_Texture_SVH3',# [13] "StDev_plasm_Texture_SumVariance_Hematoxylin_3_00_256"        
                         'plasm_mean_Texture_CORH'# [14] "Mean_plasm_Texture_Correlation_Hematoxylin_3_00_256"
)
resNeed = resNeed[-6,]
resNeed$feature_name = factor(resNeed$feature_name, levels = resNeed$feature_name)


point1 = data.frame(x = 6.4, y = 2.15)
point2 = data.frame(x = 6.4, y = 1.65)
rect = data.frame(x = c(1.9,1.9,6.1,6.1),
                  y = c(11.5,13.2,13.2,11.5))

##-plot
ggplot(data = resNeed)+
  geom_point(aes(x = t.val, y = feature_name, size = log.adj.p, color = type))+
  scale_size(name = '-log(adj.P)', range=c(8,20))+
  scale_colour_manual(values = c('#C23531', '#2F4554'))+
  labs(
    x = '|t-value|',
    col = 'MultiModel')+
  geom_polygon(data = rect, aes(x=x , y=y), fill = NA, color = '#2F4554',size = 1)+
  annotate('text', x = 3.95, y = 12.4, label = 'Welch t-test on\n High/Low Grade Samples', 
           size = 12, color = '#2F4554')+
  #xlim(4.8, 9)+
  theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5),
        axis.text.x = element_text(size =45, color = '#2F4554'),
        axis.text.y = element_text(size =35, color = '#2F4554'),
        axis.title.x = element_text(size = 45, color = '#2F4554', face = 'italic'),
        axis.title.y = element_blank(),
        legend.title = element_text(size = 30, color = '#2F4554', hjust = 0.5),
        legend.text = element_text(size = 30, color = '#2F4554', hjust = 0.5),
        legend.background = element_rect(fill = NA, color = '#2F4554', size = 1.2),
        legend.key = element_rect(fill = NA, colour = NA),
        legend.position = c(0.8,0.3))+
  geom_point(data = point1, aes(x = x, y = y), size = 8, color = '#C23531')+
  geom_point(data = point2, aes(x = x, y = y), size = 8, color = '#2F4554')

ggsave('t_test_bubble_plot.pdf', device = 'pdf', width = 16, height = 12, dpi = 300)
ggsave('t_test_bubble_plot.jpg', device = 'jpeg', width = 16, height = 12, dpi = 300)
