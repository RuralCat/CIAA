% this file contain all function used in 'cnn training tool'
classdef cttMethod
    methods(Static)
        function SetDataGeneratorEnable(handles, enable)
            if enable
                enable1 = 'on';
                enable2 = 'off';
            else
                enable1 = 'off';
                enable2 = 'on';
            end
            handles.dataPathTxt.Enable = enable2;
            handles.dataPathBtn.Enable = enable2;
            handles.loadCiliaDataBtn.Enable = enable1;
            handles.valRatioTxt.Enable = enable1;
            handles.agmPopmenu.Enable = enable1;
            handles.generateSaveBtn.Enable = enable1;
            handles.trainBtn.Enable = enable2;
        end
        
        function SetStatus(handles, strValue, color)
           handles.statusTxt.String = strValue;
           handles.statusTxt.ForegroundColor = color;
        end
        
        function valid = CheckNumeric(strValue)
            if isnan(str2double(strValue))
                msgShow(strValue,'Please enter number!', 'error');
                valid = false;
            else
                valid = true;
            end
        end
        
        function filePath = GetDirectory()
            filePath = uigetdir('', 'Pick a directory');
        end
        
        function ciliaData = OpenCiliaData()
            [fileName, pathName] = uigetfile('*mat', 'Open Cilia Data');
            if isequal(fileName, 0) || isequal(pathName, 0)
                ciliaData = 0;
            else
                filePath = fullfile(pathName, fileName);
                ciliaData = open(filePath);
                if ~isfield(ciliaData,'tsCheckCode') || ...
                        ~strcmp(ciliaData.tsCheckCode,'A ts file!')
                    msgShow(0,'It is not a training set file!','error');
                    ciliaData = 0;
                end
            end
        end
        
        function GenerateTrainAndValData(handles)
            % define parameters
            valRatio = str2double(handles.valRatioTxt.String);
            rootPath = handles.dataPathTxt.String;
            augmentation = str2double(handles.agmPopmenu.String(handles.agmPopmenu.Value));
            save(fullfile(rootPath, 'augmentation.mat'), 'augmentation');
            % read data
            fid  = handles.ciliaData;
            rawImage = fid.ts.data;
            imgId = fid.ts.parentImage;
            bbox = fid.ts.tsPosition;
            ciliaNum = fid.ts.tsNum;
            ciliaLabel = fid.ts.label;
            smallCiliaData = cell(1, 2*ciliaNum);
            bigCiliaData = cell(1, 2*ciliaNum);
            for k = 1 : ciliaNum
                [smallCiliaData{k}, smallCiliaData{k+ciliaNum}] = CiliaMethod.getCiliaTrainingRegion(...
                    rawImage{imgId(k)}, bbox(k,:), 45, 0.4);
                [bigCiliaData{k}, bigCiliaData{k+ciliaNum}] = CiliaMethod.getCiliaTrainingRegion(...
                    rawImage{imgId(k)}, bbox(k,:), 79, 1.0);
            end
            % random idx split
            ciliaNum = length(ciliaLabel);
            trainNum = floor(ciliaNum * (1 - valRatio));
            idx = randperm(ciliaNum);
            trainIdx = idx(1 : trainNum);
            valIdx = idx(trainNum + 1 : end);
            % premat if augmentation is 16
            if augmentation == 16
                trainIdx = repmat(trainIdx,[1,2]);
                valIdx = repmat(valIdx, [1,2]);
                ciliaLabel = repmat(ciliaLabel, [1,2]);
            end
            % data augmentation and save
            dataAugmentation(smallCiliaData(trainIdx), ciliaLabel(trainIdx),...
                rootPath, 'train', augmentation);
            dataAugmentation(smallCiliaData(valIdx), ciliaLabel(valIdx),...
                rootPath, 'val', augmentation);
            dataAugmentation(bigCiliaData(trainIdx), ciliaLabel(trainIdx),...
                rootPath, 'trainImage', augmentation);
            dataAugmentation(bigCiliaData(valIdx), ciliaLabel(valIdx),...
                rootPath, 'valImage', augmentation);
            delete(fullfile(rootPath,'trainImageLabel.mat'));
            delete(fullfile(rootPath,'valImageLabel.mat'));
        end
        
        function strValue = ConvertStr(value)
            strValue = num2str(value * 100);
            if value >= 0.1
                strValue = [strValue(1:5),'%'];
            else
                strValue = [strValue(1:4),'%'];
            end
        end
    end
end