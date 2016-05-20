
function Imorph = warping(SOURCE, TARGET, ~, ~, DIMENSION, ...
   SOURCE_LINE, TARGET_LINE, CONTROL_LINE, SCAN_LINE,...
   MORPH_P, bilinear)

X = 2;
Y = 1;
NUM = size(SOURCE_LINE,1);

%% Scaling the dimensions because source image and target image can be of different size.

Dimension_1 = size(SOURCE); % Dimension of Source i.e First Image
Dimension_2 = size(TARGET); % Dimension of Target i.e Second Image
Scale1_Destination = [DIMENSION(X)/Dimension_1(X) DIMENSION(Y)/Dimension_1(Y) DIMENSION(X)/Dimension_1(X) DIMENSION(Y)/Dimension_1(Y)];
Scale2_Destination = [DIMENSION(X)/Dimension_2(X) DIMENSION(Y)/Dimension_2(Y) DIMENSION(X)/Dimension_2(X) DIMENSION(Y)/Dimension_2(Y)];

%% Interpolating

Line = 1;
for l = 1:NUM
  
      % Scale lines to the Destination image
      S1 = SOURCE_LINE(l,:);
      S2 = TARGET_LINE(l,:);
      SCALED_LINE1 = S1.*Scale1_Destination;
      SCALED_LINE2 = S2.*Scale2_Destination;
      
      %% Figure out the average line
      MIDPOINT = SCALED_LINE1*(1-MORPH_P)+SCALED_LINE2*(MORPH_P);
      
      %% Scale the average back to the respective src dimensions
      MIDPOINT_1 = MIDPOINT./Scale1_Destination;
      MIDPOINT2 = MIDPOINT./Scale2_Destination;
      
      %% Points when Morphing goes from left to right.
      Source1(Line,1:4)=S1;
      Source2(Line,1:4)=S2;
      
      MID1(Line,1:4)=MIDPOINT_1;
      MID2(Line,1:4)=MIDPOINT2;
      
      Line = Line + 1;
  
end

MID1;
MID2;

NUM = Line-1;

DIMENSION = [DIMENSION 3];

 %% Warp both images using the same lines
 DIMENSION = [DIMENSION 3];
 figure;
 fprintf('Warp Source Image \n');
 
 SOURCE_WARP = neely(SOURCE, DIMENSION, Source1, MID1, SCAN_LINE, bilinear);
 fprintf('Done \n');
 fprintf('continue...\n');
 pause;
 
 figure;
 fprintf('Warp Target Image \n');
 TARGET_WARP = neely(TARGET, DIMENSION, Source2, MID2, SCAN_LINE, bilinear);
 fprintf('Done \n');
 fprintf('continue...\n');
 pause;


%% Crossfade
fprintf('Final Output...\n');
Imorph = zeros(DIMENSION(1),DIMENSION(2),DIMENSION(3));

Imorph = double(SOURCE_WARP)*(1-MORPH_P) + double(TARGET_WARP)*(MORPH_P);
figure;
subplot(1,1,1);
imshow(Imorph/255);
fprintf('done\n');