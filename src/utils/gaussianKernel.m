% builds a normalised gaussian blur kernel for a given sigma
function K = gaussianKernel(sigma)
% sigma: double scalar, spread in pixels
% K: double (2r+1) x (2r+1) with r = ceil(3*sigma), weights sum to 1
% radius 3*sigma covers almost all of the bell curve
r = ceil(3 * sigma);
[x, y] = meshgrid(-r:r, -r:r);

K = exp(-(x.^2 + y.^2) / (2 * sigma^2));
K = K / sum(K(:));   % weights add up to 1 so brightness stays the same
end
