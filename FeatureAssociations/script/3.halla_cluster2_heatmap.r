library('dplyr')
library('pheatmap')
library('tidyr')
library('tibble')
library('ggplot2')
library('ggtree')
library('aplot')
library('RColorBrewer')
library('remotes')

setwd('/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations')
##--load association data
asso = read.csv('./output/halla_cluster2_asso.csv', header = TRUE, sep = ',')
qvalue = asso[,c(1,2,5)]
asso = asso[,1:3]
#--process qvalue
qvalues = c()
qvalues[which(qvalue$q.values < 0.05)] = 'Y'
qvalues[which(qvalue$q.values >= 0.05)] = 'N'

qvalue$q.values = qvalues
qvalue = spread(qvalue, key = Y_features, value  = q.values)
qvalue = column_to_rownames(qvalue, var = 'X_features')


##--process asso
asso = spread(asso, key = Y_features, value  = association)
asso = column_to_rownames(asso, var = 'X_features')

col_alias = c( 
'plasm_std_Texture_DVH3',# [1] "StDev_plasm_Texture_DifferenceVariance_Hematoxylin_3_00_256"     
'plasm_std_Texture_IDMH3'# [2] "StDev_plasm_Texture_InverseDifferenceMoment_Hematoxylin_3_00_256"
               )
row_alias = c(
 'bladder_firstorder_10P', # [1] "bladder_firstorder_10Percentile"                 
 'bladder_firstorder_90P',# [2] "bladder_firstorder_90Percentile"                 
 'bladder_firstorder_Mean', # [3] "bladder_firstorder_Mean"                         
 "bladder_firstorder_Median" ,# [4] "bladder_firstorder_Median"                       
 "bladder_glcm_COR" ,# [5] "bladder_glcm_Correlation"                        
 "bladder_glcm_Imc1",# [6] "bladder_glcm_Imc1"                               
 "bladder_glcm_Imc2", # [7] "bladder_glcm_Imc2"                               
 "bladder_gldm_DE",# [8] "bladder_gldm_DependenceEntropy"                  
 "bladder_glrlm_RE" ,# [9] "bladder_glrlm_RunEntropy"                        
 "bladder_glszm_LALGLE" , # [10] "bladder_glszm_LargeAreaLowGrayLevelEmphasis"     
 "cancer_firstorder_Energy",# [11] "cancer_firstorder_Energy"                        
  "cancer_firstorder_TE",# [12] "cancer_firstorder_TotalEnergy"                   
 "cancer_glcm_Idmn" ,# [13] "cancer_glcm_Idmn"                                
 "cancer_glcm_Idn" , # [14] "cancer_glcm_Idn"                                 
 "cancer_gldm_DNU" ,# [15] "cancer_gldm_DependenceNonUniformity"             
 "cancer_gldm_GLNU", # [16] "cancer_gldm_GrayLevelNonUniformity"              
 "cancer_gldm_LDHGLE",# [17] "cancer_gldm_LargeDependenceHighGrayLevelEmphasis"
 "cancer_gldm_SDLGLE", # [18] "cancer_gldm_SmallDependenceLowGrayLevelEmphasis" 
  "cancer_glrlm_GLNU",# [19] "cancer_glrlm_GrayLevelNonUniformity"             
 "cancer_glrlm_LRHGLE",# [20] "cancer_glrlm_LongRunHighGrayLevelEmphasis"       
  "cancer_glrlm_RLNU",# [21] "cancer_glrlm_RunLengthNonUniformity"             
  "cancer_glszm_GLNU",# [22] "cancer_glszm_GrayLevelNonUniformity"             
  "cancer_glszm_LAE",# [23] "cancer_glszm_LargeAreaEmphasis"                  
  "cancer_glszm_LAHGLE",# [24] "cancer_glszm_LargeAreaHighGrayLevelEmphasis"     
  "cancer_glszm_LALGLE",# [25] "cancer_glszm_LargeAreaLowGrayLevelEmphasis"      
  "cancer_glszm_SZNU",# [26] "cancer_glszm_SizeZoneNonUniformity"              
 "cancer_glszm_ZV",# [27] "cancer_glszm_ZoneVariance"                       
  "cancer_shape_LAL",# [28] "cancer_shape_LeastAxisLength"                    
  "cancer_shape_MaAL",# [29] "cancer_shape_MajorAxisLength"                    
  "cancer_shape_M2DDC", # [30] "cancer_shape_Maximum2DDiameterColumn"            
  "cancer_shape_M2DDR",# [31] "cancer_shape_Maximum2DDiameterRow"               
  "cancer_shape_M2DDS",# [32] "cancer_shape_Maximum2DDiameterSlice"             
  "cancer_shape_M3DD",# [33] "cancer_shape_Maximum3DDiameter"                  
  "cancer_shape_MV",# [34] "cancer_shape_MeshVolume"                         
  "cancer_shape_MiAL",# [35] "cancer_shape_MinorAxisLength"                    
  "cancer_shape_SA",# [36] "cancer_shape_SurfaceArea"                        
  "cancer_shape_SVR",# [37] "cancer_shape_SurfaceVolumeRatio"                 
  "cancer_shape_VV"# [38] "cancer_shape_VoxelVolume"
  )

