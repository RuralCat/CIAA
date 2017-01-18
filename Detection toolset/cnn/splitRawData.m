
%% Split raw cilia data to training set, validation set, test set
%

dataPath = 'K:\BIGCAT\Projects\Cilia\Code\CIAA\RawCiliaData.mat';

% define split ratio
trainRatio = 0.8;
valRatio = 0.1;
testRatio = 0.1;
% read data
fid = load(dataPath);
rawImage = fid.ts.data;
imgId = fid.ts.parentImage;
bbox = fid.ts.tsPosition;
ciliaNum = fid.ts.tsNum;
ciliaLabel = fid.ts.label;
smallCiliaData = cell(1,ciliaNum);
medCiliaData = cell(1, 2*ciliaNum);
bigCiliaData = cell(1, 2*ciliaNum);
for k = 1 : ciliaNum
    smallCiliaData{k} = CiliaMethod.getCiliaTrainingRegion(...
        rawImage{imgId(k)}, bbox(k,:), 45, 0.3);
    [medCiliaData{k}, medCiliaData{k+ciliaNum}] = CiliaMethod.getCiliaTrainingRegion(...
        rawImage{imgId(k)}, bbox(k,:), 45, 0.4);
    [bigCiliaData{k}, bigCiliaData{k+ciliaNum}] = CiliaMethod.getCiliaTrainingRegion(...
        rawImage{imgId(k)}, bbox(k,:), 79, 1.0);
end
% random idx split
ciliaNum = length(ciliaLabel);
trainNum = floor(ciliaNum * trainRatio);
valNum = floor(ciliaNum * valRatio);
testNum = ciliaNum - trainNum - valNum;
idx = randperm(ciliaNum);
trainIdx = idx(1 : trainNum);
valIdx = idx(trainNum + 1 : trainNum + valNum);
testIdx = idx(trainNum + valNum + 1 : end); 
% repmat
trainIdx = repmat(trainIdx,[1,2]);
valIdx = repmat(valIdx, [1,2]);
testIdx = repmat(testIdx, [1,2]);
ciliaLabel = repmat(ciliaLabel, [1,2]);
% data augmentation and save
rootPath = ...
    'K:\BIGCAT\Projects\Cilia\Code\XXXXX\lenet-mnist\data\16x data(45 x 45) 0116';
dataAugmentation(medCiliaData(trainIdx),ciliaLabel(trainIdx),...
    rootPath, 'train');
dataAugmentation(medCiliaData(valIdx),ciliaLabel(valIdx),...
    rootPath, 'val');
dataAugmentation(medCiliaData(testIdx),ciliaLabel(testIdx),...
    rootPath, 'test');
dataAugmentation(bigCiliaData(trainIdx),ciliaLabel(trainIdx), ...
    rootPath, 'trainImage');
dataAugmentation(bigCiliaData(valIdx),ciliaLabel(valIdx), ...
    rootPath, 'valImage');
dataAugmentation(bigCiliaData(testIdx),ciliaLabel(testIdx), ...
    rootPath, 'testImage');