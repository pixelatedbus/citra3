% asks for an image file and adds it to the dropdown as the selected item
function browseImage(list, fig)
% list: matlab.ui.control.DropDown, made by imageDropdown
% fig: matlab.ui.Figure, brought back to front after the file dialog
[file, folder] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff', 'Images'}, 'Choose an image');
figure(fig);
if isequal(file, 0)
    return
end
path = fullfile(folder, file);
list.ItemsData = [list.ItemsData {path}];
list.Items = [list.Items {file}];
list.Value = path;
end
