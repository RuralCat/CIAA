function [ciliaBw,idx,snrRatio,directionRatio] = eliminateFP(im, ciliaIdx,...
    ciliaBw, ciliaBox, ciliaDirection, snrThres, directionThres, angleSlice)
% eliminate the edge false positive
%

% adjustable parameter
if nargin < 6
    snrThres = 1.3;
    directionThres = 0.05;
    angleSlice = 12;
end

% get and define some paras
[h,w] = size(im);
ciliaNum = length(ciliaIdx);
idx = ciliaIdx;
parAngle = 180/angleSlice;
se = cell(angleSlice,1);
for i = 1 : angleSlice
    se{i} = strel('line',10,i*parAngle);
end
snrRatio = zeros(ciliaNum,1);
directionRatio = zeros(ciliaNum,1);

% hint: cilia intensity greater than backgroud
padl = 3;
isFP = false(ciliaNum,1);
dilateRegion1 = imdilate(ciliaBw,strel('disk',1));
dilateRegion2 = imdilate(ciliaBw,strel('disk',2));
for i = 1 : ciliaNum
    % get box  
    x0 = max(ciliaBox(idx(i),2)-padl,1);
    x1 = min(ciliaBox(idx(i),2)+ciliaBox(idx(i),4)+padl,h);
    y0 = max(ciliaBox(idx(i),1)-padl,1);
    y1 = min(ciliaBox(idx(i),1)+ciliaBox(idx(i),3)+padl,w);
    % get im&bw region
    localRegion = im(x0:x1, y0:y1);
    bwLocalRegion = ciliaBw(x0:x1, y0:y1);
    % cilia center
    bwCilia = imerode(bwLocalRegion,se{ciliaDirection(idx(i))});
    % bg
    bwLocalDilate1 = dilateRegion1(x0:x1, y0:y1);
    bwLocalDilate2 = dilateRegion2(x0:x1, y0:y1);
    bwBg = logical(bwLocalDilate2-bwLocalDilate1);
    % cilia mean
    ciliaMean = mean(localRegion(bwCilia));
    % bg mean
    bgMean = mean(localRegion(bwBg));
    % cilia > bg
    snrRatio(i) = ciliaMean / bgMean;
    % isFP(i) = ~isnan(snrRatio(i)) & snrRatio(i) > snrThres;
end

% idx = idx(isFP);
% return;

% hint: cilia box could keep direction in original image
ciliaNum = length(idx);
padl = 0;
isFP = false(ciliaNum,1);
for i = 1 : ciliaNum
    % get region
    x0 = max(ciliaBox(idx(i),2)-padl,1);
    x1 = min(ciliaBox(idx(i),2)+ciliaBox(idx(i),4)+padl,h);
    y0 = max(ciliaBox(idx(i),1),1);
    y1 = min(ciliaBox(idx(i),1)+ciliaBox(idx(i),3)+padl,w);
    region = im(x0:x1,y0:y1);
    % do local adjust 
    regionLocal = localAdjust(region);
    regionLocalBw = im2bw(regionLocal,0.01);
    % get direction score
    erodeRegion = imerode(regionLocalBw,se{ciliaDirection(idx(i))});
    directionRatio(i) = sum(erodeRegion(:)) / sum(regionLocalBw(:));
    % max_score shoule greater than directionthres
    % isFP(i) = ~isnan(directionRatio) & (directionRatio > directionThres);
end

% idx = idx(isFP);
end


