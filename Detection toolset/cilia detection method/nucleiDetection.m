
function nucleiBw = nucleiDetection(rawIm, minNucleiArea, edgeFactor, minConcaveArea)
%

%% read image 
if ischar(rawIm)
    % read image
    rawIm = imread(rawIm);
end
if size(rawIm,3) == 3
    rawIm = rawIm(:,:,3);
end
rawIm = im2double(rawIm);


% parse input arguments
if nargin < 2
    minNucleiArea = 3000;
end
if nargin < 3
    edgeFactor = 0.5;
end
if nargin < 4
    minConcaveArea = 30;
end


%% pre-processing
% remove white bar
if size(rawIm, 1) == 1000 && size(rawIm, 2) == 1000
    whileBarSurroundBg = (rawIm(963,:) + rawIm(974, :)) / 2;
    rawIm(964:973, 8:621) = repmat(whileBarSurroundBg(8:621), [10,1]);
    scaleBarSurroundBg = (rawIm(982,:) + rawIm(993, :)) / 2;
    rawIm(982:993, 291:339) = repmat(scaleBarSurroundBg(291:339), [12,1]); 
end

% filtering
diskFilterH = getnhood(strel('disk', 6));
diskFilterH(1:2,:) = 0;
diskFilterH(end-1:end,:) = 0;
diskFilterH = double(diskFilterH) / sum(diskFilterH(:));
diskFilterV = getnhood(strel('disk',10));
diskFilterV(:,1:2) = 0;
diskFilterV(:,end-1:end) = 0;
diskFilterV = double(diskFilterV) / sum(diskFilterV(:));
rawIm = imfilter(rawIm, diskFilterH, 'symmetric');
rawIm = imfilter(rawIm, diskFilterV, 'symmetric');

% brightness adjustment
histNum = imhist(rawIm);
[~,ind] = sort(histNum,'descend');
ind = ind(1:2);
bg = sum((ind-1)/255.*histNum(ind)) / sum(histNum(ind));
lowIn = 0.8 * bg;
highIn = max(rawIm(:));
if lowIn < highIn
    histIm = imadjust(rawIm, [0.8*bg, max(rawIm(:))], [0.001,1]);
end
histIm = imsharpen(histIm);
histIm = imfilter(histIm, fspecial('gaussian',[3,3],2));


%% binarization
% find edge
[~, thres] = edge(histIm, 'canny');
edgeBw = edge(histIm, 'canny', thres * edgeFactor);
edgeBw(:,999) = 0;

% dilation
edgeBw = imdilate(edgeBw, [strel('line',3,90), strel('line',3,0)]);
edgeBw = imdilate(edgeBw, strel('arbitrary', diskFilterH));
edgeBw = imfill(edgeBw, 'holes');
edgeBw = imerode(edgeBw, strel('diamond',3));
edgeBw = bwareaopen(edgeBw, minNucleiArea);
edgeBw = imclose(edgeBw, strel('disk',7));
% edgeBw = imopen(edgeBw, strel('disk',8));
edgeBw = imfill(edgeBw, 'holes');

% fill bound
edgeBw(1,:) = 1;
edgeBw(end,:) = 1;
edgeBw(:,1) = 1;
edgeBw(:,end) = 1;
edgeBw(1, end/2) = 0;
edgeBw(end, end/2) = 0;
edgeBw(end/2, 1) = 0;
edgeBw(end/2, end) = 0;
edgeBw = imfill(edgeBw, 'holes');
edgeBw(1,:) = 0;
edgeBw(end,:) = 0;
edgeBw(:,1) = 0;
edgeBw(:,end) = 0;

