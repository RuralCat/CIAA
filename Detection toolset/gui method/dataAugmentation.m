%% It is a simple cilia's data augmentation tool
%
function dataAugmentation(ts, tsLabel, savePath)
% tspath - training set path generated from 'detection toolset'

%% initialize parameters
if nargin < 1
    ts = 'ciliadata4.mat';
end
if nargin < 2
    tsLabel = -1;
end
if nargin < 3
    savePath = pwd;
end

if ischar(ts)
    % load raw training set
    tsfile = load(ts);
    % data should be a training set
    if ~isfield(tsfile,'tsCheckCode')
        error('It is not a training set file.');
    else
        rawData = tsfile.ts.data;
        rawLabel = tsfile.ts.label;
    end
else
    rawData = ts;
    if tsLabel == -1
        rawLabel = zeros(1,size(rawData,2));
    else
        rawLabel = tsLabel;
    end
end
dataSavePath = fullfile(savePath, 'data.mat');
labelSavePath = fullfile(savePath, 'label.mat');
outputSize = 45;
agmMultiple = 24;

% reshape date
imSize = sqrt(size(rawData,1));
tsNum = size(rawData,2);
imDepth = size(rawData,3);
if imDepth == 1
    rawData = reshape(rawData,[imSize,imSize,tsNum]);
elseif imDepth == 3
    rawData = reshape(rawData(:,:,2),[imSize,imSize,tsNum]);
end
% (raw + 5 rotate) * (2 noise + 1 filter) * (2 gamma transform) = 36
rawData = imresize(rawData,[outputSize, outputSize]);
data = zeros(outputSize,outputSize,tsNum*agmMultiple,'uint8');
label = zeros(1,tsNum*agmMultiple,'uint8');

%% augmentation
% augmentatoin by rotating and flipping
agmCount = 0;
data(:,:,agmCount * tsNum + 1 : (agmCount + 1) * tsNum) = rawData; 
agmCount = agmCount + 1;
if agmMultiple == 54
    data(:,:,agmCount * tsNum + 1 : (agmCount + 1) * tsNum) = rot90(rawData);
    agmCount = agmCount + 1;
    data(:,:,agmCount * tsNum + 1 : (agmCount + 1) * tsNum) = rot90(rot90(rawData));
    agmCount = agmCount + 1;
end
data(:,:,agmCount * tsNum + 1 : (agmCount + 1) * tsNum) = rot90(rot90(rot90(rawData)));
agmCount = agmCount + 1;
data(:,:,agmCount * tsNum + 1 : (agmCount + 1) * tsNum) = fliplr(rawData);
agmCount = agmCount + 1;
data(:,:,agmCount * tsNum + 1 : (agmCount + 1) * tsNum) = flipud(rawData);
agmCount = agmCount + 1;
% augmentation by adding noise and filtering
if agmMultiple == 54
    for k = 0 : agmCount-1
        data(:,:,(k+agmCount) * tsNum + 1 : (k+agmCount+1) * tsNum) = ...
         imnoise(data(:,:,k * tsNum + 1 : (k+1) * tsNum),'speckle');
        data(:,:,(k+agmCount*2) * tsNum + 1 : (k+agmCount*2+1) * tsNum) = ...
            imfilter(data(:,:,k * tsNum + 1 : (k+1) * tsNum),...
            fspecial('gaussian',[3,3],0.4));
    end
    agmCount = 3 * agmCount;
elseif agmMultiple == 24
    for k = 0 : agmCount - 1
        data(:,:,(k+agmCount) * tsNum + 1 : (k+agmCount+1) * tsNum) = ...
                imnoise(data(:,:,k * tsNum + 1 : (k+1) * tsNum),'gaussian',0,0.0004);
    end
    agmCount = 2 * agmCount;
end
% augmentation by gamma transformation
for k = 0 : agmCount - 1
    for n = 1 : tsNum
        data(:,:,(k+agmCount) * tsNum + n) = ...
            im2uint8(imadjust(im2double(data(:,:,k * tsNum + n)), [], [], 0.8));
        data(:,:,(k+agmCount*2) * tsNum + n) = ...
            im2uint8(imadjust(im2double(data(:,:,k * tsNum + n)), [], [], 1.6));
    end
end
% get label
label(1,:) = repmat(rawLabel, [1,agmMultiple]);
% save
data = reshape(data, [1,outputSize,outputSize,tsNum*agmMultiple]);
save(dataSavePath','data','-v7.3');
save(labelSavePath,'label','-v7.3');
end





