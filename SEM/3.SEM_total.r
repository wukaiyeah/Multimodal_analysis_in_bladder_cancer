# path analysis example
library("lavaan")
library('semPlot')

# refer to:
# http://www.understandingdata.net/2017/03/22/cfa-in-lavaan/
# set working directory
setwd('/media/wukai/AI_Team_03/Bladder_project')

# load & prepare datatable
datatable <- read.csv('ct_wsi_merged_features.csv', sep = ',', header =  TRUE,row.names = 1)
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

datatable[,c(3:ncol(datatable))] <- apply(datatable[,c(3:ncol(datatable))],2,SCALE)

##---feature list
# filter features, load res of t.test
feature_test_res = read.table('grade_pval_res.txt', header = TRUE, sep = '\t')
feature_test_res = feature_test_res[which(feature_test_res$adj.p.val < 0.05),]
feature_list = feature_test_res$feature_name
ct_feature = feature_list[grep('bladder|cancer', feature_list)][1:30]
wsi_feature = feature_list[grep('Mean_|Median_|StDev_|Texture_', feature_list)][1:30]

##--model construct
ct_feature_input = paste(ct_feature, collapse = "+")
wsi_feature_input = paste(wsi_feature, collapse = "+") 

model  <- paste(paste('CT_Feature', ct_feature_input, sep = '=~'),
                paste('WSI_Feature', wsi_feature_input, sep = '=~'),
                'Pathology =~ grade_label + invas_label',
                sep = '\n')

fit <- sem(model, data = datatable, check.gradient = FALSE)
fitMeasures(fit, c('cfi','tli','rmsea','srmr'))
summary(fit, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
mi <- modindices(fit)
mi <- mi[order(mi$mi, decreasing = TRUE),]
mi <- mi[which(mi$mi >= 2),]

model2  <- paste(paste('CT_Feature', ct_feature_input, sep = '=~'),
                paste('WSI_Feature', wsi_feature_input, sep = '=~'),
                'Pathology =~ grade_label + invas_label',
                paste(paste(mi$lhs, mi$op, mi$rhs), collapse = '\n'),
                sep = '\n')

fit2 <- sem(model2, data = datatable, check.gradient = FALSE)
fitMeasures(fit2, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit2, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)


# Total model
model3 <- paste(
  # measurement model
  paste('CT_Feature', ct_feature_input, sep = '=~'),
  paste('WSI_Feature', wsi_feature_input, sep = '=~'),
  'Pathology =~ grade_label + invas_label',
  
  # latent path 
  'Pathology ~ WSI_Feature',
  'Pathology ~ CT_Feature',
  'CT_Feature ~ WSI_Feature',
  # Covariance
  paste(paste(mi$lhs, mi$op, mi$rhs), collapse = '\n'),
  sep = '\n')

fit3 <- sem(model3, data = datatable,check.gradient = FALSE)
fitMeasures(fit3, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit3, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
# 路径图展示图
pdf('textw-set.pdf',16,16)
semPaths(fit3, what = 'paths', whatLabels = 'stand',layout = "tree2")
dev.off()
