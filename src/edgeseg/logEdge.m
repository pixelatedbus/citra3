% laplacian of gaussian edge detection: log kernel, then zero crossings
function [BW, R, T] = logEdge(I, T, sigma)
% I: double m x n, gray image
% T: double scalar, or [] to pick it automatically
% sigma: double scalar, gaussian spread in pixels
% BW: logical m x n, true = edge
% R: double m x n, laplacian of gaussian response
% T (out): double scalar, threshold actually used
R = convolve(I, logKernel(sigma));
[BW, T] = zeroCrossing(R, T);
end
