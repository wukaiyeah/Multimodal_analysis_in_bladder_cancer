'''
Part of code borrows from https://github.com/1Konny/gradcam_plus_plus-pytorch
'''

import torch
from utils import find_layer

class BaseCAM(object):
    """ Base class for Class activation mapping.

        : Args
            - **model_dict -** : Dict. Has format as dict(type='vgg', arch=torchvision.models.vgg16(pretrained=True),
            layer_name='features',input_size=(224, 224)).

    """

    def __init__(self, model_dict):
        model_type = model_dict['type']
        layer_name = model_dict['layer_name']
        
        self.model_arch = model_dict['arch']
        self.model_arch.eval()
        if torch.cuda.is_available():
          self.model_arch.cuda()
        self.gradients = dict()
        self.activations = dict()

        def backward_hook(module, grad_input, grad_output):
            if torch.cuda.is_available():
              self.gradients['value'] = grad_output[0].cuda()
            else:
              self.gradients['value'] = grad_output[0]
            return None

        def forward_hook(module, input, output):
            if torch.cuda.is_available():
              self.activations['value'] = output.cuda()
            else:
              self.activations['value'] = output
            return None
            
        if 'my' in model_type :
            self.target_layer = find_layer(self.model_arch, layer_name)

        self.target_layer.register_forward_hook(forward_hook)
        self.target_layer.register_backward_hook(backward_hook)

    def forward(self, input, class_idx=None, retain_graph=False):
        return None

    def __call__(self, input, class_idx=None, retain_graph=False):
        return self.forward(input, class_idx, retain_graph)