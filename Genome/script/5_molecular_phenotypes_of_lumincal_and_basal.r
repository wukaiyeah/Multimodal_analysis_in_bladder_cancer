library('pheatmap')
library('tibble')
library('dplyr')
setwd('/media/wukai/AI_Team_03/Bladder_project/Genome')
# load tpm datatable
datatable = read.csv('total_tcga_mol_subtype_tpm.csv', sep = ',', header = TRUE)
datatable = datatable[,-c(1,3)]
colnames(datatable) = gsub('\\.', '-', colnames(datatable))
datatable = column_to_rownames(datatable,var = 'Gene_name')
# process tcga
subtype_info = read.csv('tcga_blca_molecular_subtype.csv', header = TRUE, sep = ',')
subtype_info = subtype_info[,c(1,48)]
colnames(subtype_info) = c('case_id', 'mRNA_cluster')
datatable_tcga = t(datatable[,61:ncol(datatable)])
datatable_tcga = rownames_to_column(as.data.frame(datatable_tcga), var = 'case_id')
datatable_tcga = inner_join(subtype_info, datatable_tcga, var = 'case_id')

colData_tcga = datatable_tcga[,1:2]
colData_test = data.frame(case_id = colnames(datatable)[1:60], mRNA_cluster = 'Test' )
colData = rbind(colData_test, colData_tcga)
colData = column_to_rownames(colData, var = 'case_id')
datatable_tcga = datatable_tcga[,-2]
datatable_tcga = t(column_to_rownames(datatable_tcga, var = 'case_id'))
datatable = cbind(datatable[,1:60], datatable_tcga)

# centered
CENTER = function(values){
  values = as.numeric(values)
  median_value = median(values)
  res = (values - median_value)/median_value
  
  return(res)
}

input = t(apply(datatable, 1, CENTER))
colnames(input) = colnames(datatable)
datatable = datatable[-c(15,16),]
pdf('tcga_mol_subtype_heatmap.pdf', 50, 10)
pheatmap(datatable, 
         scale  = 'row',
         annotation = colData,
         color = colorRampPalette(colors = c("blue","white","red"))(100),
         cluster_rows = FALSE,
         cluster_cols = TRUE)
dev.off()

# BJB061 = 'Neuronal', others = 'Luminal'
need_id = read.csv('/media/wukai/AI_Team_03/Bladder_project/clinical_info/case_id_info.csv',sep = ',', header = TRUE)
need_id = data.frame(case_id = need_id[,1])
colData = inner_join(need_id, rownames_to_column(colData,var = 'case_id'), by = 'case_id')
colData$mRNA_cluster[1:24] = 'Luminal'
colData$mRNA_cluster[23] = 'Neuronal'
colData$mol_label[grep('Luminal', colData$mRNA_cluster)] = 0
colData$mol_label[grep('Basal', colData$mRNA_cluster)] = 1
colData$mol_label[grep('Neuronal', colData$mRNA_cluster)] = 2
# 
write.csv(colData, '/media/wukai/AI_Team_03/Bladder_project/clinical_info/total_molecular_subtype.csv', quote = FALSE, row.names = FALSE)
