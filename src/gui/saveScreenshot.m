% saves a picture of the whole window, parameters included
function saveScreenshot(fig, imagePath, part, saveDir)
% fig: matlab.ui.Figure, the app window
% imagePath: char, image shown in the tab, used for the file name
% part: char, 'B' | 'C' | 'D'
% saveDir: char, folder suggested in the save dialog
[~, name] = fileparts(imagePath);
[file, folder] = uiputfile('*.png', 'Save screenshot', fullfile(saveDir, [name '_' part '.png']));
figure(fig);
if isequal(file, 0)
    return
end
exportapp(fig, fullfile(folder, file));
end
