function [ciliaIdx, candiBox, ciliaBw, ciliaScore, ciliaDirection] = ...
    ciliaSelection(bw, minCiliaLength, maxCiliaLength, angleSlice)
% process a binary image to generate a cilia map
%

% define parameters
if nargin < 4
    angleSlice = 12; % devide 180 degree into 12 parts
end
parAngle = 180/angleSlice;
directionThres = 0.1; % the region score above threshold is cilia

% label image
imCC = bwconncomp(bw);
ciliaBw = bw;
candiNum = imCC.NumObjects;
candiBox = zeros(candiNum,4); % storage [x,y,w,h], (x,y) is top left coordinate 

% loop over candidate component
ciliaIdx = 1 : 1 : candiNum;
ciliaDirection = zeros(candiNum,1);
ciliaScore = zeros(candiNum,1);
isLong = false(candiNum,1);
erodeImage = repmat(bw,1,1,angleSlice);
% get eroded image
for i = 1 : angleSlice
    erodeImage(:,:,i) = imerode(erodeImage(:,:,i),...
        strel('line',minCiliaLength,i*parAngle));
end
% get box and area
ciliaBbox = regionprops(ciliaBw,'BoundingBox');
ciliaArea = regionprops(ciliaBw,'Area');
for i = 1 : candiNum
    % get box
    candiBox(i,:) = ceil(ciliaBbox(i).BoundingBox);
    box = [candiBox(i,2),min(candiBox(i,2)+candiBox(i,4),size(bw,1)),...
        candiBox(i,1),min(candiBox(i,1)+candiBox(i,3),size(bw,2))];
    % calculate direction score
    erodeRegion = erodeImage(box(1):box(2),box(3):box(4),:);
    directionScore = reshape(sum(sum(erodeRegion)) / ciliaArea(i).Area,[angleSlice,1,1]);
    % record score, direction and length
    [maxscore,ind] = max(directionScore(:));
    ciliaScore(i) = maxscore;
    ciliaDirection(i) = ind;
    isLong(i) = candiBox(i,3) < maxCiliaLength & ...
        candiBox(i,4) < maxCiliaLength;
end
flag = ciliaScore > directionThres & isLong;
falseIdx = ciliaIdx(~flag);
for k = 1 : length(falseIdx)
    ciliaBw(imCC.PixelIdxList{falseIdx(k)}) = 0;
end
ciliaIdx = ciliaIdx(flag);


end
