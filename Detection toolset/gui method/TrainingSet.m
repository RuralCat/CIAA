classdef TrainingSet
    properties
        name;
        savePath;
        trainingSetSize;
        roiSize;
        tsRegion;
        tsPosition;
        tsNum;
        savedNum
        data;
        label;
        parentImage;
        ciliaSet;
    end
    
    methods
        function ts = TrainingSet(handles)
            ts.name = 'noneName';
            ts.savePath = 'nonePath';
            ts.trainingSetSize = handles.tsSize;
            ts.roiSize = handles.roiSize;
            ts.data = handles.image;
            ts.label = handles.label;
            ts.tsRegion = handles.roiRegion;
            ts.tsPosition = handles.roiPosition(handles.ciliaIdx,:);
            ts.tsNum = length(ts.label);
            ts.savedNum = 0;
            ts.parentImage = handles.parentImage;
            ts.ciliaSet = cell(ts.tsNum,4);
            for k = 1 : ts.tsNum
                ts.ciliaSet{k,1} = k;
                ts.ciliaSet{k,2} = handles.ciliaLength(k);
                ts.ciliaSet{k,3} = handles.roiPosition(handles.ciliaIdx(k),1:4);
                ts.ciliaSet{k,4} = handles.imageStack{handles.imageCursor};
            end
        end
        
        function ts = MergeTrainingSet(ts,tsTmp)
            ts.data = cat(2,ts.data,tsTmp.data);
            ts.label = cat(2,ts.label,tsTmp.label);
            ts.tsPosition = cat(1,ts.tsPosition,tsTmp.tsPosition);
            ts.tsNum = ts.tsNum + tsTmp.tsNum;
            if isprop(ts, 'parentImage') && isprop(tsTmp, 'parentImage')
                ts.parentImage = cat(2,ts.parentImage, tsTmp.parentImage);
            end
            if isprop(ts,'ciliaSet') && isprop(tsTmp,'ciliaSet')
                ts.ciliaSet = cat(1,ts.ciliaSet,tsTmp.ciliaSet);
            end
        end
            
    end
    
    methods(Static)
        function handles = newTrainingSet(handles)
            handles.ts = TrainingSet(handles);
            handles.isExistTs = true;
        end
        
        function isSaved = tsIsSaved(handles)
            isSaved = length(handles.ts.label) == handles.ts.savedNum;
        end
        
        function [handles, successSaved] = saveTrainingSet(handles)
            filename = handles.ts.name;
            pathname = handles.ts.savePath;
            fullpath = fullfile(pathname,filename);
            if strcmp(filename,'noneName')
                [filename,pathname] = uiputfile('*.mat','Save Training Set as');
                if isequal(filename,0) || isequal(pathname,0)
                    successSaved = false;
                    return;
                else
                    fullpath = fullfile(pathname,filename);
                end
                handles.ts.name = filename;
                handles.ts.savePath = pathname;
            end
            handles.ts.savedNum = length(handles.ts.label);
            ts = handles.ts;
            % delete invalid training set
            xPosi = find(ts.label == 2);
            ts.label(xPosi) = [];
%             ts.data(:,xPosi,:) = [];
            ts.parentImage(xPosi) = [];
            ts.tsPosition(xPosi,:) = [];
            ts.tsNum = length(ts.label);
            if isfield(handles,'checkpoint')
                checkpoint = handles.checkpoint;
            else
                checkpoint = -1;
            end
            tsCheckCode = 'A ts file!';
            save(fullpath,'ts','tsCheckCode','checkpoint');
            successSaved = true;
            % save cilia information
%             if isfield(handles.ts,'ciliaSet') || ...
%                     isprop(handles.ts,'ciliaSet') && ...
%                     length(handles.ts.ciliaSet) == length(handles.ts.label)
%                 fullpath = [fullpath(1:end-3),'txt'];
%                 TrainingSet.saveTrueCiliaInformation(handles,fullpath);
%             end
            ReportMethod.writeReportToExcel(handles, pathname);
        end
        
        function saveTrueCiliaInformation(handles,savePath)
            % delete false positive and invalid 
            ciliaSet = handles.ts.ciliaSet(handles.ts.label == 1,:);
            % write to file
            ciliaTable = cell2table(ciliaSet,'VariableNames',{'Number'...
                'CiliaLength' 'BoundingBox' 'Image'});
            % save
            if exist(savePath,'file')
                delete(savePath);
            end
            writetable(ciliaTable,savePath);
            
        end
        
        function [handles,successOpened] = openTrainingSet(handles,hasSaved)
            if nargin == 1
                hasSaved = false;
            end
            [filename,pathname] =uigetfile('*mat','Open Training Set');
            if isequal(filename,0) || isequal(pathname,0)
                successOpened = false;
                return;
            else
                fullpath = fullfile(pathname,filename);
                ts = open(fullpath);
            end
            if ~isfield(ts,'tsCheckCode') || ~strcmp(ts.tsCheckCode,'A ts file!')
                msgShow(handles,'It is not a training set file!','error');
                successOpened = false;
                return;
            end
            if ~hasSaved
                if ~TrainingSet.tsIsSaved(handles)
                isOpenAnswer = questdlg(['Current training set has not been saved.',...
                    'Is sure to continue open?'],'Open Training Set',...
                    'Yes', 'No', 'No');
                if strcmp(isOpenAnswer,'No')
                    successOpened = false;
                    return;
                end
                end
            end
            if isfield(ts,'checkpoint')
                handles.checkpoint = ts.checkpoint;
            else
                handles.checkpoint = -1;
            end
            handles.ts = ts.ts;
            successOpened = true;
            
        end
        
        function [ciliaData, ciliaLabel, ts] = generateTsFromPosition(...
                tsFilePath, roiSize)
           % parse parameters
           if nargin < 2
               roiSize = 45;
           end
           % generate training set from roi position 
           f = load(tsFilePath);
           ts = f.ts;
           rawImage = f.ts.data;
           imgId = f.ts.parentImage; 
           bbox = f.ts.tsPosition;
           ciliaNum = f.ts.tsNum;
           ciliaLabel = f.ts.label;
           ciliaData = cell(1,ciliaNum);
           for k = 1 : ciliaNum
               ciliaRegion = CiliaMethod.getCiliaTrainingRegion(...
                   rawImage{imgId(k)},bbox(k,:),roiSize);
               ciliaData{k} = ciliaRegion;
           end
        end
    end
end
    