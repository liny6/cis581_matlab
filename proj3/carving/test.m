I = imread('hotpot.jpg');

imshow(I)

for i = 1:200
e=genEngMap(I);

[Mx, Tbx] = cumMinEngVer(e);

[My, Tby] = cumMinEngHor(e);

%[I, E] = rmHorSeam(I, My, Tby);

[I, E] = rmVerSeam(I, Mx, Tbx);

imshow(I)
end