rownames(asso) = row_alias
colnames(asso) = col_alias

rownames(qvalue) = row_alias
colnames(qvalue) = col_alias

##-ggplot
# cluster row and column
clustRow = hclust(dist(asso))
clustCol = hclust(dist(t(asso)))
# order
asso_orderd = asso[clustRow$order, clustCol$order]
orderRow = rownames(asso_orderd)
orderCol = colnames(asso_orderd)

qvalue_orderd = qvalue[clustRow$order, clustCol$order]

# reform
asso_orderd$CT = rownames(asso_orderd)
asso_input = gather(asso_orderd, 1:ncol(asso_orderd)-1, key = 'WSI', value = 'asso')
asso_input$CT = factor(asso_input$CT, levels = orderRow)
asso_input$WSI = factor(asso_input$WSI, levels = orderCol)

orderRow = rownames(asso_input)
orderCol = colnames(asso_input)
phc = ggtree(clustRow, root.position = 20) + layout_dendrogram()


qvalue_orderd$CT = rownames(qvalue_orderd)
qvalue_input = gather(qvalue_orderd, 1:ncol(qvalue_orderd)-1, key = 'WSI', value = 'qvalue')
#--merge
asso_input$qvalue = qvalue_input$qvalue

asso_input = asso_input[which(asso_input$WSI !='plasm_std_Texture_DEH3'),]
# plot
p = ggplot(asso_input)+
  geom_tile(aes(x = CT, y = WSI, fill = asso))+
  scale_fill_gradient2(low = "#4575B4", mid = 'white', high = "#D73027", midpoint = 0,n.breaks = 5)+
  annotate('text', x = -0.5, y = 0.6, label = 'WSI Features', size = 14, angle = 90, vjust = 1, hjust = 0, color = '#2F4554')+
  annotate('text', x = 20, y = 1.5, label = 'Densely Associated Block 2', size = 45, color = '#2F4554',alpha = 0.5)+
  scale_y_discrete(position = 'right')+
  labs(y = 'WSI Features', x = 'CT Features', fill = 'Association')+
  theme_void()+
  theme(plot.title = element_text(size = 55, hjust = 0.5),
        axis.text.x = element_text(size = 25, angle = 90, hjust = 1, vjust = 0.5, color = '#2F4554'),
        axis.text.y = element_text(size = 25, hjust = 1, vjust = 0.5, color = '#2F4554'),
        axis.title.x = element_text(size = 45, color = '#2F4554'),
        axis.title.y = element_blank(),
        legend.title = element_text(size =25, color = '#2F4554', hjust = 0.5),
        legend.text = element_text(size = 25, color = '#2F4554', hjust = 0.5),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA),
        legend.key.height = unit(1.8,'cm'),
        legend.position = 'right')

p = p +geom_point(aes(x = CT, y = WSI, color = qvalue), size = 5, shape = 21, fill = 'white',alpha = 0.5, show.legend = FALSE)+
  scale_color_manual(values = c(NA,'#2F4554'))

#p = p + annotate('text', x = 25, y = 12, label = 'Densely Associated\n Block 1', size = 45, color = '#2F4554',alpha = 0.5)

#p = p %>% insert_top(phc, height  = 0.3) 

ggsave('heatmap_cluster2.pdf',plot = p, device = 'pdf', width  = 32, height = 9, dpi = 300)



