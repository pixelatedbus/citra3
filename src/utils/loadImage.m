% reads an image file and returns it as a double image in [0,1]
function I = loadImage(path)
% path: char, image file path
% I: double m x n x 3 (or m x n for gray files), values in [0,1]
[I, map] = imread(path);
if ~isempty(map)
    I = ind2rgb(I, map);
end
I = im2double(I);
end
