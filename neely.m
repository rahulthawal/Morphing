
function IWarp = neely(I, dim, source_line, target_line, scan_line, bilinear)

Dimension_I=size(I);

%% Number of control lines
num = size(source_line,1);
if num ~= size(target_line,1)
   error('srcline and dstline must have same number of rows');
end

%%
a = 0.000000000001;
b = 2;
p = 0;

%% precalculate values of the Y loop.

SCALE = [Dimension_I(2)/dim(2) Dimension_I(1)/dim(1)];

QPD = target_line(:,3:4)-target_line(:,1:2);

PERP_QPD = perp(QPD);

LENGTH2_QPD = sum(QPD.*QPD,2);

LENGTH_QPD = sqrt(LENGTH2_QPD);

QPS = source_line(:,3:4)-source_line(:,1:2);

PERP_QPS = perp(QPS);

LENGTH2_QPS = sum(QPS.*QPS,2);

LENGTH_QPS = sqrt(LENGTH2_QPS);

%% REPLICATING ABOVE MATRIX  

scale_rep=repmat(SCALE,dim(2)*num,1);

scaleindex=repmat(SCALE,dim(2),1);

length2_qpd=repmat(LENGTH2_QPD,dim(2),1);

length_qpd=repmat(LENGTH_QPD,dim(2),1);

qpd=repmat(QPD,dim(2),1);

perp_qpd=repmat(PERP_QPD,dim(2),1);

Pd=repmat(target_line(:,1:2),dim(2),1);

Qd=repmat(target_line(:,3:4),dim(2),1);

length2_qps=repmat(LENGTH2_QPS,dim(2),1);

length_qps=repmat(LENGTH_QPS,dim(2),1);

qps=repmat(QPS,dim(2),1);

perp_qps=repmat(PERP_QPS,dim(2),1);

Ps=repmat(source_line(:,1:2),dim(2),1);

%% Destination matrix
IWarp = uint8(zeros(dim(1),dim(2),dim(3)));

Xindex = linspace(1,dim(2),dim(2))';
Xindex = Xindex .* scaleindex(:,1);

%% CREATING IMAGES FOR MAPPING

xx=ones(num,1);
for i=2:dim(2)
   t = linspace(i,i,num)';
   xx = [xx;t];
end

subplot(1,1,1);
imshow(IWarp);

% Loop over y
for y = 1:scan_line:dim(1)
    
   Yindex = linspace(y,y,dim(2))';
   Yindex = Yindex .* scaleindex(:,2);
   yy = linspace(y,y,dim(2)*num)';
   
   Xd=[xx yy].*scale_rep;
   xpd=Xd-Pd;
   xqd=Xd-Qd;
   xpdlength = sqrt(sum(xpd.*xpd,2));
   xqdlength = sqrt(sum(xqd.*xqd,2));
   
   %% CALCULATING u,v and other variables.
   u=sum(xpd.*qpd,2)./length2_qpd;
   v=sum(xpd.*perp_qpd,2)./length_qpd;
   
  
   aa = qps.*[u u];
   bb = perp_qps.*[v v]./[length_qps length_qps];
   Xs = Ps + aa + bb;
   %% shortest distance.
   D = Xs - Xd;
   
   dist1=(u<0).*xpdlength;
   dist2=(u>=0 & u<=1).*abs(v);
   dist3=(u>1).*xqdlength;
   dist = dist1+dist2+dist3;
   
   %% calculate weight, dsum.
   weight = (length_qpd.^p)./((a+dist).^b);
   dsum = D.*[weight weight];
   
   if num > 1
      ddsum = sum(reshape(dsum,num,dim(2),2));
      ddsum = reshape(ddsum,dim(2),2,1);
      weightsum = sum(reshape(weight,num,dim(2)))';
   else
      ddsum = dsum;
      weightsum = weight;
   end

   IMAGE_INDEX = ([Xindex Yindex] + ddsum./[weightsum weightsum]);
   %% Map
   X_Image = IMAGE_INDEX(:,1);
   Y_Image = IMAGE_INDEX(:,2);
   
   if X_Image<1
        X_Image1 = 1;
   else if X_Image>Dimension_I(2)
           X_Image2 = Dimension_I(2);
    else if (X_Image>=1)
               if X_Image<=Dimension_I(2)
                    X_Image3 = X_Image;
               end
       end
       end
   end
   
   X_Image = X_Image1 + X_Image2 + X_Image3;
   if Y_Image<1
        Y_Image1 = 1;
   else if Y_Image>Dimension_I(1)
           Y_Image2 = Dimension_I(1);
       else if (Y_Image>=1)
               if Y_Image<=Dimension_I(1)
                    Y_Image3 = Y_Image;
               end
           end
       end
   end
   Y_Image = Y_Image1 + Y_Image2 + Y_Image3;

  %% BILINEAR CALCULATION 
   if bilinear == 0 % simple round
      XX_Image = ceil(X_Image);
      YY_Image = ceil(Y_Image);
      

      
      % Don't want this loop.  Use commented trick above.
      for x = 1:dim(2)
         IWarp(y,x,:) = I(YY_Image(x),XX_Image(x),:);
      end
   else % bilinear filter
      IMAGE_INDEX = [X_Image Y_Image];
      
      X1 = floor(X_Image);
      Y1 = floor(Y_Image);
      X2 = ceil(X_Image);
      Y2 = ceil(Y_Image);
      
      d1 = IMAGE_INDEX - [X1 Y1];
      d2 = IMAGE_INDEX - [X1 Y2];
      d3 = IMAGE_INDEX - [X2 Y1];
      d4 = IMAGE_INDEX - [X2 Y2];
      
      dd1 = sqrt(sum(d1.*d1,2));
      dd2 = sqrt(sum(d2.*d2,2));
      dd3 = sqrt(sum(d3.*d3,2));
      dd4 = sqrt(sum(d4.*d4,2));
      wsum = dd1+dd2+dd3+dd4;
      
      % Now do a weighted sum
      C = zeros(dim(2),3);
      for x = 1:dim(2)
         c1(1:3) = I(Y1(x), X1(x), :);
         c2(1:3) = I(Y1(x), X2(x), :);
         c3(1:3) = I(Y2(x), X1(x), :);
         c4(1:3) = I(Y2(x), X2(x), :);
         if( wsum(x) > 0 )
            C(x,:) = double(c1)*dd1(x) + double(c2)*dd2(x) + ...
                     double(c3)*dd3(x) + double(c4)*dd4(x);
                  C(x,:) = C(x,:)/wsum(x);
         else
            C(x,:) = I(Y2(x),X2(x));
         end
         IWarp(y,x,:) = C(x,:);
      end
   end
   

end

subplot(1,1,1);
imshow(IWarp);
drawnow;