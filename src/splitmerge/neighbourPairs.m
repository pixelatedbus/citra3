% lists every pair of labels that sit right next to each other
function pairs = neighbourPairs(L)
% L: double m x n, integer labels
% pairs: double P x 2, labels that touch left-right or up-down, one row [a b] per pair with a < b
left = L(:, 1:end-1);
right = L(:, 2:end);
up = L(1:end-1, :);
down = L(2:end, :);

a = [left(:); up(:)];
b = [right(:); down(:)];
keep = a ~= b;
a = a(keep);
b = b(keep);

pairs = unique([min(a, b), max(a, b)], 'rows');
end
