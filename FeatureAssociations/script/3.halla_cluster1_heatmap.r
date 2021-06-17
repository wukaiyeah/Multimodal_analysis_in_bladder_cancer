library('dplyr')
library('pheatmap')
library('tidyr')
library('tibble')
library('ggplot2')
library('ggtree')
library('aplot')
library('RColorBrewer')
library('remotes')

setwd('F:/Bladder_project/FeatureAssociations')
##--load association data
asso = read.csv('./output/halla_cluster1_asso.csv', header = TRUE, sep = ',')
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

# filter WSI_features
# distance = dist(t(asso), method = "euclidean")
# fit <- hclust(distance, method="ward.D")
# groups <- cutree(fit, k=4)
# groups_1 = names(which(groups == 1))
# groups_2 = names(which(groups == 2))
# groups_3 = names(which(groups == 3))
# groups_4 = names(which(groups == 4))
# asso_part = asso[,c(groups_1, groups_4)]

# pheatmap(asso,
#          show_colnames  = TRUE,
#          show_rownames = TRUE,
#          number_color = '#2F4554',
#          fontsize = 20,
#          border_color = NA,
#          width = 16,
#          height = 12)
col_alias = c( 
  'nuclei_mean_AreaShape_Area',# [1] "Mean_nuclei_AreaShape_Area"                                       
  'nuclei_mean_AreaShape_CPT',# [2] "Mean_nuclei_AreaShape_Compactness"                                
  'nuclei_mean_Intensity_IIH',# [3] "Mean_nuclei_Intensity_IntegratedIntensity_Hematoxylin"            
  'nuclei_mean_Intensity_MIH',# [4] "Mean_nuclei_Intensity_MaxIntensity_Hematoxylin"                   
  'nuclei_mean_Radial_FADH1',# [5] "Mean_nuclei_RadialDistribution_FracAtD_Hematoxylin_1of4"          
  'nuclei_mean_Radial_ZPH4',# [6] "Mean_nuclei_RadialDistribution_ZernikePhase_Hematoxylin_4_0"      
  'nuclei_mean_Texture_CORH3',# [7] "Mean_nuclei_Texture_Correlation_Hematoxylin_3_00_256"             
  'plasm_mean_AreaShape_EXT',# [8] "Mean_plasm_AreaShape_Extent"                                      
  'plasm_mean_Intensity_MIH',# [9] "Mean_plasm_Intensity_MaxIntensity_Hematoxylin"                    
  'plasm_mean_Intensity_SIEH',# [10] "Mean_plasm_Intensity_StdIntensityEdge_Hematoxylin"                
  'plasm_mean_Texture_CORH3',# [11] "Mean_plasm_Texture_Correlation_Hematoxylin_3_00_256"              
  'nuclei_med_AreaShape_Area',# [12] "Median_nuclei_AreaShape_Area"                                     
  'nuclei_med_AreaShape_CPT',# [13] "Median_nuclei_AreaShape_Compactness"                              
  'nuclei_med_AreaShape_zernike2',# [14] "Median_nuclei_AreaShape_Zernike_2_0"                              
  'nuclei_med_Intensity_IIH',# [15] "Median_nuclei_Intensity_IntegratedIntensity_Hematoxylin"          
  'nuclei_med_Intensity_MDH',# [16] "Median_nuclei_Intensity_MassDisplacement_Hematoxylin"             
  'nuclei_med_Intensity_MIH',# [17] "Median_nuclei_Intensity_MaxIntensity_Hematoxylin"                 
  'nuclei_med_Radial_FAH1',# [18] "Median_nuclei_RadialDistribution_FracAtD_Hematoxylin_1of4"        
  'nuclei_med_Radial_ZMH6',# [19] "Median_nuclei_RadialDistribution_ZernikeMagnitude_Hematoxylin_6_0"
  'nuclei_med_Radial_ZMH8',# [20] "Median_nuclei_RadialDistribution_ZernikeMagnitude_Hematoxylin_8_0"
  'nuclei_med_Texture_CORH3',# [21] "Median_nuclei_Texture_Correlation_Hematoxylin_3_00_256"           
  'plasm_med_AreaShape_CPT',# [22] "Median_plasm_AreaShape_Compactness"                               
  'plasm_med_AreaShape_EXT',# [23] "Median_plasm_AreaShape_Extent"                                    
  'plasm_med_Intensity_MIH',# [24] "Median_plasm_Intensity_MaxIntensity_Hematoxylin"                  
  'plasm_med_Intensity_MIEH',# [25] "Median_plasm_Intensity_MinIntensityEdge_Hematoxylin"              
  'plasm_med_Texture_CORH3',# [26] "Median_plasm_Texture_Correlation_Hematoxylin_3_00_256"            
  'nuclei_std_AreaShape_Area',# [27] "StDev_nuclei_AreaShape_Area"                                      
  'nuclei_std_AreaShape_CPT',# [28] "StDev_nuclei_AreaShape_Compactness"                               
  'nuclei_std_AreaShape_FF',# [29] "StDev_nuclei_AreaShape_FormFactor"                                
  'nuclei_std_Intensity_IIH',# [30] "StDev_nuclei_Intensity_IntegratedIntensity_Hematoxylin"           
  'nuclei_std_Intensity_LQIH',# [31] "StDev_nuclei_Intensity_LowerQuartileIntensity_Hematoxylin"        
  'nuclei_std_Intensity_SIEH',# [32] "StDev_nuclei_Intensity_StdIntensityEdge_Hematoxylin"              
  'nuclei_std_Radial_FAH3',# [33] "StDev_nuclei_RadialDistribution_FracAtD_Hematoxylin_3of4"         
  'nuclei_std_Radial_RCV4',# [34] "StDev_nuclei_RadialDistribution_RadialCV_Hematoxylin_4of4"        
  'nuclei_std_Radial_ZMH2',# [35] "StDev_nuclei_RadialDistribution_ZernikeMagnitude_Hematoxylin_2_2" 
  'nuclei_std_Radial_ZMH8',# [36] "StDev_nuclei_RadialDistribution_ZernikeMagnitude_Hematoxylin_8_0" 
  'nuclei_std_Radial_ZPH4',# [37] "StDev_nuclei_RadialDistribution_ZernikePhase_Hematoxylin_4_0"     
  'nuclei_std_Texture_CORH3',# [38] "StDev_nuclei_Texture_Correlation_Hematoxylin_3_00_256"            
  'nuclei_std_Texture_IMH3',# [39] "StDev_nuclei_Texture_InfoMeas1_Hematoxylin_3_00_256"              
  'nuclei_std_Texture_SVH3',# [40] "StDev_nuclei_Texture_SumVariance_Hematoxylin_3_00_256"            
  'plasm_std_AreaShape_zernike8',# [41] "StDev_plasm_AreaShape_Zernike_8_8"                                
  'plasm_std_Intensity_LQUH',# [42] "StDev_plasm_Intensity_LowerQuartileIntensity_Hematoxylin"         
  'plasm_std_Intensity_SIEH',# [43] "StDev_plasm_Intensity_StdIntensityEdge_Hematoxylin"               
  'plasm_std_Texture_CORH3',# [44] "StDev_plasm_Texture_Correlation_Hematoxylin_3_00_256"             
  'plasm_std_Texture_DEH3',# [45] "StDev_plasm_Texture_DifferenceEntropy_Hematoxylin_3_00_256"       
  'plasm_std_Texture_IMH3',# [46] "StDev_plasm_Texture_InfoMeas1_Hematoxylin_3_00_256"               
  'plasm_std_Texture_SVH3'# [47] "StDev_plasm_Texture_SumVariance_Hematoxylin_3_00_256"
               )
