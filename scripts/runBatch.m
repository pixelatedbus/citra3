% runs edge segmentation and split & merge on every test image and saves the figures in results/batch/
clear; close all;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(root, 'src')));

dataDir = fullfile(root, 'data', 'bsds500_test_8');
outDir = fullfile(root, 'results', 'batch');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

methods = {'sobel', 'prewitt', 'roberts', 'laplace', 'log', 'canny'};

% edge segmentation
opt.fudge = 0.5;
opt.smooth = 0;
opt.sigma = 2;
opt.dilate = 3;
opt.clearBorder = false;
opt.erode = 2;
opt.keep = 'largest';

% split & merge
T = 0.05;
Tm = 0.12;
minSize = 2;
minArea = 64;

files = dir(fullfile(dataDir, '*.jpg'));
for k = 1:numel(files)
    [~, name] = fileparts(files(k).name);
    I = loadImage(fullfile(dataDir, files(k).name));
    fprintf('%s\n', name);

    fig = figure('Visible', 'off', 'Position', [0 0 1200 1500]);
    for m = 1:numel(methods)
        [mask, BW] = segmentByEdges(I, methods{m}, opt);
        subplot(numel(methods), 3, 3*m - 2); imshow(I); title(methods{m});
        subplot(numel(methods), 3, 3*m - 1); imshow(BW); title('edges');
        subplot(numel(methods), 3, 3*m);     imshow(I .* mask); title('segmented');
    end
    saveas(fig, fullfile(outDir, [name '_edge.png']));
    close(fig);

    tic;
    [L, Lsplit] = splitMerge(I, T, Tm, minSize, minArea);
    fprintf('  split %d -> merge %d regions (%.1f s)\n', max(Lsplit(:)), max(L(:)), toc);

    fig = figure('Visible', 'off', 'Position', [0 0 1600 400]);
    subplot(1, 4, 1); imshow(I); title('image');
    subplot(1, 4, 2); imshow(label2rgb(Lsplit, 'jet', 'k', 'shuffle')); title('after split');
    subplot(1, 4, 3); imshow(label2rgb(L, 'jet', 'k', 'shuffle')); title('after merge');
    subplot(1, 4, 4); imshow(labelMeanColor(I, L)); title('mean colour');
    saveas(fig, fullfile(outDir, [name '_splitmerge.png']));
    close(fig);
end
