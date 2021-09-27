###--enrichmant analysis
library('tidyr')
library('tibble')
library('ggplot2')
library('latex2exp')

setwd('F:/Bladder_project/FeatureAssociations')
# load t.test res
ttestRes = read.table('F:/Bladder_project/FeatureAssociations/grade_pval_res.txt',header = TRUE, sep = '\t')
tSigRes = ttestRes[which(ttestRes$adj.p.val < 0.05),]

totalFeat = ttestRes$feature_name
sigFeat = tSigRes$feature_name
non_sigFeat = totalFeat[!c(totalFeat %in% sigFeat)]

# load sigCluster res
block1Res = read.csv('F:/Bladder_project/FeatureAssociations/output/halla_cluster1_asso.csv', header = TRUE, sep = ',')
block1Feat = unique(c(block1Res$X_features,block1Res$Y_features))
non_block1Feat = totalFeat[!c(totalFeat %in% block1Feat)]

#### construct the matrix
########### A : block1; B: sig t-test
# A+B   A+nB  = 69

# nA+B  nA+nB = 555

# =142  =482
############
A_B = length(sigFeat[sigFeat %in% block1Feat])
nA_nB = length(non_block1Feat[non_block1Feat %in% non_sigFeat])
nA_B = length(sigFeat) - A_B
A_nB = length(non_sigFeat) - nA_nB

datatable = data.frame(sig_test = c(A_B, nA_B),
                       non_sig_test = c(A_nB, nA_nB),
                       row.names = c('block1', 'non_block1'))
res = fisher.test(datatable)

##-- plot
#input_table =  gather(rownames_to_column(datatable, var = 'cluster'),key =  'test',value = 'count', -cluster) 
input_table = data.frame(tile = c('a', 'b', 'c','d'),
                         x1 = c(0,0,8,8),
                         x2 = c(7.6,7.6,25,25),
                         y1 = c(15.4,0.0,21.0,0.0),
                         y2 = c(25,15.0,25.0,20.6))

rect = data.frame(x = c(13,13,24,24),
                  y = c(1,5,5,1))


ggplot(data = input_table)+
  geom_rect(aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2, fill = tile), alpha = 0.9)+
  scale_fill_manual(values = c('#c23531', '#61A0A8','#D48265', '#c4ccd3'))+
  theme_void()+
  annotate('text', x = 4, y = -1, label = 'Sig (142)', size = 15, color =  '#6E7074')+
  annotate('text', x = 16, y = -1, label = 'non-Sig (482)', size = 15, color =  '#6E7074')+
  annotate('text', x = 12.5, y = -3, label = 't-test High/Low-Grade', size = 15, color =  '#2F4554')+
  annotate('text', x = -1, y = 21, label = 'In (69)', size = 15, color =  '#6E7074', angle = 90)+
  annotate('text', x = -1, y = 8, label = 'Out (555)', size = 15, color =  '#6E7074', angle = 90)+
  annotate('text', x = -3, y = 12.5, label = 'Densely Associated Block1', size = 15, color =  '#2F4554', angle = 90)+
  
  annotate('text', x = 3.5, y = 20, label = 55, size = 15, color =  'black')+
  annotate('text', x = 3.5, y = 8, label = 87, size = 15, color =  'black')+
  annotate('text', x = 16, y = 23, label = 14, size = 15, color =  'black')+
  annotate('text', x = 16, y = 12, label = 468, size = 15, color =  'black')+
  
  geom_polygon(data = rect, aes(x = x, y = y), fill = NA, size = 1, color='#2F4554', alpha = 0.9)+
  annotate('text', x = 18, y = 4.2, label = "Fisher's Exact Test", size = 10, color = '#2F4554',hjust = 0.4, fontface = 'italic')+
  annotate('text', x = 18.5, y = 2.9, label = TeX('Odds Ratio = 21.0$\\pm$ 10.8'), size = 10, color = '#2F4554')+
  annotate('text', x = 18, y = 1.75, label = 'P < 0.001', size = 10, color = '#2F4554',hjust = 0.2)+
  theme(legend.position = 'none')
ggsave('enrichment_plot_block1.pdf', device = 'pdf', width = 16, height = 12, dpi = 300)

