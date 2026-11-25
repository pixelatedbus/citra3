% builds a laplacian of gaussian kernel for a given sigma
function K = logKernel(sigma)
% sigma: double scalar, gaussian spread in pixels
% K: double (2r+1) x (2r+1) with r = ceil(3*sigma), weights sum to 0
% Laplacian of Gaussian: (d^2 - 2 sigma^2) / sigma^4 * exp(-d^2 / (2 sigma^2)),
% d = distance from the centre
r = ceil(3 * sigma);
[x, y] = meshgrid(-r:r, -r:r);
d2 = x.^2 + y.^2;

K = (d2 - 2 * sigma^2) / sigma^4 .* exp(-d2 / (2 * sigma^2));
K = K - mean(K(:));   % weights add up to 0 so flat areas give 0
end
