% dropdown listing the images in a folder, the value is the full file path
function list = imageDropdown(parent, folder)
% parent: grid layout to put the dropdown in
% folder: char, folder with .jpg / .png images
% list: matlab.ui.control.DropDown, Items = file names, ItemsData = full paths
files = [dir(fullfile(folder, '*.jpg')); dir(fullfile(folder, '*.png'))];
names = {files.name};
paths = fullfile(folder, names);
list = uidropdown(parent, 'Items', names, 'ItemsData', paths);
end