%% find concave points
regprops = regionprops(edgeBw, 'BoundingBox', 'ConvexImage', 'Image');
refinedBw = zeros(size(edgeBw));
seDisk12 = strel('disk', 12);
for k = 1 : size(regprops, 1)
    concaveRegion = regprops(k).ConvexImage - regprops(k).Image;
    concaveRegion = bwareaopen(concaveRegion, minConcaveArea);
    concaveRegion = imclose(concaveRegion, seDisk12);
    restRegion = regprops(k).ConvexImage - concaveRegion;
    restRegion(restRegion < 0) = 0;
    regBB = round(regprops(k).BoundingBox);
    refinedBw(regBB(2) : (regBB(2) + regBB(4) - 1), ...
        regBB(1) : (regBB(1) + regBB(3) - 1)) = ...
        refinedBw(regBB(2) : (regBB(2) + regBB(4) - 1), ...
        regBB(1) : (regBB(1) + regBB(3) - 1)) | restRegion;
end
% area filtering
refinedBw = bwareaopen(refinedBw, minNucleiArea, 4);

%
regprops = regionprops(refinedBw, 'BoundingBox', 'ConvexImage', 'Image');
nucleiBw = zeros(size(refinedBw));
for k = 1 : size(regprops, 1)
    pointProps = findConcavePoint(regprops(k).Image, ...
        regprops(k).ConvexImage);
    sepBw = separateCell(regprops(k).Image, pointProps);
    regBB = round(regprops(k).BoundingBox);
    nucleiBw(regBB(2) : (regBB(2) + regBB(4) - 1), ...
        regBB(1) : (regBB(1) + regBB(3) - 1)) = ...
        nucleiBw(regBB(2) : (regBB(2) + regBB(4) - 1), ...
        regBB(1) : (regBB(1) + regBB(3) - 1)) | sepBw;
end
% area filtering
nucleiBw = bwareaopen(nucleiBw, minNucleiArea, 4);

end

function pointsProp = findConcavePoint(ccObj, hull)
%

% define some constant
step = 20;
minPeakHeight = 3.5;
minPeakDistance = 20;
regRadius = 10;
distThres = 2.5;
hullDistThres = 12;

% get object's boundary
bound = bwboundaries(ccObj);
bound = bound{1};
boundMap = zeros(size(ccObj));
for k = 1 : length(bound(:,1))
    boundMap(bound(k,1),bound(k,2)) = 1;
end
boundLen = length(bound(:,1));
objDistMap = bwdist(ccObj);

% if the point is cent
ratio = zeros(1, boundLen);
for k = 1 : boundLen
    triPoint = zeros(3,2);
    triPoint(1,:) = bound(k,:);
    triPoint(2,:) = bound(mod(k-step, boundLen) + 1, :);
    triPoint(3,:) = bound(mod(k+step, boundLen) + 1, :);
    centralPoint = round(sum(triPoint, 1) / 3);
    ratio(k) = objDistMap(centralPoint(1), centralPoint(2));
end

[~, loc] = findpeaks(ratio, 1:boundLen, 'minPeakHeight', minPeakHeight, ...
    'minPeakDistance', minPeakDistance);
concavePoints = bound(loc,:);

% refinement step 1
cpDist = zeros(1, size(concavePoints, 1));
for k = 1 : size(concavePoints, 1)
    cP = concavePoints(k,:);
    region = ccObj(cP(1) - regRadius : cP(1) + regRadius,...
        cP(2) - regRadius : cP(2) + regRadius);
    regHull = bwconvhull(region);
    hullBound = bwboundaries(regHull);
    hullBound = hullBound{1};
    hullBoundMap = zeros(size(hullBound));
    for i = 1 : size(hullBound,1)
        hullBoundMap(hullBound(i,1), hullBound(i,2)) = 1;
    end
    dist = bwdist(hullBoundMap);
    cpDist(k) = dist(regRadius + 1, regRadius + 1);
end
concavePoints = concavePoints(cpDist > distThres, :);
loc = loc(cpDist > distThres);

% refinement step 2
hullDist = zeros(1, size(concavePoints, 1));
hullBound = bwboundaries(hull);
hullBound = hullBound{1};
hullBoundMap = zeros(size(hull));
for k = 1 : size(hullBound, 1)
    hullBoundMap(hullBound(k,1), hullBound(k,2)) = 1;
