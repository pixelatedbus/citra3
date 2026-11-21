% glues neighbouring blocks with similar colours into bigger regions
function L = mergeRegions(I, L, blocks, Tm, minArea)
% I: double m x n x 3 (or m x n), values in [0,1], input image
% L: double m x n, block labels 1..n from quadSplit
% blocks: double n x 4, [row col height width] per block
% Tm: double scalar, max rgb distance between region means to merge
% minArea: integer scalar, smallest region in pixels
% L (out): double m x n, region labels 1..R
% every block starts as its own region, owner(k) is the region block k is in
n = size(blocks, 1);
owner = (1:n)';
area = zeros(n, 1);
colour = zeros(n, size(I, 3));
for k = 1:n
    rows = blocks(k, 1) : blocks(k, 1) + blocks(k, 3) - 1;
    cols = blocks(k, 2) : blocks(k, 2) + blocks(k, 4) - 1;
    area(k) = numel(rows) * numel(cols);
    colour(k, :) = mean(I(rows, cols, :), [1 2]);
end

pairs = neighbourPairs(L);
dist = sqrt(sum((colour(pairs(:, 1), :) - colour(pairs(:, 2), :)).^2, 2));
[~, order] = sort(dist);
pairs = pairs(order, :);

% absorbing a small region changes its neighbour's mean colour, which can
% make new merges possible, so repeat both steps until nothing is absorbed
absorbed = true;
while absorbed
    % a merge changes the region's mean colour, so keep going until nothing merges
    changed = true;
    while changed
        changed = false;
        for k = 1:size(pairs, 1)
            a = owner(pairs(k, 1));
            b = owner(pairs(k, 2));
            if a ~= b && norm(colour(a, :) - colour(b, :)) <= Tm
                [owner, area, colour] = joinRegions(owner, area, colour, a, b);
                changed = true;
            end
        end
    end

    % regions that are still too small go to their closest neighbour
    absorbed = false;
    ids = unique(owner);
    [~, order] = sort(area(ids));
    for a = ids(order)'
        if ~any(owner == a) || area(a) >= minArea
            continue
        end
        nb = neighboursOf(a, owner, pairs);
        if isempty(nb)
            continue
        end
        dist = sqrt(sum((colour(nb, :) - colour(a, :)).^2, 2));
        [~, i] = min(dist);
        [owner, area, colour] = joinRegions(owner, area, colour, nb(i), a);
        absorbed = true;
    end
end

ids = unique(owner);
newLabel = zeros(n, 1);
newLabel(ids) = 1:numel(ids);
L = newLabel(owner(L));
end

% folds region b into region a and updates a's area and mean colour
function [owner, area, colour] = joinRegions(owner, area, colour, a, b)
% owner: double n x 1, region id of each block
% area: double n x 1, pixel count of each region id
% colour: double n x c, mean colour of each region id
% a, b: integer scalar region ids, b goes into a
colour(a, :) = (area(a) * colour(a, :) + area(b) * colour(b, :)) / (area(a) + area(b));
area(a) = area(a) + area(b);
owner(owner == b) = a;
end

% lists the regions that touch region a
function nb = neighboursOf(a, owner, pairs)
% a: integer scalar, region id
% owner: double n x 1, region id of each block
% pairs: double P x 2, block ids that touch
% nb: double column vector, region ids touching a
first = owner(pairs(:, 1));
second = owner(pairs(:, 2));
nb = unique([second(first == a); first(second == a)]);
nb(nb == a) = [];
end
