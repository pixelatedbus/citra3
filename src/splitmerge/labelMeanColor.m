% paints each region with its average colour so the segmentation is easy to see
function J = labelMeanColor(I, L)
% I: double m x n x 3 (or m x n), values in [0,1], input image
% L: double m x n, region labels 1..K
% J: double, same size as I, every region painted with its mean colour
J = zeros(size(I));
for c = 1:size(I, 3)
    channel = I(:, :, c);
    out = zeros(size(L));
    for k = 1:max(L(:))
        inside = L == k;
        out(inside) = mean(channel(inside));
    end
    J(:, :, c) = out;
end
end
