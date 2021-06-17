'''
@Author: Kai Wu
My Score-CAM script for Conv1d-net
Part of code borrows from https://github.com/haofanwang/Score-CAM and
https://github.com/1Konny/gradcam_plus_plus-pytorch
'''
import torch
import torch.nn.functional as F
from cam.basecam import *


class ScoreCAM(BaseCAM):

    """
        ScoreCAM, inherit from BaseCAM

    """
    def __init__(self, model_dict):
        super().__init__(model_dict)

    def forward(self, input, class_idx=None, retain_graph=False):
        b, c, f  = input.size()
        
        # predication on raw input
        logit = self.model_arch(input).cuda()
        
        if class_idx is None:
            predicted_class = [1 if logit > 0 else 0][0]
            score = logit.squeeze()
        else:
            predicted_class = torch.LongTensor([class_idx])
            score = logit.squeeze()
        
        logit = torch.sigmoid(logit)

        if torch.cuda.is_available():
          score = score.cuda()
          logit = logit.cuda()

        self.model_arch.zero_grad()
        score.backward(retain_graph=retain_graph)
        activations = self.activations['value']
        b, k, u = activations.size()
        
        score_saliency_map = torch.zeros((1, 1, f))

        if torch.cuda.is_available():
          activations = activations.cuda()
          score_saliency_map = score_saliency_map.cuda()

        with torch.no_grad():
          for i in range(k):

              # upsampling
                saliency_map = torch.unsqueeze(activations[:, i, :], 1)
                saliency_map = F.interpolate(saliency_map, size= (f), mode='linear', align_corners=False) # 插值上采样
              
                if saliency_map.max() == saliency_map.min():
                    continue
              
              # normalize to 0-1
                norm_saliency_map = (saliency_map - saliency_map.min()) / (saliency_map.max() - saliency_map.min())

              # how much increase if keeping the highlighted region
              # predication on masked input
                output = self.model_arch(input * norm_saliency_map)
                output = torch.sigmoid(output)
                if predicted_class > 0.:
                    score = output.squeeze()
                else:
                    score = (1-output).squeeze()
                score_saliency_map +=  score * saliency_map
                
        score_saliency_map = F.relu(score_saliency_map)
        score_saliency_map_min, score_saliency_map_max = score_saliency_map.min(), score_saliency_map.max()

        if score_saliency_map_min == score_saliency_map_max:
            return None

        score_saliency_map = (score_saliency_map - score_saliency_map_min).div(score_saliency_map_max - score_saliency_map_min).data

        return score_saliency_map

    def __call__(self, input, class_idx=None, retain_graph=False):
        return self.forward(input, class_idx, retain_graph)