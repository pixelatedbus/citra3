% names and display colours of the 21 Pascal VOC classes the downloaded model knew before fine-tuning
function [names, colours] = vocClasses()
% names: cell 1 x 21, class names (label value k = names{k}, 1 = background)
% colours: double 21 x 3, rgb in [0,1], the usual VOC palette
names = {'background', 'aeroplane', 'bicycle', 'bird', 'boat', 'bottle', 'bus', 'car', 'cat', ...
    'chair', 'cow', 'diningtable', 'dog', 'horse', 'motorbike', 'person', 'pottedplant', ...
    'sheep', 'sofa', 'train', 'tvmonitor'};
colours = [  0   0   0
           128   0   0
             0 128   0
           128 128   0
             0   0 128
           128   0 128
             0 128 128
           128 128 128
            64   0   0
           192   0   0
            64 128   0
           192 128   0
            64   0 128
           192   0 128
            64 128 128
           192 128 128
             0  64   0
           128  64   0
             0 192   0
           128 192   0
             0  64 128] / 255;
end
