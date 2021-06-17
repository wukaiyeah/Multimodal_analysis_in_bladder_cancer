##--draw plot for 
library(ggplot2)
library(latex2exp)

setwd('G:/Bladder_project/FeatureAssociations')
##-load data
feature_table = read.csv('G:/Bladder_project//ct_wsi_merged_features.csv', header = TRUE, sep = ',', row.names = 1)


##--load the block 1 data
cluster = read.csv('./output/halla_cluster1_asso.csv', header = TRUE, sep = ',')
feature_names = unique(c(cluster$X_features, cluster$Y_features))

#-scatter plot and cor.test

input_table = feature_table[,c('Mean_nuclei_Texture_Correlation_Hematoxylin_3_00_256',"cancer_firstorder_TotalEnergy")]
colnames(input_table) = c('nuclei_mean_Texture_CORH3', 'cancer_firstorder_TE')
input_table$cancer_firstorder_TE = log10(input_table$cancer_firstorder_TE)

corRes = cor.test(input_table[,1], input_table[,2])
p.value = corRes$p.value
cor = round(corRes$estimate,3)
confint = round(corRes$conf.int, 3)- cor
anno_text1 = TeX('$R = 0.537\\pm$0.113')
anno_text2 = 'P < 0.001'

rect = data.frame(x = c(0.33,0.33,0.53,0.53),
                  y = c(8.6,9.3,9.3,8.6))

##-plot
ggplot(data = input_table, aes(x = nuclei_mean_Texture_CORH3, y = cancer_firstorder_TE),)+
  geom_point(color = '#C23531', size = 8, alpha = 0.8)+
  geom_smooth(method = lm,color = '#2F4554',fill = '#2F4554', alpha = 0.1)+
  geom_polygon(data = rect, aes(x=x , y=y), fill = NA, color = '#2F4554',size = 1)+
  annotate('text', x = 0.43, y = 9.1, label = anno_text1, 
           size = 12, color = '#2F4554')+
  annotate('text', x = 0.43, y = 8.8, label = anno_text2, 
           size = 12, color = '#2F4554', hjust = 0.95)+
  labs(y =  'log(cancer_firstorder_TE)')+
  theme_bw()+
  theme(plot.title = element_text(size = 55, hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =30),
        axis.title.x = element_text(size = 45, color = '#2F4554'),
        axis.title.y = element_text(size = 45, color = '#2F4554'),
        legend.title = element_text(size = 25, color = '#2F4554', hjust = 0.5),
        legend.text = element_text(size = 25, color = '#2F4554', hjust = 0.5),
        legend.background = element_rect(fill = NA, color = '#2F4554', size = 1.2),
        legend.key = element_rect(fill = NA, colour = NA),
        legend.position = c(0.15,0.81))

ggsave('cor_scatter_plot1.pdf', device = 'pdf', width = 16, height = 12, dpi = 300)
ggsave('cor_scatter_plot1.jpg', device = 'jpeg', width = 16, height = 12, dpi = 300)


#-scatter plot 2 and cor.test
input_table = feature_table[,c('StDev_nuclei_AreaShape_Compactness',"cancer_shape_MeshVolume")]
colnames(input_table) = c('nuclei_std_Areashape_CPT', 'cancer_shape_MV')
input_table$cancer_shape_MV = log10(input_table$cancer_shape_MV)

corRes = cor.test(input_table[,1], input_table[,2])
p.value = corRes$p.value
cor = round(corRes$estimate,3)
confint = round(corRes$conf.int, 3)- cor
anno_text1 = TeX('$R = -0.477\\pm$ 0.124')
anno_text2 = 'P < 0.001'

rect = data.frame(x = c(1.8,1.8,2.6,2.6),
                  y = c(4.8,5.5,5.5,4.8))

##-plot
ggplot(data = input_table, aes(x = nuclei_std_Areashape_CPT, y = cancer_shape_MV))+
  geom_point(color = '#C23531', size = 8, alpha = 0.8)+
  geom_smooth(method = lm, color = '#2F4554', fill = '#2F4554', alpha = 0.1)+
  geom_polygon(data = rect, aes(x=x , y=y), fill = NA, color = '#2F4554',size = 1)+
  annotate('text', x = 2.2, y = 5.3, label = anno_text1, 
           size = 12, color = '#2F4554')+
  annotate('text', x = 2.2, y = 5.0, label = anno_text2, 
           size = 12, color = '#2F4554', hjust = 1)+
  labs(y =  'log(cancer_shape_MV)')+
  theme_bw()+
  theme(plot.title = element_text(size = 55, hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =30),
        axis.title.x = element_text(size = 45, color = '#2F4554'),
        axis.title.y = element_text(size = 45, color = '#2F4554'),
        legend.title = element_text(size = 25, color = '#2F4554', hjust = 0.5),
        legend.text = element_text(size = 25, color = '#2F4554', hjust = 0.5),
        legend.background = element_rect(fill = NA, color = '#2F4554', size = 1.2),
        legend.key = element_rect(fill = NA, colour = NA),
        legend.position = c(0.15,0.81))

ggsave('cor_scatter_plot2.pdf', device = 'pdf', width = 16, height = 12, dpi = 300)
ggsave('cor_scatter_plot2.jpg', device = 'jpeg', width = 16, height = 12, dpi = 300)
