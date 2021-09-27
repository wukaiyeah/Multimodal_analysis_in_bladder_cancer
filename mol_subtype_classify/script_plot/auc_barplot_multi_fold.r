library('ggplot2')
library('tidyr')
library('latex2exp')

setwd('/media/wukai/Data01/Multimodal_analysis_in_bladder_cancer/mol_subtype_classify')
# load data
res = read.csv('classifier/AUC_fold_res.csv',
               header = TRUE, sep = ',', row.names = 1)
colnames(res) = paste('fold',seq(0,4),sep = '_')
res = as.data.frame(t(res))
res$fold = paste('fold',seq(0,4),sep = '_')
# plot
ggplot(res, aes(x = fold , y = auc, fill = fold))+
  geom_bar(stat = 'identity',position = 'dodge', width = 0.5, size = 1)+
  scale_fill_manual(values = c('#C23531', '#2F4554','#61A0A8','#D48265','#91C7AE'))+
  geom_text(aes(x = fold, y = auc, label = auc), size = 15, vjust = 0, color = '#546570')+
  geom_text(x = 4.3, y = 0.96, label = 'Average AUC: 0.84', size = 15, vjust = 0, color = '#2F4554')+
  labs(y = 'AUC', 
       x = '5-Fold Cross Test')+
  ylim(0,1.0)+
  theme_bw()+
  theme(plot.title = element_text(size = 55, hjust = 0.5 ),
        axis.text.x = element_text(size =40),
        axis.text.y = element_text(size =40),
        axis.title.x = element_text(size = 40),
        axis.title.y = element_text(size = 40),
        #axis.ticks.x = element_blank(),
        panel.grid.major.x=element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 40),
        legend.background = element_blank(),
        legend.position = '',
        legend.key = element_rect(fill = NA, colour = NA, size=1)
  )

ggsave("roc_five_fold_cross.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("roc_five_fold_cross.pdf", device = "pdf", width = 16, height = 12, dpi = 300)