end
hullDistMap = bwdist(hullBoundMap);
for k = 1 : size(concavePoints, 1)
    hullDist(k) = hullDistMap(concavePoints(k,1), concavePoints(k,2));
end
concavePoints = concavePoints(hullDist > hullDistThres, :);
loc = loc(hullDist > hullDistThres);

% get the direction of extending line
pointsProp = zeros(size(concavePoints,1), 4);
for k = 1 : size(concavePoints, 1)
    ind = loc(k);
    tempVec1 = bound(mod(ind - step, boundLen) + 1, :) - bound(ind, :);
    tempVec2 = bound(mod(ind + step, boundLen) + 1, :) - bound(ind, :);
    extendDirection = -(tempVec1 / norm(tempVec1) + tempVec2 / norm(tempVec2));
    extendDirection = extendDirection / norm(extendDirection);
    pointsProp(k, :) = [bound(ind,:), extendDirection];
end

end

% separate overlapped cell using concave points and the direction of
% extended line
function nucleiBw = separateCell(nucleiBw, pointProps)
% nucleiBw -- the binarized image of nucleis
% pointPros -- store the concave points' position and direction

% get paras and define constant
[imH, imW] = size(nucleiBw);
pointPosi = pointProps(:,1:2);
pointDire = pointProps(:,3:4);
maxIncludeAngle = 40 / 180 * pi;
maxCorrPointDist = 150;
angleThres = sqrt(2 - 2 * cos(maxIncludeAngle));

% connect corresponding concave points
ind = 1;
while(ind < size(pointPosi, 1))
    % find corresponding concave point
    pointsNum = size(pointPosi, 1);
    includedAngle = zeros(1, pointsNum - ind);
    for k = ind + 1 : pointsNum
        includedAngle(k - ind) = norm(pointDire(ind,:) + pointDire(k,:));
    end
    % find the angle smaller than maxIncludeAngle
    [~, tempInd] = find(includedAngle < angleThres);
    tempInd = tempInd + ind;
    if ~isempty(tempInd)
       dist = zeros(1, length(tempInd));
       for k = 1 : length(tempInd)
           dist(k) = norm(pointPosi(ind,:) - pointPosi(tempInd(k),:));
       end
       % preserve the point with min distance from current point
       flag = dist < maxCorrPointDist;
       dist = dist(flag);
       tempInd = tempInd(flag);
       if ~isempty(dist)
           [~, connectedInd] = min(dist);
           connectedInd = tempInd(connectedInd);
           nucleiBw = connectPoint(pointPosi(ind, :), pointPosi(connectedInd, :), nucleiBw);
           % delete
           pointPosi([ind, connectedInd],:) = [];
           pointDire([ind, connectedInd],:) = [];
       else
           ind = ind + 1;
       end
    else
        ind = ind + 1;
    end
end

% find the rest point's line
pointsNum = size(pointPosi, 1);
sepLine = zeros(pointsNum, 4);
for k = 1 : pointsNum
    % get start point and extended direction
    startX = pointPosi(k,1);
    startY = pointPosi(k,2);
    extendX = pointDire(k,1);
    extendY = pointDire(k,2);
    % define extended count
    count = 1;
    posiX = startX;
    posiY = startY;
    while(true)
        % store old point and get next point
        oldPosiX = posiX;
        oldPosiY = posiY;
        posiX = round(startX + count * extendX);
        posiY = round(startY + count * extendY);
        if posiX < 1 || posiX > imH || posiY < 1 || posiY > imW
            break;
        elseif ~isequal([posiX, posiY], [oldPosiX, oldPosiY]) && ...
                nucleiBw(posiX, posiY) == 0
            break;
        else
            count = count + 1;
        end
    end
    sepLine(k,:) = [pointPosi(k,:), oldPosiX, oldPosiY];
end

