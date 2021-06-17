# path analysis example
library("lavaan")
library('semPlot')
library('dplyr')

# refer to:
# http://www.understandingdata.net/2017/03/22/cfa-in-lavaan/
# set working directory
setwd('/media/wukai/AI_Team_03/Bladder_project')

# load & prepare datatable
datatable <- read.csv('ct_wsi_merged_features.csv', sep = ',', header =  TRUE)
colnames(datatable)[1] = 'case_id'
mol_subtype = read.csv('/media/wukai/AI_Team_03/Bladder_project/clinical_info/total_molecular_subtype.csv',
                       sep = ',', header = TRUE)
mol_subtype = mol_subtype[,c(1,3)]
datatable = left_join(mol_subtype, datatable, by = 'case_id')
datatable = na.omit(datatable)

# scale features
SCALE <- function(values){
  result <- scale(values, center = TRUE, scale = TRUE)
  return(as.numeric(result))
} # center

SCALE2 <- function(values){
  MAX = max(values)
  MIN = min(values)
  res = (values - MIN)/(MAX - MIN)
  return(as.numeric(res))
} # min/max scale

datatable[,c(5:ncol(datatable))] <- apply(datatable[,c(5:ncol(datatable))],2,SCALE2)

datatable[,5:ncol(datatable)] = scale(datatable[,5:ncol(datatable)])

##---feature list
# filter features, load res of t.test
feature_test_res = read.table('/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations/grade_pval_res.txt', header = TRUE, sep = '\t')
feature_test_res = feature_test_res[which(feature_test_res$adj.p.val < 0.05),]
feature_list = feature_test_res$feature_name
ct_feature = feature_list[grep('bladder|cancer', feature_list)][1:30]
wsi_feature = feature_list[grep('Mean_|Median_|StDev_|Texture_', feature_list)][1:30]

#--model construct
ct_feature_input = paste(ct_feature[-28], collapse = "+")
wsi_feature_input = paste(wsi_feature, collapse = "+") 

model  <- paste(paste('CT_Feature', ct_feature_input, sep = '=~'),
                paste('WSI_Feature', wsi_feature_input, sep = '=~'),
                'Pathology =~ grade_label + invas_label',
                'Molecular =~ mol_label',
                sep = '\n')

model  <- paste('WSI_Feature', wsi_feature_input, sep = '=~')

fit <- sem(model, data = datatable, check.gradient = FALSE)
fitMeasures(fit, c('cfi','tli','rmsea','srmr'))
summary(fit, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
mi <- modindices(fit)
mi <- mi[order(mi$mi, decreasing = TRUE),]
mi <- mi[which(mi$mi >= 2),]
mi <- mi[which(mi$op != '=~'),]

model2  <- paste(paste('CT_Feature', ct_feature_input, sep = '=~'),
                 paste('WSI_Feature', wsi_feature_input, sep = '=~'),
                 'Pathology =~ grade_label+invas_label',
                 'Molecular =~ mol_label',
                 paste(paste(mi$lhs, mi$op, mi$rhs), collapse = '\n'),
                 sep = '\n')

fit2 <- sem(model2, data = datatable, check.gradient = FALSE)
fitMeasures(fit2, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit2, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)


# Total model
model3 <- paste(
  # latent variable definitions
  paste('CT_Feature', ct_feature_input, sep = '=~'),
  paste('WSI_Feature', wsi_feature_input, sep = '=~'),
  'Pathology =~ grade_label+invas_label',
  'Molecular =~ mol_label',
  
  # regressions: latent path
  'Pathology ~ CT_Feature +  WSI_Feature',
  'CT_Feature ~ WSI_Feature',
  'Molecular ~ WSI_Feature + CT_Feature',
  
  #residual correlations
  paste(paste(mi$lhs, mi$op, mi$rhs), collapse = '\n'),
  sep = '\n')

fit3 <- sem(model3, data = datatable,check.gradient = FALSE)
fitMeasures(fit3, c('cfi','tli','rmsea','srmr','pvalue'))
# 
summary(fit3, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
# 路径图展示图
pdf('textw-set.pdf',16,16)
semPaths(fit3, what = 'paths', whatLabels = 'stand',layout = "tree2")
dev.off()
