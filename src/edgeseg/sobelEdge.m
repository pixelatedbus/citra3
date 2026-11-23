function [BW, mag, T] = sobelEdge(I, T)
% I: double m x n, gray image
% T: double scalar, or [] to pick it automatically
% BW: logical m x n, true = edge
% mag: double m x n, gradient magnitude
% T (out): double scalar, threshold actually used
Kx = [-1 0 1; -2 0 2; -1 0 1];
Ky = [1 2 1; 0 0 0; -1 -2 -1];
[BW, mag, T] = gradientEdge(I, Kx, Ky, T);
end
