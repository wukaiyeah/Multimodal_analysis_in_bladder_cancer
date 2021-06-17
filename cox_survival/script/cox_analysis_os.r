# cox analysis with cam-activated features
library('dplyr')
library('tibble')
library('survival')
# BiocManager::install('survminer')
library('survminer') # for drawing
library('survcomp')

setwd('/media/wukai/AI_Team_03/Bladder_project/cox_survival')
# laod table
datatable = read.csv('activated_features_with_clinical_info.csv', header = TRUE, sep = ',',row.names = 1)

# standardized
datatable[,1:272]= scale(datatable[,1:272])

##---for overall
OStable = datatable[,c(1:272,275:276)]
OStable = na.omit(OStable)
surv.time <- OStable$Overall_survival_months
surv.event <- c()
surv.event[grep('LIVING',OStable$Overall_survival_status)] = 1
surv.event[grep('DECEASED',OStable$Overall_survival_status)] = 2

Cox.analysis <- function(feature){
  cox.result <- coxph(as.formula(paste('Surv(time = surv.time, surv.event)',feature,sep = '~')), data = OStable)
  cox.summary <- summary(cox.result)
  Coef <- cox.summary$coefficients[1, 1]
  HR <- cox.summary$coefficients[1, 2]
  P.val <- cox.summary$coefficients[1, 5]
  Upper <- cox.summary$conf.int[1, 4]
  Lower <- cox.summary$conf.int[1, 3]
  cox <- c(Coef, HR, Upper, Lower, P.val)
  return(cox)
}

coxres = data.frame(Cox.analysis(colnames(OStable)[1]))
for(feature in colnames(OStable)[2:272]){
  coxres = cbind(coxres, data.frame(Cox.analysis(feature)))
}
coxres = data.frame(t(coxres))
colnames(coxres) = c('Cox.coef', 'Cox.HR', 'Cox.Upper', 'Cox.Lower', 'Cox.pval')
rownames(coxres) = colnames(OStable)[1:272]
cox_res_sig = coxres[which(coxres$Cox.pval < 0.05),]
cox_res_sig = cox_res_sig[order(cox_res_sig$Cox.HR, decreasing = TRUE),]
#--filter

write.csv(cox_res_sig, '/media/wukai/AI_Team_03/Bladder_project/cox_survival/overall_cox_res.csv', quote = FALSE, row.names = TRUE)

