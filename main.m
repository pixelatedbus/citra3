% opens the segmentation app
root = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(root, 'src')));
segmentationApp(root);
