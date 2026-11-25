% marks the pixels where the laplacian response changes sign by a big enough jump
function [BW, T] = zeroCrossing(R, T)
% R: double m x n, laplacian or log response
% T: double scalar, or [] to pick it automatically
% BW: logical m x n, true = edge (border pixels always false)
% T (out): double scalar, threshold actually used
% a pixel is an edge if its two neighbours (left/right or up/down) have opposite signs and the jump between them is bigger than T
if isempty(T)
    T = 3 * mean(abs(R(:)));
end

[rows, cols] = size(R);
BW = false(rows, cols);
for i = 2:rows-1
    for j = 2:cols-1
        left = R(i, j-1);
        right = R(i, j+1);
        up = R(i-1, j);
        down = R(i+1, j);

        acrossHorizontal = left * right < 0 && abs(left - right) > T;
        acrossVertical = up * down < 0 && abs(up - down) > T;
        BW(i, j) = acrossHorizontal || acrossVertical;
    end
end
end
