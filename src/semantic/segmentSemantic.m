function [L, Lbefore] = segmentSemantic(I, pythonExe, scriptPath)
% I: double m x n x 3 (or m x n), values in [0,1], input image
% pythonExe: char, python with torch installed (the project's .venv)
% scriptPath: char, path of src/semantic/python/predict.py
% L: double m x n, class 1..11 (see camvidClasses)
% Lbefore: double m x n, class 1..21 from the same network before fine-tuning (see vocClasses)
inFile = [tempname '.png'];
outFile = [tempname '.png'];
beforeFile = [tempname '.png'];
imwrite(I, inFile);

% one python run gives both results, starting python is the slow part
command = sprintf('"%s" "%s" "%s" "%s" "%s"', pythonExe, scriptPath, inFile, outFile, beforeFile);
[status, output] = system(command);
delete(inFile);
if status ~= 0
    error('predict.py failed:\n%s', output);
end

L = double(imread(outFile));
Lbefore = double(imread(beforeFile));
delete(outFile);
delete(beforeFile);
end
