% tab B: cuts out the main object with each edge operator, all six shown side by side
function tabEdge(tab, fig, dataDir, saveDir)
% tab: matlab.ui.container.Tab, tab to build in
% fig: matlab.ui.Figure, the app window
% dataDir: char, folder with the test images
% saveDir: char, folder suggested when saving a screenshot
operators = {'sobel', 'prewitt', 'roberts', 'laplace', 'log', 'canny'};

root = uigridlayout(tab, [1 2]);
root.ColumnWidth = {340, '1x'};

% left: image, parameters, buttons
left = uigridlayout(root, [12 2]);
left.ColumnWidth = {'fit', '1x'};
left.RowHeight = repmat({'fit'}, 1, 12);

uilabel(left, 'Text', 'Image');
imageList = imageDropdown(left, dataDir);
browseButton = uibutton(left, 'Text', 'Browse...');
browseButton.Layout.Row = 2;
browseButton.Layout.Column = [1 2];

uilabel(left, 'Text', 'Threshold factor');
fudgeField = uieditfield(left, 'numeric', 'Value', 0.5, 'Limits', [0 Inf]);
uilabel(left, 'Text', 'Smoothing sigma (not LoG/Canny)');
smoothField = uieditfield(left, 'numeric', 'Value', 0, 'Limits', [0 Inf]);
uilabel(left, 'Text', 'LoG / Canny sigma');
sigmaField = uieditfield(left, 'numeric', 'Value', 2, 'Limits', [0 Inf], 'LowerLimitInclusive', 'off');
uilabel(left, 'Text', 'Dilation length');
dilateField = uieditfield(left, 'numeric', 'Value', 3, 'Limits', [1 Inf], 'RoundFractionalValues', 'on');
uilabel(left, 'Text', 'Erosion steps');
erodeField = uieditfield(left, 'numeric', 'Value', 2, 'Limits', [0 Inf], 'RoundFractionalValues', 'on');
uilabel(left, 'Text', 'Clear border');
clearBorderBox = uicheckbox(left, 'Text', '', 'Value', false);
uilabel(left, 'Text', 'Object to keep');
keepList = uidropdown(left, 'Items', {'largest blob', 'closest to centre', 'all blobs'}, ...
    'ItemsData', {'largest', 'centre', 'all'}, 'Value', 'largest');

runButton = uibutton(left, 'Text', 'Run');
runButton.Layout.Row = 10;
runButton.Layout.Column = [1 2];
saveButton = uibutton(left, 'Text', 'Save screenshot...');
saveButton.Layout.Row = 11;
saveButton.Layout.Column = [1 2];

% right: original in the top-left corner, then two operators per row,
% each as an [edges | object] pair
right = uigridlayout(root, [2 1]);
right.RowHeight = {'1x', 'fit'};
axesGrid = uigridlayout(right, [3 5]);
axesGrid.Padding = [0 0 0 0];
originalAxes = uiaxes(axesGrid);
originalAxes.Layout.Row = 1;
originalAxes.Layout.Column = 1;
edgeAxes = gobjects(1, 6);
objectAxes = gobjects(1, 6);
for m = 1:6
    row = ceil(m / 2);
    col = 2;
    if mod(m, 2) == 0
        col = 4;
    end
    edgeAxes(m) = uiaxes(axesGrid);
    edgeAxes(m).Layout.Row = row;
    edgeAxes(m).Layout.Column = col;
    objectAxes(m) = uiaxes(axesGrid);
    objectAxes(m).Layout.Row = row;
    objectAxes(m).Layout.Column = col + 1;
end
status = uilabel(right, 'Text', '', 'FontName', 'Consolas', 'WordWrap', 'on');

imageList.ValueChangedFcn = @(~, ~) showOriginal();
browseButton.ButtonPushedFcn = @(~, ~) browse();
runButton.ButtonPushedFcn = @(~, ~) runSegmentation();
saveButton.ButtonPushedFcn = @(~, ~) saveScreenshot(fig, imageList.Value, 'B', saveDir);
showOriginal();

    % adds a file from disk to the list and shows it
    function browse()
        browseImage(imageList, fig);
        showOriginal();
    end

    % shows the chosen image and clears old results
    function showOriginal()
        for k = 1:6
            showImage(edgeAxes(k), [], operators{k});
            showImage(objectAxes(k), [], '');
        end
        status.Text = 'Press Run.';
        if isempty(imageList.Value)
            showImage(originalAxes, [], 'original');
            return
        end
        showImage(originalAxes, loadImage(imageList.Value), 'original');
    end

    % runs all six operators with the parameters on the left
    function runSegmentation()
        if isempty(imageList.Value)
            uialert(fig, 'Choose an image first.', 'Edge segmentation');
            return
        end
        I = loadImage(imageList.Value);
        opt.fudge = fudgeField.Value;
        opt.smooth = smoothField.Value;
        opt.sigma = sigmaField.Value;
        opt.dilate = dilateField.Value;
        opt.erode = erodeField.Value;
        opt.clearBorder = clearBorderBox.Value;
        opt.keep = keepList.Value;

        busy = uiprogressdlg(fig, 'Title', 'Edge segmentation', 'Message', 'Running...', 'Indeterminate', 'on');
        for k = 1:6
            [mask, BW] = segmentByEdges(I, operators{k}, opt);
            showImage(edgeAxes(k), BW, [operators{k} ' edges']);
            showImage(objectAxes(k), I .* mask, [operators{k} ' object']);
        end
        close(busy);

        [~, name, ext] = fileparts(imageList.Value);
        status.Text = sprintf(['%s%s | threshold factor %g | smoothing sigma %g | LoG/Canny sigma %g | ' ...
            'dilation %d | erosion %d | clear border %d | keep %s'], name, ext, opt.fudge, ...
            opt.smooth, opt.sigma, opt.dilate, opt.erode, opt.clearBorder, opt.keep);
    end
end
