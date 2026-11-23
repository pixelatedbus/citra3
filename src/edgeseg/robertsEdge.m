function [BW, mag, T] = robertsEdge(I, T)
Kx = [1 0 0; 0 -1 0; 0 0 0];
Ky = [0 1 0; -1 0 0; 0 0 0];
[BW, mag, T] = gradientEdge(I, Kx, Ky, T);
end
