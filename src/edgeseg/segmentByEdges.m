% cuts the main object out of an image using the edges found by one operator
function [mask, BW] = segmentByEdges(I, method, opt)
% I: double m x n x 3 (or m x n), values in [0,1], input image
% method: char, operator name (see detectEdges)
% opt: struct, parameters set in main.m
%   .fudge: double scalar, multiplier on the auto threshold
%   .smooth: double scalar, gaussian sigma before detection, 0 = off (not used by log and canny)
%   .sigma: double scalar, sigma for log and canny
%   .dilate: integer scalar, length in pixels of the dilation lines
%   .clearBorder: logical scalar, true removes blobs touching the border
%   .erode: integer scalar, number of 1-pixel erosions
%   .keep: char, 'largest' | 'centre' | 'all', which blob is the object
% mask: logical m x n, true = object
% BW: logical m x n, true = edge
% Steps from MathWorks' "Detect Cell Using Edge Detection and Morphology"
g = toGray(I);
if opt.smooth > 0 && ~strcmp(method, 'log') && ~strcmp(method, 'canny')
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

if ~strcmp(opt.keep, 'all') && any(mask(:))
    mask = pickBlob(mask, opt.keep);
end
end

function mask = pickBlob(mask, keep)
% mask: logical m x n, blobs after the morphology
% keep: char, 'largest' | 'centre'
% mask (out): logical m x n, only the chosen blob
[L, n] = bwlabel(mask, 8);
[rows, cols] = size(mask);
minArea = 0.01 * rows * cols;   % blobs under 1% of the image are ignored for 'centre', they are mostly specks

best = 0;
bestScore = -Inf;
for k = 1:n
    [r, c] = find(L == k);
    if strcmp(keep, 'largest')
        score = numel(r);
    elseif numel(r) >= minArea
        % squared distance from the centre to the blob's nearest pixel, smaller is better
        score = -min((r - rows / 2).^2 + (c - cols / 2).^2);
    else
        continue
    end
    if score > bestScore
        bestScore = score;
        best = k;
    end
end

% no blob is big enough for 'centre', fall back to the largest one
if best == 0
    mask = pickBlob(mask, 'largest');
    return
end
mask = L == best;
end
