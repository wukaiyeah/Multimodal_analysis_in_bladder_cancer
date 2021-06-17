X_INPUT=/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations/X_ct_features.txt
Y_INPUT=/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations/Y_wsi_features.txt
OUTPUT_DIR=/media/wukai/AI_Team_03/Bladder_project/FeatureAssociations/output

halla -x $X_INPUT -y $Y_INPUT -m spearman -o $OUTPUT_DIR --clustermap --hallagram --diagnostic_plot
# draw pdf
hallagram -i $OUTPUT_DIR -o hallagram.pdf --dpi 300 
