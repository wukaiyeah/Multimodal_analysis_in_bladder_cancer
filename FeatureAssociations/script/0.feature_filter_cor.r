##--feature filter to remove the redundance
library('tidyr')
library('tibble')
library('corrplot')
library('pheatmap')

setwd('/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations')
total_feat = read.csv('/media/wukai/AI_Team_03/Bladder_project/ct_wsi_merged_features.csv', header = TRUE, sep = ',', row.names = 1)
wsi_feat = total_feat[,203:ncol(total_feat)] # WSI feat
# remove the feature with std == 0
wsi_std = apply(wsi_feat, 2, sd) 
wsi_feat = wsi_feat[,which(wsi_std > 10e-10)]

##-correlation
corr.matrix = cor(wsi_feat) 

# pheatmap(corr.matrix, 
#          cluster_rows = TRUE,
#          cluster_cols = TRUE,
#          file = 'total_wsi_feature_cor_heatmap.pdf',
#          width = 36,
#          height = 36)

##--process matrix into data.frame
corr.matrix = as.data.frame(corr.matrix)
corr.matrix$feat1 = rownames(corr.matrix)
corr_table = gather(corr.matrix, 1:(ncol(corr.matrix)-1),key = 'feat2', value = 'cor')

##--filter corr
corr_table = corr_table[which(corr_table$cor != 1),]
high_corr_table = corr_table[which(abs(corr_table$cor) > 0.7),]

write.csv(high_corr_table, 'high_corr_table.csv', quote = FALSE, row.names = FALSE)