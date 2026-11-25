% 2d convolution that keeps the image size, border pixels are repeated outward
function J = convolve(I, K)
% I: double m x n, gray image
% K: double kh x kw (kh, kw odd), kernel
% J: double m x n, filtered image
padRows = (size(K, 1) - 1) / 2;
padCols = (size(K, 2) - 1) / 2;
P = padarray(I, [padRows padCols], 'replicate');
J = conv2(P, K, 'valid');
end
