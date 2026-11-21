% checks whether a block is flat enough in colour to leave it unsplit
function ok = isHomogeneous(R, T)
% R: double h x w x c, one block of the image
% T: double scalar, max std
% ok: logical scalar, true = homogeneous
% every colour channel must have std <= T
ok = max(std(R, 1, [1 2])) <= T;
end
