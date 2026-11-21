% finds edges where the laplacian flips sign
function [BW, R, T] = laplaceEdge(I, T)
% I: double m x n, gray image
% T: double scalar, or [] to pick it automatically
% BW: logical m x n, true = edge
% R: double m x n, laplacian response
% T (out): double scalar, threshold actually used
K = [1 1 1; 1 -8 1; 1 1 1];
R = convolve(I, K);
[BW, T] = zeroCrossing(R, T);
end
