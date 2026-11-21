% roberts edge detector, a gradient taken along the two diagonals
function [BW, mag, T] = robertsEdge(I, T)
% I: double m x n, gray image
% T: double scalar, or [] to pick it automatically
% BW: logical m x n, true = edge
% mag: double m x n, gradient magnitude
% T (out): double scalar, threshold actually used
% 2x2 kernels put in a 3x3 so convolve has a centre pixel to work with
Kx = [1 0 0; 0 -1 0; 0 0 0];
Ky = [0 1 0; -1 0 0; 0 0 0];
[BW, mag, T] = gradientEdge(I, Kx, Ky, T);
end
