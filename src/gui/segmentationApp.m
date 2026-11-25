% main window with one tab per segmentation method
function fig = segmentationApp(root)
% root: char, project folder (holds data/, results/, src/ and .venv/)
% fig: matlab.ui.Figure, the app window
dataDir = fullfile(root, 'data', 'bsds500_test_8');
saveDir = fullfile(root, 'results');
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

fig = uifigure('Name', 'IF4073 Tugas 3 - Segmentasi Citra', 'Position', [20 40 1600 860]);
fig.WindowState = 'maximized';
fig.Theme = 'light';   % same look on every machine
grid = uigridlayout(fig, [1 1]);
grid.Padding = [0 0 0 0];
tabs = uitabgroup(grid);

tabEdge(uitab(tabs, 'Title', 'B. Edge segmentation'), fig, dataDir, saveDir);
tabSplitMerge(uitab(tabs, 'Title', 'C. Split and merge'), fig, dataDir, saveDir);
tabSemantic(uitab(tabs, 'Title', 'D. Semantic segmentation'), fig, root, saveDir);
end
