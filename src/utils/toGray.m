% turns an rgb image into gray, gray images pass through untouched
function g = toGray(I)
% I: double m x n x 3 or m x n
% g: double m x n, gray image
if size(I, 3) == 3
    g = rgb2gray(I);
else
    g = I;
end
end
