library('ggplot2')
library('tidyr')
library('pROC')
library('latex2exp')

setwd('/media/wukai/Data01/Multimodal_analysis_in_bladder_cancer/mol_subtype_classify')
# load data
res = read.csv('classifier/mol_subtype_pred_net0_fold0.csv',
         header = TRUE, sep = ',', row.names = 1)

#define object to plot and calculate AUC
#rocobj <- roc(subtype$label, subtype$proba, smooth = TRUE, smooth.n = 100)
rocobj <- pROC::roc(res$mol_subtype, res$prob)
auc_ci <- as.numeric(ci(rocobj))

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

#for 95% CI bootstrap line
ciobj <- ci.se(rocobj, specificities=seq(0, 1, 0.01),conf.level=0.95, boot.n=2000)
ciobj <- as.data.frame(ciobj)
ciobj$specificities <- 1 - as.numeric(row.names(ciobj))
colnames(ciobj) <- c('TPR_low', 'TPR','TPR_high', 'FPR')
rownames(ciobj) <- NULL
ci_table <- ciobj[order(ciobj$FPR),]
# 

ci_text <- data.frame(x = 0.65, y = 0.065, text = c('95% confidence interval'))
box <- data.frame(x = c(0.32,0.32,1.02,1.02),
                  y = c(0.01,0.32,0.32,0.01))
rect = data.frame(x = c(0.34,0.34,0.39,0.39),
                  y = c(0.04,0.1,0.1,0.04))
line_table <- data.frame(x= c(0.34, 0.39),
                         y = c(0.15,0.15))

# 
ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour = '#C23531', size = 3.5)+
  geom_ribbon(data = ci_table, aes(x = FPR, ymin = TPR_low, ymax = TPR_high),fill='#C23531',alpha = .2)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_polygon(data = box, aes(x=x , y=y), fill = 'white', color = '#666666',size = 1.5)+
  geom_polygon(data = rect, aes(x=x , y=y), fill = '#C23531',alpha = .15)+
  annotate('text', x = 0.67, y = 0.28, label = c('Binary classification'),size = 13)+
  annotate('text', x = 0.67, y = 0.21, label = c('molecular subtype luminal vs. basal'), size = 13, color = '#666666')+
  annotate('text', x =  0.70, y =0.14, label =  TeX('ROC (Area=0.89(0.75-1.0))'), size = 13)+
  geom_text(data = ci_text, aes(x = x, y = y, label = text), size = 13,  show.legend = NA)+
  geom_line(data = line_table, aes(x = x, y = y),colour = '#C23531', size = 3.5)+
  
  labs(y = 'Sensitivity', x = '1 - specificity')+
  theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45, color = '#2F4554'),
        axis.title.y = element_text(size = 45.,color = '#2F4554'),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA, size=1),
        legend.position = '')

ggsave("roc_curve_ci_fold0.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("roc_curve_ci_fold0.pdf", device = "pdf", width = 16, height = 12, dpi = 300)

