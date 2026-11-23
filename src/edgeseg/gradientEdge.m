function [BW, mag, T] = gradientEdge(I, Kx, Ky, T)
% I: double m x n, gray image
% Kx, Ky: double 3 x 3, kernels for horizontal / vertical change
% T: double scalar, or [] to pick it automatically
% BW: logical m x n, true = edge
% mag: double m x n, gradient magnitude
% T (out): double scalar, threshold actually used
gx = convolve(I, Kx);
gy = convolve(I, Ky);
mag = sqrt(gx.^2 + gy.^2);

if isempty(T)
    T = 2 * sqrt(mean(mag(:).^2));
end
BW = mag >= T;
end
