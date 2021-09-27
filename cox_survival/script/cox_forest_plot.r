##--draw forest plot
library('ggplot2')

setwd('/media/wukai/AI_Team_03/Bladder_project/cox_survival')
#--load data
datatable = read.csv('overall_cox_res.csv',header = TRUE, sep = ',')
colnames(datatable)[1] = 'feature'
feat_alias = c('bladder_firstorder_10P', 
                      'nuclei_med_areashape_MFD',
                      'plasm_mean_intensity_MDH',
                      'nuclei_std_intensity_MIH',
                      'nuclei_med_areashape_MAL',
                      'nuclei_med_areashape_PM',
                      'nuclei_med_intensity_IIH',
                      'nuclei_mean_texture_DVH',
                      'nuclei_mean_texture_IDH',
                      'bladder_glszm_SZNUN',
                      'bladder_firstorder_energy',
                      'nuclei_mean_texture_DVH',
                      'cancer_glszm_LALGLE',
                      'plasm_med_intensity_MIH')
datatable$feature = feat_alias

datatable = datatable[-12,] # 删除冗余
# 添加模态信息
type = c()
type[grep('bladder|cancer',datatable$feature)] = 'CT Feature'
type[grep('nuclei|plasm',datatable$feature)] = 'WSI Feature'
datatable$type = type

datatable = datatable[order(datatable$Cox.HR),]
datatable$feature = factor(datatable$feature, levels = datatable$feature)

datatable$Cox.pval = format(datatable$Cox.pval,scientific=F,digits=1)
datatable$pval_x = rep(2.7, nrow(datatable))

ggplot(datatable, aes(x = Cox.HR, y = feature,color = type))+
  geom_vline(aes(xintercept = 1), colour="#C4CCD3", linetype="dashed", size = 2)+
  geom_errorbarh(aes(xmax =Cox.Upper, xmin = Cox.Lower), 
                 height = 0.3, color = "#2F4554",size = 1) +
  geom_point(size=12,shape = 'diamond') +
  scale_colour_manual(values = c('#C23531', '#2F4554'))+
  scale_x_continuous(limits= c(0.1, 3), breaks= seq(0, 2.5, 0.5))+
  geom_text(aes(x = pval_x, y = feature, label = Cox.pval),
            size = 10, color = '#2F4554')+
  annotate("text", x= 3, y=6 ,label= 'P-value', 
           size = 10, angle = 90, color = '#2F4554')+
  labs(x = 'Hazard Ratio (Overall Survival)')+
  theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =30),
        axis.title.x = element_text(size = 45, color = '#2F4554'),
        axis.title.y = element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 30, color = '#2F4554'),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA, size=1),
        legend.position = c(0.15,0.92))
ggsave('cox_forest_plot.pdf', device = 'pdf', width = 16, height = 12, dpi = 300)
ggsave('cox_forest_plot.jpg', device = 'jpeg', width = 16, height = 12, dpi = 300)
