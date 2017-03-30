
function [ske, skeLen] = measureCiliaLength(region)
% method to get cilia skeleton and length

% processing on hist_im and enhanced this region
enhancedIm = localAdjust(region);
enhancedIm = medfilt2(enhancedIm, [3,3]);
bwIm = im2bw(enhancedIm, 0.02);
bwIm = bwareaopen(bwIm, 20);
meanI = mean(enhancedIm(bwIm));
enhancedIm(enhancedIm < meanI) = 0;

% find edge threshold
[~, thres] = edge(enhancedIm, 'sobel');
fugeFactor = 0.5;

% find edge and subtract isolate point
bwIm = edge(enhancedIm, 'sobel', thres * fugeFactor);
bwIm = bwareaopen(bwIm, 10);

% dilation to get entire object
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
bwIm = imdilate(bwIm, [se90, se0]);

% erosion
seD = strel('diamond', 1);
bwIm = imerode(bwIm, seD);
bwIm = bwareafilt(bwIm, 1);
bwIm = imfill(bwIm, 'holes');

% find coarse skeleton map
coarseSkeMap = bwmorph(bwIm, 'skel', Inf);
coarseSkeMap(1, :) = 0;
coarseSkeMap(end, :) = 0;
coarseSkeMap(:, 1) = 0;
coarseSkeMap(:, end) = 0;

% find adjacent points
adjPoint = countAdjacentPoint(double(coarseSkeMap));

% remove branch
adjPoint = removeBranch(adjPoint);

% get fine skeleton map
[pX, pY] = find(coarseSkeMap == 1);
ind = find(adjPoint(:,1) == -1);
for k = 1 : length(ind)
    coarseSkeMap(pX(ind(k)), pY(ind(k))) = 0;
end
fineSkeMap = bwareafilt(coarseSkeMap, 1);

% extend skeleton map
[pX, pY] = find(fineSkeMap == 1);
adjPoint = countAdjacentPoint(double(fineSkeMap));
endPointInd = find(adjPoint(:,1) == 1);
for k = 1 : 2
    formerInd = adjPoint(endPointInd(k), 2);
    shiftX = pX(endPointInd(k)) - pX(formerInd);
    shiftY = pY(endPointInd(k)) - pY(formerInd);
    nextPoint = [pX(endPointInd(k)) + shiftX, pY(endPointInd(k)) + shiftY]; 
    while(bwIm(nextPoint(1), nextPoint(2)) == 1)
        if nextPoint(1) <= 1 || nextPoint(1) >= size(region, 1) || ...
            nextPoint(2) <= 1 || nextPoint(2) >= size(region, 2)
            break;
        end
        fineSkeMap(nextPoint(1), nextPoint(2)) = 1;
        nextPoint = [nextPoint(1) + shiftX, nextPoint(2) + shiftY];
    end
end

% get skeleton
ske = getSkeleton(fineSkeMap);
ske = cat(1, ske(1:2:end,:), ske(end,:))';

% smooth skeleton
ske = spcrv([[ske(2,1) ske(2,:) ske(2,end)]; [ske(1,1) ske(1,:) ske(1,end)]], 5);
ske = ske(:,2:-1:1);
skeLen = ske(2:end,:) - ske(1:end-1,:);
skeLen = sum(sqrt(skeLen(:,1).^2 + skeLen(:,2).^2));

end

