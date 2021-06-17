library('ggplot2')
library('tidyr')
library('pROC')
library('latex2exp')

setwd('G:/Bladder_project/mol_subtype_classify')
# load data
res = read.csv('./classifier/mol_subtype_pred_res_multinet.csv',
               header = TRUE, sep = ',', row.names = 1)

#define object to plot and calculate AUC
#rocobj <- roc(subtype$label, subtype$proba, smooth = TRUE, smooth.n = 100)
rocobj1 <- pROC::roc(res$mol_subtype, res$prob_net1)
auc_ci1 <- as.numeric(ci(rocobj1))
roc_table1 <- data.frame(FPR = 1-rocobj1$specificities, TPR = rocobj1$sensitivities)
roc_table1 <- roc_table1[order(roc_table1$TPR),]

rocobj2 <- pROC::roc(res$mol_subtype, res$prob_net2)
auc_ci2 <- as.numeric(ci(rocobj2))
roc_table2 <- data.frame(FPR = 1-rocobj2$specificities, TPR = rocobj2$sensitivities)
roc_table2 <- roc_table2[order(roc_table2$TPR),]

rocobj3 <- pROC::roc(res$mol_subtype, res$prob_net3)
auc_ci3 <- as.numeric(ci(rocobj3))
roc_table3 <- data.frame(FPR = 1-rocobj3$specificities, TPR = rocobj3$sensitivities)
roc_table3 <- roc_table3[order(roc_table3$TPR),]

# 
 

ci_text <- data.frame(x = 0.62, y = 0.065, text = c('95% confidence interval'))
box <- data.frame(x = c(0.23,0.23,1.0,1.0),
                  y = c(0.01,0.32,0.32,0.01))
rect = data.frame(x = c(0.34,0.34,0.39,0.39),
                  y = c(0.03,0.09,0.09,0.03))
line_table1 <- data.frame(x= c(0.25, 0.30),
                          y = c(0.22,0.22))
line_table2 <- data.frame(x= c(0.25, 0.30),
                          y = c(0.14,0.14))
line_table3 <- data.frame(x= c(0.25, 0.30),
                         y = c(0.06,0.06))


# 
ggplot()+
  geom_line(data = roc_table1, aes(x = FPR, y = TPR),colour = '#C23531', size = 3.5, alpha = 0.7)+
  geom_line(data = roc_table2, aes(x = FPR, y = TPR),colour = '#2F4554', size = 3.5, alpha = 0.7)+
  geom_line(data = roc_table3, aes(x = FPR, y = TPR),colour = '#61A0A8', size = 3.5, alpha = 0.7)+
  
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_polygon(data = box, aes(x=x , y=y), fill = 'white', color = '#666666',size = 1.5)+
  annotate('text', x = 0.6, y = 0.28, label = c('molecular subtype luminal vs. basal'), size = 13, color = '#666666')+
  annotate('text', x = 0.65, y = 0.21, label = TeX('Net1 ROC (Area=0.95(0.85-1.0))'),size = 13)+
  annotate('text', x = 0.63, y = 0.14, label = c('Net2 ROC (Area=0.85(0.65-1.0))'), size = 13)+
  annotate('text', x =  0.63, y =0.07, label = c('Net3 ROC (Area=0.83(0.62-1.0))'), size = 13)+
  geom_line(data = line_table1, aes(x = x, y = y),colour = '#C23531', size = 3.5, alpha = 0.7)+
  geom_line(data = line_table2, aes(x = x, y = y),colour =  '#2F4554', size = 3.5, alpha = 0.7)+ 
  geom_line(data = line_table3, aes(x = x, y = y),colour = '#61A0A8', size = 3.5, alpha = 0.7)+
    
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

ggsave("multi_net_roc_curve.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("multi_net_roc_curve_ci.pdf", device = "pdf", width = 16, height = 12, dpi = 300)

