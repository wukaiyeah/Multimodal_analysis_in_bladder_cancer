library('dplyr')
library('pheatmap')
setwd('/media/wukai/AI_Team_03/Bladder_project')
datatable = read.csv('ct_wsi_merged_features.csv', header = TRUE, 
                     sep = ',', quote = '', row.names = 1)

# remove the feature which have 0 standard deviation
feature_names = names(which(apply(datatable[3:ncol(datatable)], 2, sd) > 1e-10))


p_values = c()
for(feature in feature_names){
    p.value = t.test(as.formula(paste(feature,'~grade_label')), 
                               data = datatable,
                               alternative = 'two.sided',
                               paried = FALSE)$p.value
    p_values = append(p_values, p.value)
}

adj_p = p.adjust(p_values, method = 'fdr')
res = data.frame(feature_name = feature_names,
                 p.val = p_values,
                 adj.p.val = adj_p)
res = res[order(res$adj.p.val, decreasing = FALSE),]
write.table(res, 'grade_pval_res.txt', quote = FALSE,sep = '\t', row.names = FALSE)

# heatmap
feat_val = t(datatable[,feature_names])
colnames(feat_val) = row.names(datatable)
colData = data.frame(class = datatable$grade_label,row.names = row.names(datatable))
pheatmap(feat_val,
         scale = 'row',
         annotation = colData,
         show_rownames = FALSE)
