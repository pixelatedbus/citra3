% the full split and merge: quadtree split first, then merge similar neighbours
function [L, Lsplit] = splitMerge(I, T, Tm, minSize, minArea)
% I: double m x n x 3 (or m x n), values in [0,1], input image
% T: double scalar, max std per channel for a block to stay whole
% Tm: double scalar, max rgb distance between region means to merge
% minSize: integer scalar, smallest block side in pixels
% minArea: integer scalar, smallest region in pixels
% L: double m x n, final region labels 1..R
% Lsplit: double m x n, block labels 1..K after the split
[Lsplit, blocks] = quadSplit(I, T, minSize);
L = mergeRegions(I, Lsplit, blocks, Tm, minArea);
end
