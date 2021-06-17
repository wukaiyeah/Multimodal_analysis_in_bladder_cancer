library('ggplot2')

setwd('/media/wukai/AI_Team_03/Bladder_project/mol_subtype_classify/CAM')
# load data
datatable = read.csv('scorecam_matrix.csv', header = TRUE, sep = ',', row.names = 1)
mol_subtype = c()
mol_subtype[grep('0',datatable$mol_label)] = 'luminal'
mol_subtype[grep('1',datatable$mol_label)] = 'basal'
datatable = datatable[,-c(1)]

colData = data.frame(mol_subtype = mol_subtype, row.names = row.names(datatable))
cam_table0 = datatable[grep(0, datatable$mol_label),]
cam_table0 = cam_table0[,-1]
cam_table1 = datatable[grep(1, datatable$mol_label),]
cam_table1 = cam_table1[,-1]

cam_table0_median = apply(cam_table0, 2, median)
cam_table0_median = data.frame(cam = -1 * cam_table0_median, 
                        features = factor(names(cam_table0_median), levels = names(cam_table0_median)),
                        mol_subtype = 'luminal')
write.csv(cam_table0_median[which(cam_table0_median$cam != 0),],'luminal_activated_feature.csv', quote = FALSE, row.names = FALSE)

cam_table1_median = apply(cam_table1, 2, median)
cam_table1_median = data.frame(cam = cam_table1_median, 
                               features = factor(names(cam_table1_median), levels = names(cam_table1_median)),
                               mol_subtype = 'basal')
write.csv(cam_table1_median[which(cam_table1_median$cam > 0),], 'basal_activated_feature.csv', quote = FALSE, row.names = FALSE)

cam_table_median = rbind(cam_table0_median, cam_table1_median)

#---plot 1
ggplot(cam_table_median, aes(x = features , y = cam, fill = mol_subtype))+
  geom_bar(stat = 'identity',position = 'dodge', width = 8, size = 3)+
  scale_fill_manual(values = c('#C23531', '#2F4554'))+
  geom_vline(aes(xintercept=200))+
  labs(y = 'Median of Score-CAM', 
       x = 'CT                       WSI  Features')+
  theme_bw()+
  theme(plot.title = element_text(size = 55, hjust = 0.5 ),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45, hjust = 0.1),
        axis.title.y = element_text(size = 45),
        axis.ticks.x = element_blank(),
        panel.grid.major.x=element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        legend.position = c(0.9,0.9),
        legend.key = element_rect(fill = NA, colour = NA, size=1)
        )

ggsave('cam_plot1.pdf', device = 'pdf', dpi = 300, width = 16, height = 12)

##---plot 2
feat_type = c()
feat_type[grep('bladder|cancer',as.vector(cam_table_median$features))] = 'CT'
feat_type[grep('bladder|cancer',as.vector(cam_table_median$features), invert = TRUE)] = 'WSI'
cam_table_median$feat_type = factor(feat_type, levels = c('WSI', 'CT'))

ggplot(cam_table_median, aes(x = features , y = cam, fill = mol_subtype))+
  geom_bar(stat = 'identity',position = 'dodge', width = 8, size = 3)+
  scale_fill_manual(values = c('#C23531', '#2F4554'))+
  facet_grid(~feat_type, 
             scales = 'free',space = 'free')+
  labs(y = 'Median of Score-CAM', 
       x = 'Texture Features')+
  theme_bw()+
  theme(plot.title = element_text(size = 55, hjust = 0.5 ),
        strip.text = element_text(size = 45),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45),
        axis.title.y = element_text(size = 45),
        axis.ticks.x = element_blank(),
        panel.grid.major.x=element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        legend.position = c(0.7,0.9),
        legend.key = element_rect(fill = NA, colour = NA, size=1)
  )

ggsave('cam_plot2.pdf', device = 'pdf', dpi = 300, width = 16, height = 12)

##---plot 3
cam_table_median$cam = abs(cam_table_median$cam)
feat_type = c()
feat_type[grep('bladder|cancer',as.vector(cam_table_median$features))] = 'CT'
feat_type[grep('bladder|cancer',as.vector(cam_table_median$features), invert = TRUE)] = 'WSI'
cam_table_median$feat_type = factor(feat_type, levels = c('WSI', 'CT'))

ggplot(cam_table_median, aes(x = features , y = cam, fill = mol_subtype))+
  geom_bar(stat = 'identity',position = 'dodge', width = 8, size = 3, alpha = 1)+
  scale_fill_manual(values = c('#C23531', '#2F4554'))+
  facet_grid(~feat_type, 
             scales = 'free',space = 'free')+
  labs(y = 'Median of Score-CAM', 
       x = 'Texture Features')+
  theme_bw()+
  theme(plot.title = element_text(size = 55, hjust = 0.5 ),
        strip.text = element_text(size = 45),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45),
        axis.title.y = element_text(size = 45),
        axis.ticks.x = element_blank(),
        panel.grid.major.x=element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        legend.position = c(0.7,0.9),
        legend.key = element_rect(fill = NA, colour = NA, size=1)
  )

ggsave('cam_plot3.pdf', device = 'pdf', dpi = 300, width = 16, height = 12)



