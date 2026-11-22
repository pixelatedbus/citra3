% tab C: split and merge segmentation, showing the quadtree blocks, the merged regions and their mean colours
function tabSplitMerge(tab, fig, dataDir, saveDir)
% tab: matlab.ui.container.Tab, tab to build in
% fig: matlab.ui.Figure, the app window
% dataDir: char, folder with the test images
% saveDir: char, folder suggested when saving a screenshot
root = uigridlayout(tab, [1 2]);
root.ColumnWidth = {290, '1x'};

% left: image, parameters, buttons
left = uigridlayout(root, [9 2]);
left.ColumnWidth = {'fit', '1x'};
left.RowHeight = repmat({'fit'}, 1, 9);

uilabel(left, 'Text', 'Image');
imageList = imageDropdown(left, dataDir);
browseButton = uibutton(left, 'Text', 'Browse...');
browseButton.Layout.Row = 2;
browseButton.Layout.Column = [1 2];

uilabel(left, 'Text', 'Split: max std (T)');
splitField = uieditfield(left, 'numeric', 'Value', 0.05, 'Limits', [0 Inf]);
uilabel(left, 'Text', 'Merge: max colour distance');
mergeField = uieditfield(left, 'numeric', 'Value', 0.12, 'Limits', [0 Inf]);
uilabel(left, 'Text', 'Smallest block side');
minSizeField = uieditfield(left, 'numeric', 'Value', 2, 'Limits', [1 Inf], 'RoundFractionalValues', 'on');
uilabel(left, 'Text', 'Smallest region area');
minAreaField = uieditfield(left, 'numeric', 'Value', 64, 'Limits', [0 Inf], 'RoundFractionalValues', 'on');

runButton = uibutton(left, 'Text', 'Run');
runButton.Layout.Row = 7;
runButton.Layout.Column = [1 2];
saveButton = uibutton(left, 'Text', 'Save screenshot...');
saveButton.Layout.Row = 8;
saveButton.Layout.Column = [1 2];

% right: 2 x 2 results and a line with the parameters used
right = uigridlayout(root, [2 1]);
right.RowHeight = {'1x', 'fit'};
axesGrid = uigridlayout(right, [2 2]);
axesGrid.Padding = [0 0 0 0];
originalAxes = uiaxes(axesGrid);
splitAxes = uiaxes(axesGrid);
mergeAxes = uiaxes(axesGrid);
meanAxes = uiaxes(axesGrid);
status = uilabel(right, 'Text', '', 'FontName', 'Consolas', 'WordWrap', 'on');

imageList.ValueChangedFcn = @(~, ~) showOriginal();
browseButton.ButtonPushedFcn = @(~, ~) browse();
runButton.ButtonPushedFcn = @(~, ~) runSegmentation();
saveButton.ButtonPushedFcn = @(~, ~) saveScreenshot(fig, imageList.Value, 'C', saveDir);
showOriginal();

    % adds a file from disk to the list and shows it
    function browse()
        browseImage(imageList, fig);
        showOriginal();
    end

    % shows the chosen image and clears old results
    function showOriginal()
        showImage(splitAxes, [], 'after split');
        showImage(mergeAxes, [], 'after merge');
        showImage(meanAxes, [], 'mean colour per region');
        status.Text = 'Press Run.';
        if isempty(imageList.Value)
            showImage(originalAxes, [], 'original');
            return
        end
        showImage(originalAxes, loadImage(imageList.Value), 'original');
    end

    % runs split and merge with the parameters on the left
    function runSegmentation()
        if isempty(imageList.Value)
            uialert(fig, 'Choose an image first.', 'Split and merge');
            return
        end
        I = loadImage(imageList.Value);
        T = splitField.Value;
        Tm = mergeField.Value;
        minSize = minSizeField.Value;
        minArea = minAreaField.Value;

        busy = uiprogressdlg(fig, 'Title', 'Split and merge', 'Message', 'Running...', 'Indeterminate', 'on');
        tic;
        [L, Lsplit] = splitMerge(I, T, Tm, minSize, minArea);
        seconds = toc;
        close(busy);

        % region borders drawn in yellow on top of the image
        nBlocks = max(Lsplit(:));
        nRegions = max(L(:));
        showImage(splitAxes, imoverlay(I, boundarymask(Lsplit), 'yellow'), sprintf('after split: %d blocks', nBlocks));
        showImage(mergeAxes, imoverlay(I, boundarymask(L), 'yellow'), sprintf('after merge: %d regions', nRegions));
        showImage(meanAxes, labelMeanColor(I, L), 'mean colour per region');

        [~, name, ext] = fileparts(imageList.Value);
        status.Text = sprintf(['%s%s | split max std T %g | merge max colour distance %g | ' ...
            'smallest block %d px | smallest region %d px | %d blocks -> %d regions | %.2f s'], ...
            name, ext, T, Tm, minSize, minArea, nBlocks, nRegions, seconds);
    end
end