% break line if it intersect with other line
intersectPoint = zeros(pointsNum, 2 * pointsNum);
intersectLen = ones(pointsNum, pointsNum) * Inf;
% find the point of intersection
for i = 1 : pointsNum
    k1 = (sepLine(i, 4) - sepLine(i, 2)) / (sepLine(i, 3) - sepLine(i, 1) + 1e-4);
    len1 = norm(sepLine(i,1:2) - sepLine(i,3:4));
    for j = i+1 : pointsNum
        k2 = (sepLine(j, 4) - sepLine(j, 2)) / (sepLine(j, 3) - sepLine(j, 1) + 1e-4);
        interX = (k1 * sepLine(i,1) - sepLine(i,2) - k2 * sepLine(j,1) + ...
            sepLine(j,2)) / (k1 - k2 + 1e-4);
        interY = k1 * (interX - sepLine(i,1)) + sepLine(i,2);
        intersectPoint(i, 2*j-1 : 2*j) = [interX, interY];
        % it is valid if the point of intersection between two end points
        len2 = norm(sepLine(i,1:2) - [interX, interY]);
        len3 = norm(sepLine(i,3:4) - [interX, interY]);
        if len2 < len1 + 1 && len3 < len1 + 1
            intersectLen(i,j) = len2;
        end
    end
end
%
while(~isempty(intersectLen))
    [minLen, minInd] = min(intersectLen(:));
    if minLen ~= Inf
        % get row and col
        col = ceil(minInd / pointsNum);
        row = mod(minInd, pointsNum);
        % set Inf
        intersectLen(row,:) = Inf;
        intersectLen(col,:) = Inf;
        % change sepLine
        sepLine(row, 3:4) = round(intersectPoint(row, 2*col-1 : 2*col));
        sepLine(col, 3:4) = round(intersectPoint(row, 2*col-1 : 2*col));
    else
        break;
    end
end
% connect line
for k = 1 : pointsNum
    nucleiBw = connectPoint(sepLine(k,1:2), sepLine(k,3:4), nucleiBw);
end

end

function bw = connectPoint(point1, point2, bw)
% connect two points in bw

%
tempVec = point2 - point1;
[vecLen, ind1] = max(abs(tempVec));
if ind1 == 1
    ind2 = 2;
else
    ind2 = 1;
end
k = tempVec(ind2) / tempVec(ind1);
lineObj = zeros(vecLen, 2);
lineObj(:, ind1) = 1 : 1 : vecLen;
lineObj(:, ind1) = sign(tempVec(ind1)) * lineObj(:, ind1);
lineObj(:, ind2) = point1(ind2) + round(lineObj(:, ind1) * k);
lineObj(:, ind1) = lineObj(:, ind1) + point1(ind1);
% 3x3 region
lineObj = cat(1, lineObj, [lineObj(1:vecLen, 1) - 1, lineObj(1:vecLen, 2) - 1]);
lineObj = cat(1, lineObj, [lineObj(1:vecLen, 1) - 1, lineObj(1:vecLen, 2)]);
lineObj = cat(1, lineObj, [lineObj(1:vecLen, 1) - 1, lineObj(1:vecLen, 2) + 1]);
lineObj = cat(1, lineObj, [lineObj(1:vecLen, 1), lineObj(1:vecLen, 2) - 1]);
lineObj = cat(1, lineObj, [lineObj(1:vecLen, 1), lineObj(1:vecLen, 2) + 1]);
lineObj = cat(1, lineObj, [lineObj(1:vecLen, 1) + 1, lineObj(1:vecLen, 2) - 1]);
lineObj = cat(1, lineObj, [lineObj(1:vecLen, 1) + 1, lineObj(1:vecLen, 2)]);
lineObj = cat(1, lineObj, [lineObj(1:vecLen, 1) + 1, lineObj(1:vecLen, 2) + 1]);
% check boundary
lineObj(lineObj == 0) = 1;
x = lineObj(:,1);
x(x == size(bw,1) + 1) = size(bw, 1);
lineObj(:,1) = x;
y = lineObj(:,2);
y(y == size(bw,2) + 1) = size(bw, 2);
lineObj(:,2) = y;
% convert to index
lineObj = lineObj(:,1) + size(bw,1) * (lineObj(:,2) - 1);
% set to zero
bw(lineObj) = 0;


end

