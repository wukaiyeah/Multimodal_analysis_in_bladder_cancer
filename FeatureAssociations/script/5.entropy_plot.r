library('ggplot2')
library('dplyr')
library('tidyr')
library('BioQC')
library('tibble')

setwd('/home/wukai/Multimodal_analysis_in_bladder_cancer/FeatureAssociations')

#-- load CT & WSI data
ct_wsi_feature = read.csv('../ct_wsi_merged_features.csv', header = TRUE, row.names = 1)
target_feature_table = select(ct_wsi_feature, c('grade_label','bladder_firstorder_Entropy','Median_nuclei_Texture_Entropy_Hematoxylin_3_03_256','StDev_plasm_Texture_SumEntropy_Hematoxylin_3_01_256'))
colnames(target_feature_table) = c('grade_label','CT','WSI Nuclei','WSI Plasma')
input_table = gather(target_feature_table, feature, value, -grade_label)
input_table$grade_label[which(input_table$grade_label == 0)] = 'Low-Grade'
input_table$grade_label[which(input_table$grade_label == 1)] = 'High-Grade'
input_table$grade_label = factor(input_table$grade_label, levels = c('Low-Grade','High-Grade'))

#-- load RNAseq data
rnaseq_table = read.csv('/home/wukai/Multimodal_analysis_in_bladder_cancer/Genome/total_rnaseq_tpm.csv',header = TRUE, row.names = 1)
need_id = read.csv('/home/wukai/Multimodal_analysis_in_bladder_cancer/mol_subtype_classify/classifier/dataset_for_classifer.csv', header = TRUE, row.names = 1)
colnames(rnaseq_table) = gsub('\\.','-',colnames(rnaseq_table))
rnaseq_table = select(rnaseq_table,rownames(need_id))
rnaseq_table = rnaseq_table[which(rowSums(rnaseq_table) != 0),]
#write.csv(rnaseq_table, 'participate_rnaseq_tpm.csv',quote = FALSE,row.names = FALSE)
entropyDiversity = data.frame(entropy = BioQC::entropyDiversity(rnaseq_table))
entropyDiversity = left_join(rownames_to_column(entropyDiversity,var = 'case_id'),rownames_to_column(select(ct_wsi_feature, 'grade_label'), var = 'case_id'), by = 'case_id')
t.test(formula = entropy ~ grade_label, data = entropyDiversity)

input_entropy = column_to_rownames(entropyDiversity, var = 'case_id')
input_entropy$feature = 'Transcriptome'
input_entropy$grade_label[which(input_entropy$grade_label == 0)] = 'Low-Grade'
input_entropy$grade_label[which(input_entropy$grade_label == 1)] = 'High-Grade'
input_entropy = input_entropy[,c(2,3,1)]
colnames(input_entropy) = colnames(input_table)
input_table = rbind(input_table,input_entropy)
input_table$feature = factor(input_table$feature, levels = c('WSI Plasma','CT','Transcriptome','WSI Nuclei'))

colnames(entropyDiversity)[2] = 'Transcriptome'
total_entropy_table = left_join(entropyDiversity, rownames_to_column(target_feature_table, var = 'case_id'), by = 'case_id')
total_entropy_table = total_entropy_table[,c(1,2,5,6,7)]
write.csv(total_entropy_table, 'multimodal_data_entropy.csv', row.names = FALSE, quote = FALSE)

##-plot
ggplot(data = input_table, aes(y = value, fill = grade_label))+
  geom_boxplot(width = 0.14, size = 0.5,color = 'black')+
  scale_fill_manual(values = c('#2F4554','#C23531'))+
  facet_grid(~feature, scales='free_y')+
  annotate('text', x = 0, y = 12.5, label = 'P < 0.001', 
           size = 12, color = '#2F4554')+
  labs(y = 'Infomation Entropy')+
  theme_bw()+
  theme(plot.title = element_text(size = 55, hjust = 0.5),
        strip.text.x = element_text(size=40, color = '#2F4554'),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size =30),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 45, color = '#2F4554'),
        legend.title = element_blank(),
        legend.text = element_text(size = 30, color = '#2F4554', hjust = 0.5),
        legend.background = element_rect(fill = NA, color = '#2F4554', size = 1.2),
        legend.key = element_rect(fill = NA, colour = NA),
        legend.key.width = unit(2,'cm'),
        legend.position = c(0.12,0.85))

ggsave('entropy_boxplot.pdf', device = 'pdf', width = 16, height = 12, dpi = 300)
ggsave('entropy_boxplot.jpg', device = 'jpeg', width = 16, height = 12, dpi = 300)
