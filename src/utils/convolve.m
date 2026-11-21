% 2D convolution that keeps the image size and doesn't invent edges at the border
function J = convolve(I, K)
% I: double m x n, gray image
% K: double kh x kw (kh, kw odd), kernel
% J: double m x n, filtered image
% pad the image with copies of its border pixels so the border doesn't turn
% into an edge, then 'valid' cuts the result back to the original size
padRows = (size(K, 1) - 1) / 2;
padCols = (size(K, 2) - 1) / 2;
P = padarray(I, [padRows padCols], 'replicate');
J = conv2(P, K, 'valid');
end