function adjPoint = countAdjacentPoint(bw)
% adjPoint form : [adjacent point's num, index1, index2, index3, index4]

% get point position
[pX, pY] = find(bw == 1);
pointNum = length(pX);
adjPoint = zeros(pointNum, 5);
for k = 1 : pointNum
    bw(pX(k), pY(k)) = k;
end

% count num
for k = 1 : pointNum
    tmp = 0;
%     
    if bw(pX(k) - 1, pY(k)) ~= 0 
        tmp = tmp + 1; 
        adjPoint(k, tmp + 1) = bw(pX(k) - 1, pY(k));
    end
    if bw(pX(k) + 1, pY(k)) ~= 0 
        tmp = tmp + 1; 
        adjPoint(k, tmp + 1) = bw(pX(k) + 1, pY(k));
    end
    if bw(pX(k), pY(k) - 1) ~= 0 
        tmp = tmp + 1; 
        adjPoint(k, tmp + 1) = bw(pX(k), pY(k) - 1);
    end
    if bw(pX(k), pY(k) + 1) ~= 0 
        tmp = tmp + 1; 
        adjPoint(k, tmp + 1) = bw(pX(k), pY(k) + 1);
    end
    if bw(pX(k) - 1, pY(k)) == 0 && bw(pX(k), pY(k) - 1) == 0 && ...
            bw(pX(k) - 1, pY(k) - 1) ~= 0
        tmp = tmp + 1; 
        adjPoint(k, tmp + 1) = bw(pX(k) - 1, pY(k) - 1);
    end
    if bw(pX(k) - 1, pY(k)) == 0 && bw(pX(k), pY(k) + 1) == 0 && ...
            bw(pX(k) - 1, pY(k) + 1) ~= 0
        tmp = tmp + 1; 
        adjPoint(k, tmp + 1) = bw(pX(k) - 1, pY(k) + 1);
    end
    if bw(pX(k) + 1, pY(k)) == 0 && bw(pX(k), pY(k) - 1) == 0 && ...
            bw(pX(k) + 1, pY(k) - 1) ~= 0
        tmp = tmp + 1; 
        adjPoint(k, tmp + 1) = bw(pX(k) + 1, pY(k) - 1);
    end
    if bw(pX(k) + 1, pY(k)) == 0 && bw(pX(k), pY(k) + 1) == 0 && ...
            bw(pX(k) + 1, pY(k) + 1) ~= 0
        tmp = tmp + 1; 
        adjPoint(k, tmp + 1) = bw(pX(k) + 1, pY(k) + 1);
    end
    adjPoint(k, 1) = tmp;
end

end

function adjPoint = removeBranch(adjPoint)
%

% loop over branch point
branchInd = find(adjPoint(:,1) > 2, 1);
while(~isempty(branchInd))
    % get branch num in this point
    branchNum = adjPoint(branchInd, 1);
    branchLength = ones(1, branchNum);
    % calculate branch's length
    for k = 1 : branchNum
       formerInd = branchInd;
       curInd = adjPoint(branchInd, k + 1);
       while(true)
           [curInd, formerInd] = findNextPoint(curInd, formerInd, adjPoint);
           if curInd ~= -1
               branchLength(k) = branchLength(k) + 1;
           else
               break;
           end
       end
    end
    % preserve the 2 longest branch and set other branch to invalid
    [~, lenInd] = sort(branchLength, 'descend');
    adjPoint(adjPoint(branchInd, lenInd(3:end) + 1), :) = -1;
    adjPoint(branchInd, 2 : 3) = adjPoint(branchInd, lenInd(1 : 2) + 1);
    adjPoint(branchInd, 4 : 5) = 0;
    adjPoint(branchInd, 1) = 2;
    % get next branch point's index
    branchInd = find(adjPoint(:,1) > 2, 1);
end

end

function ske = getSkeleton(skeMap)
%

% get adj point
[pX, pY] = find(skeMap == 1);
adjPoint = countAdjacentPoint(double(skeMap));
endPointInd = find(adjPoint(:,1) == 1, 1);
ske = [pX(endPointInd), pY(endPointInd)];

%
formerInd = endPointInd;
curInd = adjPoint(endPointInd, 2);
while(curInd ~= -1)
    ske = cat(1, ske, [pX(curInd), pY(curInd)]);
    [curInd, formerInd] = findNextPoint(curInd, formerInd, adjPoint);
end

end

function [nextPointInd, formerInd] = findNextPoint(curPointInd, formerPointInd, adjPoint)
%
k = curPointInd;
if adjPoint(k, 1) == 1 || adjPoint(k, 1) == 3 || adjPoint(k, 1) == 4
    nextPointInd = -1;
else
    possibleInd = adjPoint(k, 2 : 3);
    nextPointInd = possibleInd(possibleInd ~= formerPointInd);
end
formerInd = k;

end