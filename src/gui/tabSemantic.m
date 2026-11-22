% tab D: semantic segmentation of a street image with the CNN fine-tuned on CamVid
function tabSemantic(tab, fig, projectRoot, saveDir)
% tab: matlab.ui.container.Tab, tab to build in
% fig: matlab.ui.Figure, the app window
% projectRoot: char, project folder (holds .venv/, data/ and src/semantic/ with python/ and models/)
% saveDir: char, folder suggested when saving a screenshot
testDir = fullfile(projectRoot, 'data', 'camvid', 'prepared', 'test', 'images');
pythonExe = fullfile(projectRoot, '.venv', 'Scripts', 'python.exe');
scriptPath = fullfile(projectRoot, 'src', 'semantic', 'python', 'predict.py');
modelDir = fullfile(projectRoot, 'src', 'semantic', 'models');
[names, colours] = camvidClasses();
[vocNames, vocColours] = vocClasses();

root = uigridlayout(tab, [1 2]);
root.ColumnWidth = {340, '1x'};

% left: image and buttons
left = uigridlayout(root, [5 2]);
left.ColumnWidth = {'fit', '1x'};
left.RowHeight = repmat({'fit'}, 1, 5);
uilabel(left, 'Text', 'Image (CamVid test)');
imageList = imageDropdown(left, testDir);
browseButton = uibutton(left, 'Text', 'Browse...');
browseButton.Layout.Row = 2;
browseButton.Layout.Column = [1 2];
runButton = uibutton(left, 'Text', 'Run');
runButton.Layout.Row = 3;
runButton.Layout.Column = [1 2];
saveButton = uibutton(left, 'Text', 'Save screenshot...');
saveButton.Layout.Row = 4;
saveButton.Layout.Column = [1 2];

% right: input, ground truth, before and after fine-tuning on top;
% overlay, training curve and per-class scores below
right = uigridlayout(root, [2 1]);
right.RowHeight = {'1x', 'fit'};
grid = uigridlayout(right, [2 4]);
grid.Padding = [0 0 0 0];
inputAxes = uiaxes(grid);
truthAxes = uiaxes(grid);
beforeAxes = uiaxes(grid);
predAxes = uiaxes(grid);
overlayAxes = uiaxes(grid);
curveAxes = uiaxes(grid);
classTable = uitable(grid);
classTable.Layout.Column = [3 4];
status = uilabel(right, 'Text', '', 'FontName', 'Consolas', 'WordWrap', 'on');

[testMIoU, testAccuracy] = showModelInfo();

