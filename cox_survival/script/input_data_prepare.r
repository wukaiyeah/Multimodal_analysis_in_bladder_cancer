# prepare cox analysis input
library('dplyr')


setwd('/media/wukai/AI_Team_03/Bladder_project/cox_survival/')

# load activated features
luminal_activated = read.csv('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/CAM/luminal_activated_feature.csv',
                             sep = ',', header = TRUE)
basal_activated = read.csv('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/CAM/basal_activated_feature.csv',
                           sep = ',', header = TRUE)
activated_features = unique(sort(c(luminal_activated$features, basal_activated$features)))

# load feature table
feature_table = read.csv('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/classifier/dataset_for_classifer.csv',
                         sep = ',', header = TRUE,row.names = 1)
activated_feature_table = feature_table[,activated_features]
activated_feature_table = rownames_to_column(activated_feature_table,var = 'case_id')
# load clinical info 
clinical_info = read.table('/media/wukai/AI_Team_03/Bladder_project/clinical_info/cBioPortal.blca.tcga.pub.2017.clinical.data.tsv', 
                           sep = '\t', header = TRUE, quote = '')
clinical_info = clinical_info[,c(2,24,25,70,71)]
colnames(clinical_info) = c('case_id', 'Disease_free_months','Disease_free_status' ,'Overall_survival_months', 'Overall_survival_status')

beijing_info = read.csv('/media/wukai/AI_Team_03/Bladder_project/clinical_info/beijing_patient_followup_info.csv',
                        header = TRUE, sep = ',', quote = '', fileEncoding = 'GBK')
beijing_info = beijing_info[,c(1,11,10,13,12)]
colnames(beijing_info) = c('case_id', 'Disease_free_months','Disease_free_status' ,'Overall_survival_months', 'Overall_survival_status')
clinical_info = rbind(beijing_info, clinical_info)
clinical_info = clinical_info[!duplicated(clinical_info),]
# merge feature & clinical table
datatable = inner_join(activated_feature_table, clinical_info, by = 'case_id')
datatable = column_to_rownames(datatable, var = 'case_id')

write.csv(datatable, 'activated_features_with_clinical_info.csv', quote = FALSE, row.names = TRUE)
