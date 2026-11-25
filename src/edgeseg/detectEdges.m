% runs one of the six edge operators on an image
function [BW, R, T] = detectEdges(I, method, T, sigma)
% I: double m x n x 3 (or m x n), values in [0,1], input image
% method: char, 'sobel' | 'prewitt' | 'roberts' | 'laplace' | 'log' | 'canny'
% T: double scalar (1 x 2 [low high] for canny), or [] to pick it automatically
% sigma: double scalar, gaussian spread in pixels, only used by log and canny
% BW: logical m x n, true = edge
% R: double m x n, response before thresholding
% T (out): double scalar (1 x 2 for canny), threshold actually used
I = toGray(I);

switch method
    case 'sobel'
        [BW, R, T] = sobelEdge(I, T);
    case 'prewitt'
        [BW, R, T] = prewittEdge(I, T);
    case 'roberts'
        [BW, R, T] = robertsEdge(I, T);
    case 'laplace'
        [BW, R, T] = laplaceEdge(I, T);
    case 'log'
        [BW, R, T] = logEdge(I, T, sigma);
    case 'canny'
        [BW, T] = edge(I, 'canny', T, sigma);
        R = double(BW);
    otherwise
        error('unknown method: %s', method);
end
end