imageList.ValueChangedFcn = @(~, ~) showInput();
browseButton.ButtonPushedFcn = @(~, ~) browse();
runButton.ButtonPushedFcn = @(~, ~) runSegmentation();
saveButton.ButtonPushedFcn = @(~, ~) saveScreenshot(fig, imageList.Value, 'D', saveDir);
showInput();

    % training curve and the per-class test scores written by train.py and evaluate.py
    function [miou, accuracy] = showModelInfo()
        miou = NaN;
        accuracy = NaN;
        logFile = fullfile(modelDir, 'train_log.csv');
        if exist(logFile, 'file')
            log = readmatrix(logFile);   % epoch, train loss, val accuracy, val mIoU, seconds
            yyaxis(curveAxes, 'left');
            plot(curveAxes, log(:, 1), log(:, 2));
            ylabel(curveAxes, 'train loss');
            yyaxis(curveAxes, 'right');
            plot(curveAxes, log(:, 1), log(:, 4));
            ylabel(curveAxes, 'val mIoU');
            xlabel(curveAxes, 'epoch');
            title(curveAxes, 'fine-tuning on CamVid');
            curveAxes.Toolbar.Visible = 'off';
        end

        metricFile = fullfile(modelDir, 'test_metrics.csv');
        iou = nan(11, 1);
        classAccuracy = nan(11, 1);
        if exist(metricFile, 'file')
            m = readmatrix(metricFile);   % rows: 11 classes, mean, global; columns: name, accuracy, iou
            classAccuracy = m(1:11, 2);
            iou = m(1:11, 3);
            miou = m(12, 3);
            accuracy = m(13, 2);
        end
        classTable.Data = table(names', compose('%.1f', 100 * iou), compose('%.1f', 100 * classAccuracy));
        classTable.ColumnName = {'Class', 'Test IoU (%)', 'Test accuracy (%)'};
        classTable.RowName = {};
        % colour each class name like the label images, white text on dark colours
        for k = 1:11
            textColour = [0 0 0];
            if mean(colours(k, :)) < 0.5
                textColour = [1 1 1];
            end
            addStyle(classTable, uistyle('BackgroundColor', colours(k, :), 'FontColor', textColour), 'cell', [k 1]);
        end
    end

    % adds a file from disk to the list and shows it
    function browse()
        browseImage(imageList, fig);
        showInput();
    end

    % shows the chosen image and its ground truth if there is one, clears old results
    function showInput()
        showImage(beforeAxes, [], 'before fine-tuning (VOC classes)');
        showImage(predAxes, [], 'after fine-tuning (CamVid classes)');
        showImage(overlayAxes, [], 'after fine-tuning, over the image');
        status.Text = 'Press Run.';
        if isempty(imageList.Value)
            showImage(inputAxes, [], 'input');
            showImage(truthAxes, [], 'ground truth');
            return
        end
        showImage(inputAxes, loadImage(imageList.Value), 'input');
        truth = findTruth(imageList.Value);
        if isempty(truth)
            showImage(truthAxes, [], 'ground truth (none for this image)');
        else
            showImage(truthAxes, label2rgb(truth, colours, 'k'), 'ground truth');
        end
    end

    % runs the CNN through python and compares with the ground truth when there is one
    function runSegmentation()
        if isempty(imageList.Value)
            uialert(fig, 'Choose an image first.', 'Semantic segmentation');
            return
        end
        if ~exist(pythonExe, 'file')
            uialert(fig, ['Python not found: ' pythonExe], 'Semantic segmentation');
            return
        end
        I = loadImage(imageList.Value);
        busy = uiprogressdlg(fig, 'Title', 'Semantic segmentation', 'Message', 'Running the CNN...', 'Indeterminate', 'on');
        tic;
        try
            [L, Lbefore] = segmentSemantic(I, pythonExe, scriptPath);
        catch err
            close(busy);
            uialert(fig, err.message, 'Semantic segmentation');
            return
        end
        seconds = toc;
        close(busy);

        showImage(predAxes, label2rgb(L, colours, 'k'), 'after fine-tuning (CamVid classes)');
        showImage(overlayAxes, labeloverlay(I, L, 'Colormap', colours, 'Transparency', 0.4), 'after fine-tuning, over the image');

        % the VOC classes that cover at least 1% of the image, so the title says what the colours mean
        found = {};
        for k = 1:numel(vocNames)
            share = mean(Lbefore(:) == k);
            if share >= 0.01
                found{end + 1} = sprintf('%s %.0f%%', vocNames{k}, 100 * share); %#ok<AGROW>
            end
        end
        showImage(beforeAxes, label2rgb(Lbefore, vocColours), ...
            {'before fine-tuning (VOC classes)', strjoin(found, ', ')});

        [~, name, ext] = fileparts(imageList.Value);
        truth = findTruth(imageList.Value);
        compare = 'no ground truth';
        if ~isempty(truth)
            valid = truth > 0;
            compare = sprintf('pixel accuracy vs ground truth %.1f %%', 100 * mean(L(valid) == truth(valid)));
        end
        status.Text = sprintf('%s%s | %s | %.1f s | DeepLabV3-MobileNetV3 fine-tuned on CamVid, test mIoU %.1f %%, test accuracy %.1f %%', ...
            name, ext, compare, seconds, 100 * testMIoU, 100 * testAccuracy);
    end

    % ground truth sits in ../labels with the same file name, [] if there is none
    function truth = findTruth(imagePath)
        [folder, name, ext] = fileparts(imagePath);
        labelPath = fullfile(fileparts(folder), 'labels', [name ext]);
        truth = [];
        if exist(labelPath, 'file')
            truth = loadLabels(labelPath);
        end
    end
end
