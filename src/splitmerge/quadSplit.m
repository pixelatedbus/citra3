% keeps cutting the image into quarters until every block is uniform enough
function [L, blocks] = quadSplit(I, T, minSize)
% I: double m x n x 3 (or m x n), values in [0,1], input image
% T: double scalar, homogeneity threshold
% minSize: integer scalar, smallest block side in pixels
% L: double m x n, pixel value = index of its block 1..K
% blocks: double K x 4, one row [row col height width] per leaf of the quadtree
[m, n, ~] = size(I);
blocks = splitBlock(I, 1, 1, m, n, T, minSize);

L = zeros(m, n);
for k = 1:size(blocks, 1)
    rows = blocks(k, 1) : blocks(k, 1) + blocks(k, 3) - 1;
    cols = blocks(k, 2) : blocks(k, 2) + blocks(k, 4) - 1;
    L(rows, cols) = k;
end
end

% splits one block into four and recurses, or keeps it whole if it's uniform or too small
function blocks = splitBlock(I, r, c, h, w, T, minSize)
% r, c: integer scalars, top-left corner of the block
% h, w: integer scalars, block height and width
% blocks: double k x 4, leaves found inside this block
R = I(r:r+h-1, c:c+w-1, :);
if min(h, w) < 2 * minSize || isHomogeneous(R, T)
    blocks = [r c h w];
    return
end

h1 = floor(h / 2);  h2 = h - h1;
w1 = floor(w / 2);  w2 = w - w1;
blocks = [splitBlock(I, r,      c,      h1, w1, T, minSize)
          splitBlock(I, r,      c + w1, h1, w2, T, minSize)
          splitBlock(I, r + h1, c,      h2, w1, T, minSize)
          splitBlock(I, r + h1, c + w1, h2, w2, T, minSize)];
end
