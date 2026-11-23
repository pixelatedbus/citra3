function L = loadLabels(path)
% path: char, label PNG (class 0..10, 255 = void)
% L: double m x n, class 1..11, 0 = void
L = double(imread(path)) + 1;
L(L == 256) = 0;
end
