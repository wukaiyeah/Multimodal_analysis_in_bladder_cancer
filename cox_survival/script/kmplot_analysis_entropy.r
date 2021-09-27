#!/usr/bin/R
##---This script aims to conduct survival analysis
##--packages preparation
# install.packages('survival')
library('survival')
# BiocManager::install('survminer')
library('survminer') # for drawing
library('dplyr')
library('tibble')
library('latex2exp')
##--environment setting
setwd("/home/wukai/Multimodal_analysis_in_bladder_cancer/cox_survival")

##--load  data table
feature_table <- read.csv('../FeatureAssociations/multimodal_data_entropy.csv', header = TRUE, sep = ',')

surv_table = read.csv('activated_features_with_clinical_info.csv', header = TRUE, sep = ',')
surv_table = surv_table[,c(1,274:277)]
colnames(surv_table)[1] = 'case_id'
surv_table = left_join(surv_table, feature_table, by = 'case_id' )

##-- load filtered feature for overall survival
surv.table <-cbind(surv_table[,4:5], surv_table[9])
colnames(surv.table)[3] <- 'feature'
surv.table <- surv.table[order(surv.table$feature, decreasing = FALSE),]

# make level table
case.num <-nrow(surv.table)
level.table <- data.frame(level_1 = c(rep('low', 1), rep('high', case.num-1)))
for(i in 2:(case.num-1)){
  level.table <- cbind(level.table, c(rep('low', i), rep('high', case.num-i)))
}
colnames(level.table) <- paste('level', 1:(case.num-1), sep ='_')

# auto-find the perfect cutoff
time <- surv.table$Overall_survival_months
event <- c()
event[which(surv.table$Overall_survival_status == 'LIVING')] = 1
event[which(surv.table$Overall_survival_status == 'DECEASED')] = 2
event = as.numeric(event)
surv.table <- cbind(surv.table, level.table)

log.rank.pval.list <- c() 
for (level in colnames(level.table)){
  sfit <- survfit(as.formula(paste('Surv(time = time, event = event) ~', level)), data = surv.table)
  p.value <- round(surv_pvalue(sfit)$pval, digits = 4)
  log.rank.pval.list <- append(log.rank.pval.list, p.value)
}
names(log.rank.pval.list) <- colnames(level.table)
level.sig <- log.rank.pval.list[which(log.rank.pval.list < 0.05)]
print(level.sig)
###############################

# fitting survival curve
sfit <- survfit(Surv(time = time, event)~ level_41, data = surv.table)
summary(sfit)

# drawling plot
#windowsFonts(Calibri = 'Calibri')

ggsurv <- ggsurvplot(sfit,
                     data = surv.table,
                     conf.int=TRUE, 
                     # set line type
                     linetype = 1,
                     size = 3,                    
                     # set censor points
                     censor = TRUE,
                     censor.size = 8,
                     # set pvalue
                     pval = FALSE, # set later 
                     # set risk table 
                     risk.table = FALSE, 
                     risk.table.height = 0.27,
                     risk.table.fontsize = 14,
                     risk.table.pos = 'out',
                     risk.table.title = '',
                     # set title name
                     # title = 'Overall Survival Curve',
                     subtitle = 'WSI plasma Entropy',# nuclei_StDev_Intensity_MeanIntensity_Hematoxylin
                     xlab = 'Months',
                     ylab = 'Overall Survival',
                     legend.labs=c("high", "low"),
                     legend.title=c(""))


p.value <- data.frame(x = 20, y = 0.2, text = c('P = 0.009')) 
ggsurv$plot <- ggsurv$plot + geom_text(data = p.value, aes(x = x, y = y, label = text), 
                                       size = 15, show.legend = NA, color = '#2F4554')

ggsurv$plot <- ggsurv$plot +theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5 ),
        plot.subtitle = element_text(size = 55,hjust = 0.5,colour = '#2F4554'),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45),
        axis.title.y = element_text(size = 45),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA, size=1),
        legend.position = c(0.9,0.9))


ggsurv
ggsave("overall_wsi_plasma_entropy.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("overall_wsi_plasma_entropy.pdf", device = "pdf", width = 16, height = 12, dpi = 300)

