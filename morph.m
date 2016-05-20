

function Imorph = morph(source, target, final, ...
control_lines, scan_line, percen, ...
savefile, save,bilinear)


%% Loading Control Points.
load(savefile,'picture');
picture(:).lineseg
figure;

imshow(picture(1).I);
figure;
imshow(picture(2).I);

fprintf('Control Points are selected by user now press Enter to start warping \n');
fprintf('Enter');
pause;

%% WARPING START

Imorph = warping(picture(1).I, picture(2).I, 0, 0, final, ...
   picture(1).lineseg, picture(2).lineseg, control_lines, ...
   scan_line, percen, bilinear);