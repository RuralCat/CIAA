function [imBw, ciliaBox, ciliaIdx, snrRatio, directionRatio] = ...
    semiCiliaDetection(image, snrThres,...
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
if ischar(image)
    image = imread(image);
end
if size(image,3) == 3
    im = im2double(image(:,:,2));
else
    im = im2double(image);
end

% image pre-processing
imHist = imagePreProcessing(im);

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