row_alias = c(
'cancer_firstorder_EN',# [1] "cancer_firstorder_Energy"                   
'cancer_firstorder_TE',# [2] "cancer_firstorder_TotalEnergy"              
'cancer_gldm_DNU',# [3] "cancer_gldm_DependenceNonUniformity"        
'cancer_gldm_GLNU',# [4] "cancer_gldm_GrayLevelNonUniformity"         
'cancer_glrlm_GLNU',# [5] "cancer_glrlm_GrayLevelNonUniformity"        
'cancer_glrlm_RLNU',# [6] "cancer_glrlm_RunLengthNonUniformity"        
'cancer_glszm_GLNU',# [7] "cancer_glszm_GrayLevelNonUniformity"        
'cancer_glszm_LAE',# [8] "cancer_glszm_LargeAreaEmphasis"             
'cancer_glszm_LAHGLE',# [9] "cancer_glszm_LargeAreaHighGrayLevelEmphasis"
'cancer_glszm_SZNU',# [10] "cancer_glszm_SizeZoneNonUniformity"         
'cancer_glszm_ZV',# [11] "cancer_glszm_ZoneVariance"                  
'cancer_shape_LAL',# [12] "cancer_shape_LeastAxisLength"               
'cancer_shape_MaAL',# [13] "cancer_shape_MajorAxisLength"               
'cancer_shape_M2DDC',# [14] "cancer_shape_Maximum2DDiameterColumn"       
'cancer_shape_M2DDR',# [15] "cancer_shape_Maximum2DDiameterRow"          
'cancer_shape_M2DDS',# [16] "cancer_shape_Maximum2DDiameterSlice"        
'cancer_shape_M3DD',# [17] "cancer_shape_Maximum3DDiameter"             
'cancer_shape_MV',# [18] "cancer_shape_MeshVolume"                    
'cancer_shape_MiAL',# [19] "cancer_shape_MinorAxisLength"               
'cancer_shape_SA',# [20] "cancer_shape_SurfaceArea"                   
'cancer_shape_SVR',# [21] "cancer_shape_SurfaceVolumeRatio"            
'cancer_shape_VV'# [22] "cancer_shape_VoxelVolume" 
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
phc = ggtree(clustCol) + layout_dendrogram()
phr = ggtree(clustRow)

qvalue_orderd$CT = rownames(qvalue_orderd)
qvalue_input = gather(qvalue_orderd, 1:ncol(qvalue_orderd)-1, key = 'WSI', value = 'qvalue')
#--merge
asso_input$qvalue = qvalue_input$qvalue

asso_input = asso_input[which(asso_input$WSI !='plasm_std_Texture_DEH3'),]
# plot
p = ggplot(asso_input)+
  geom_tile(aes(x = WSI, y = CT, fill = asso))+
  scale_fill_gradient2(low = "#4575B4", mid = 'white', high = "#D73027", midpoint = 0,n.breaks = 5)+
  scale_y_discrete(position = 'right')+
  labs(x = 'WSI Features', y = 'CT Features', fill = 'Association')+
  theme(plot.title = element_text(size = 55, hjust = 0.5),
        axis.text.x = element_text(size = 25, angle = 90, hjust = 1, vjust = 0.5, color = '#2F4554'),
        axis.text.y = element_text(size = 25, color = '#2F4554'),
        axis.title.x = element_text(size = 45, color = '#2F4554'),
        axis.title.y = element_text(size = 45, color = '#2F4554'),
        legend.title = element_text(size =25, color = '#2F4554', hjust = 0.5),
        legend.text = element_text(size = 25, color = '#2F4554', hjust = 0.5),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA),
        legend.key.height = unit(4,'cm'),
        legend.position = 'right')

p = p +geom_point(aes(x = WSI, y = CT, color = qvalue), size = 5, shape = 21, fill = 'white',alpha = 0.5, show.legend = FALSE)+
  scale_color_manual(values = c(NA,'#2F4554'))

p = p + annotate('text', x = 25, y = 12, label = 'Densely Associated\n Block 1', size = 45, color = '#2F4554',alpha = 0.5)

p = p %>% insert_left(phr, width  = 0.05) %>%
            insert_top(phc, height = 0.08)
  

ggsave('heatmap_cluster1.pdf',plot = p, device = 'pdf', width  = 32, height = 16, dpi = 300)



