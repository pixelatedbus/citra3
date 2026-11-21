% cuts the main object out of the image using its edges and some morphology
function [mask, BW] = segmentByEdges(I, method, opt)
% I: double m x n x 3 (or m x n), values in [0,1], input image
% method: char, operator name (see detectEdges)
% opt: struct, parameters set in main.m
%   .fudge: double scalar, multiplier on the auto threshold
%   .smooth: double scalar, gaussian sigma before detection, 0 = off
%   .sigma: double scalar, sigma for log and canny
%   .dilate: integer scalar, length in pixels of the dilation lines
%   .clearBorder: logical scalar, true removes blobs touching the border
%   .erode: integer scalar, number of 1-pixel erosions
%   .keepLargest: logical scalar, true keeps only the biggest blob
% mask: logical m x n, true = object
% BW: logical m x n, true = edge
% Steps from MathWorks' "Detect Cell Using Edge Detection and Morphology"
g = toGray(I);
if opt.smooth > 0
    g = convolve(g, gaussianKernel(opt.smooth));
end

[~, ~, T] = detectEdges(g, method, [], opt.sigma);
BW = detectEdges(g, method, T * opt.fudge, opt.sigma);

mask = imdilate(BW, strel('line', opt.dilate, 90));
mask = imdilate(mask, strel('line', opt.dilate, 0));
mask = imfill(mask, 'holes');

if opt.clearBorder
    mask = imclearborder(mask, 4);
end

for k = 1:opt.erode
    mask = imerode(mask, strel('diamond', 1));
end

if opt.keepLargest && any(mask(:))
    mask = bwareafilt(mask, 1);
end
end
