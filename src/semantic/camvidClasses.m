function [names, colours] = camvidClasses()
% names: cell 1 x 11, class names (label value k = names{k})
% colours: double 11 x 3, rgb in [0,1], one row per class
names = {'Sky', 'Building', 'Pole', 'Road', 'Pavement', 'Tree', ...
    'SignSymbol', 'Fence', 'Car', 'Pedestrian', 'Bicyclist'};
% same colours as the MathWorks CamVid example
colours = [128 128 128
           128   0   0
           192 192 192
           128  64 128
            60  40 222
           128 128   0
           192 128 128
            64  64 128
            64   0 128
            64  64   0
             0 128 192] / 255;
end
