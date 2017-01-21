%% It is a simple cilia's data augmentation tool
%
function dataAugmentation(ts, tsLabel, savePath, saveHead, augmentation)
% tspath - training set path generated from 'detection toolset'

%% initialize parameters
if nargin < 2
    tsLabel = -1;
end
if nargin < 3
    savePath = pwd;
    saveHead = '';
end
if nargin < 5
    augmentation = 8;
end

if ischar(ts)
    [ciliaData, rawLabel] = TrainingSet.generateTsFromPosition(ts);
else
    ciliaData = ts;
    if tsLabel == -1
        rawLabel = zeros(1,size(ciliaData,2));
    else
        rawLabel = tsLabel;
    end
end
rawDataName = [saveHead, 'Data.mat'];
rawLabelName = [saveHead, 'Label.mat'];
dataSavePath = fullfile(savePath, rawDataName);
labelSavePath = fullfile(savePath, rawLabelName);

% reshape date
imSize = size(ciliaData{1},1);
ciliaNum = size(ciliaData,2);
rawData = zeros(imSize,imSize,ciliaNum);
for k = 1 : ciliaNum
    if size(ciliaData{k}, 3) == 1
        rawData(:,:,k) = ciliaData{k};
    elseif size(ciliaData{k}, 3) == 3
        rawData(:,:,k) = ciliaData{k}(:,:,2);
    end
end

%% augmentation
% augmentatoin by rotating and flipping
data = rawData;
if isequal(augmentation, 8) || isequal(augmentation, 16)
    data = cat(3, data, rot90(rawData));
    data = cat(3, data, rot90(rot90(rawData)));
    data = cat(3, data, rot90(rot90(rot90(rawData))));
    data = cat(3, data, fliplr(data));
end
% data = cat(3, data, flipud(rawData));
% augmentation by adding noise and filtering
if 0
    noiseData = zeros(size(data),'uint8');
    for k = 1 : size(data,3)
        noiseData(:,:,k) = imnoise(data(:,:,k), 'gaussian', 0, 0.0004);
    end
    data = cat(3, data, noiseData);
end
% augmentation by gamma transformation
if 0
    gammaData = zeros(size(data),'uint8');
    for k = 1 : size(data,3)
        gammaData(:,:,k) = im2uint8(imadjust(im2double(data(:,:,k)), [], [], 0.8));
    end
    data = cat(3, data, gammaData);
end
% get label
label(1,:) = uint8(repmat(rawLabel, [1,size(data,3)/size(rawData,3)]));
% save
data = uint8(reshape(data, [1, imSize, imSize, size(data,3)]));
save(dataSavePath','data','-v7.3');
save(labelSavePath,'label','-v7.3');
end





