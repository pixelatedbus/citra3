% draws an image on an axes with a title and no ticks, an empty image clears the axes
function showImage(ax, img, titleText)
% ax: matlab.ui.control.UIAxes
% img: double or logical, m x n or m x n x 3, or [] to clear
% titleText: char, or cell of char for a title over several lines
if isempty(img)
    cla(ax);
else
    imshow(img, 'Parent', ax);
end
title(ax, titleText, 'Interpreter', 'none');
axis(ax, 'off');
ax.Toolbar.Visible = 'off';   % hides the zoom/pan buttons so screenshots stay clean
end
