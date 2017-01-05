function [imBw, ciliaBox, ciliaIdx, snrRatio, directionRatio] = ...
    semiCiliaDetection(imdir, snrThres,...
    directionThres, minCiliaArea, minCiliaLength, ...
    maxCiliaLength, angleSlice)
% this is a semi-automated cilia detection method
% imdir - image directory
% snrThres - important parameter to control filter
% directionThres - import parameter to control filter
% minCiliaLength, maxCiliaLength, angleSlice, suggest using default value
%

% define parameters
if nargin < 2
    snrThres = 1.3;
end
if nargin < 3
    directionThres = 0.09;
end
if nargin < 4
    minCiliaArea = 20;
    minCiliaLength = 10;
    maxCiliaLength = 300;
    angleSlice = 12;
end

% read image 
im = imread(imdir);
if size(im,3) == 3
    im = im2double(im(:,:,2));
else
    im = im2double(im);
end

% filter image
im = rmwhitebar(im,1.0,2);
im = imfilter(im,fspecial('gaussian',[3,3],1));

% estimate background
histNum = imhist(im);
[~,ind] = sort(histNum,'descend');
ind = ind(1:2);
bg = sum((ind-1)/255.*histNum(ind)) / sum(histNum(ind));

% hist adjust
imHist = imadjust(im,[bg, max(im(:))], [0.001,1]);
% imHist = imguidedfilter(imsharpen(imHist,'Radius',1.5,'Amount',5));

% enhance local image
[~, imBw] = imageLocalEnhanced(imHist,minCiliaArea, angleSlice);

% select cilia
[ciliaIdx, ciliaBox, ciliaBw, ~, ciliaDirection] = ...
    ciliaSelection(imBw,minCiliaLength,maxCiliaLength, angleSlice);

% eliminate false postive
[~, ciliaIdx, snrRatio, directionRatio] = eliminateFP(im, ciliaIdx, ...
    ciliaBw, ciliaBox, ciliaDirection,...
   snrThres, directionThres, angleSlice);

end

