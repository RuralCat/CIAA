classdef LabelMethod
    methods(Static)
        function showImage(~,handles,image)
            if ischar(image)
                image = imread(image);
            end
            hImage = imshow(image,[],'Parent',handles.imageAxes);
            set(hImage,'ButtonDownFcn',{@(hObject,eventdata)tst(...
                'imageAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject))});
        end
        
        function handles = showCiliaImage(handles,idx)
            if nargin == 1
                if isempty(handles.label)
                    idx = -1;
                else
                    idx = handles.ciliaShowIdx;
                end
            end
            if idx == -1
                imshow(zeros(500),'Parent',handles.ciliaAxes);
                controlStatus.setCiliaBtn(handles,{'off','off','off','off'});
            else
                % show image
                box = handles.roiPosition(handles.ciliaIdx(idx),:);
                padl = ceil(0.3*box(5:6));
                xstart = max(box(1) - padl(1),1);
                xend = min(box(3) + padl(1),handles.imageH);
                ystart = max(box(2) - padl(2),1);
                yend = min(box(4) + padl(2),handles.imageW);
                localIm = handles.image(xstart:xend,ystart:yend,:);
                imshow(localIm,[],'Parent',handles.ciliaAxes);
                % show skeleton
                skeletonX = handles.skeleton{idx}(:,1) - xstart;
                skeletonY = handles.skeleton{idx}(:,2) - ystart;
                hold(handles.ciliaAxes,'on');
                handles.skeletonHandle = plot(handles.ciliaAxes,...
                    skeletonY,skeletonX,'r','LineWidth',0.01);
                hold(handles.ciliaAxes,'off');
                % set btn status
                if idx == 1
                    if handles.roiNum == 1
                        controlStatus.setCiliaBtn(handles,{'off','off','on','off'});
                    else
                        controlStatus.setCiliaBtn(handles,{'off','on','on','off'});
                    end
                elseif idx == length(handles.ciliaIdx)
                    controlStatus.setCiliaBtn(handles,{'on','off','on','off'});
                else
                    controlStatus.setCiliaBtn(handles,{'on','on','on','off'});
                end
                % show cilia featrue
%                 LabelMethod.showCiliaFeatrue(handles,localIm);
            end
        end
        
        function showCiliaFeatrue(handles,localIm)
            if localIm == -1
                imshow(zeros(500),'Parent',handles.ciliaFeatrueAxes);
            else
                localIm = localAdjust(im2double(localIm));
                imshow(localIm,'Parent',handles.ciliaFeatrueAxes);
                hold on
                plot(handles.ciliaFeatrueAxes,...
                    handles.skeleton{handles.ciliaShowIdx}(:,2),...
                    handles.skeleton{handles.ciliaShowIdx}(:,1),...
                    'b','LineWidth',0.01);
                hold off
            end
        end
        
        function handles = importImage(handles)
            imageDirName = uigetdir('','Pick a directory');
            if isequal(imageDirName,0)
                return;
            end
            imageStack = {};
            imageNum = 0;
            [imageStack,imageNum] = LabelMethod.getImage(imageDirName,imageStack,imageNum);
            if isequal(imageNum,0)
                return;
            end
            handles.totalImage = imageNum;
            handles.imageCursor = 0;
            handles.imageStack = imageStack;
        end
        
        function [imageStack,imageNum] = getImage(imageDir,imageStack,imageNum)
            fileStruct = dir(imageDir);
            for i = 1 : length(fileStruct)
                if fileStruct(i).isdir
                    if ~strcmp(fileStruct(i).name,'.') &&  ~strcmp(fileStruct(i).name,'..')
                        [imageStack,imageNum] = LabelMethod.getImage(...
                            fullfile(imageDir,fileStruct(i).name),imageStack,imageNum);
                    end
                else if strcmp(fileStruct(i).name(end-2:end),'tif')
                        imageNum = imageNum + 1;
                        imageStack{imageNum} = fullfile(imageDir,fileStruct(i).name);
                    end
                end  
            end
        end
        
        function handles = detectCilia(handles)
            % read image
            embedWaitbar(0,handles.waitbar,'Read Image...'); %!!!!
            pause(0.1);
            imagePath = handles.imageStack{handles.imageCursor};
            handles.image = imread(imagePath);
            handles.imageW = size(handles.image,2);
            handles.imageH = size(handles.image,1);
            % get candidate cilia
            embedWaitbar(0.1,handles.waitbar,'Detect Cilia...'); %!!!
            pause(0.1);
            [imBw, ciliaBox, ciliaIdx, snrRatio, directionRatio] = ...
                semiCiliaDetection(imagePath,...
                handles.snrThreshold, handles.directionThreshold);
            handles.imageBw = imBw;
            handles.ciliaBox = ciliaBox;
            handles.snrRatio = snrRatio;
            handles.directionRatio = directionRatio;
            % get roi position
            handles.candidateCiliaNum = length(snrRatio);
            handles.candidateCiliaIdx = ciliaIdx;
            bbox = zeros(size(ciliaBox,1),6);
            if handles.candidateCiliaNum > 0
                bbox(:,1) = ciliaBox(:,2);
                bbox(:,2) = ciliaBox(:,1);
                bbox(:,3) = min(ciliaBox(:,2) + ciliaBox(:,4),handles.imageW);
                bbox(:,4) = min(ciliaBox(:,1) + ciliaBox(:,3),handles.imageH);
                bbox(:,5:6) = bbox(:,3:4) - bbox(:,1:2);
            end
            handles.roiPosition = bbox;
            % filter cilia
            embedWaitbar(0.8,handles.waitbar,'Filter Cilia...'); %!!!
            handles = LabelMethod.filterCilia(handles);
            % compute cilia
            embedWaitbar(0.9,handles.waitbar,'Compute Cilia...'); %!!!
            handles = LabelMethod.computeAndShowCilia(handles);
            embedWaitbar(1,handles.waitbar,'Completed!'); %!!!
        end
        
        function handles = filterCilia(handles)
            % filter cilia
            ciliaIdx = handles.candidateCiliaIdx;
            isFP = true(handles.candidateCiliaNum,1);
            if handles.snrThreshold > 0
                isFP = isFP & ~isnan(handles.snrRatio) & ...
                    (handles.snrRatio > handles.snrThreshold);
            end
            if handles.directionThreshold > 0
                isFP = isFP & ~isnan(handles.directionRatio) & ...
                    (handles.directionRatio > handles.directionThreshold);
            end
            handles.ciliaIdx = ciliaIdx(isFP);
        end
        
        function handles = computeAndShowCilia(handles)
            ciliaIdx = handles.ciliaIdx;
            % get roi position
            ciliaNum = length(ciliaIdx);
            bbox = handles.roiPosition;
            % get cilia region
            roiSize = handles.ts.roiSize;
            handles.roiRegion = zeros(handles.imageW,handles.imageH,'uint16');
            data = zeros(roiSize*roiSize,ciliaNum,3,'uint8');
            label = ones(1,ciliaNum) * handles.labelMode;
            % create a binary cilia region
            handles.bwCiliaRegion = bwlabel(handles.imageBw);
            for k = 1 : ciliaNum
                % get cilia region
                [handles,ciliaRegion] = CiliaMethod.getCiliaRegion(handles, bbox, k);
                data(:,k,:) = ciliaRegion;
                % compute cilia length
                handles = CiliaMethod.computeCiliaLength(handles,bbox,k);
                % create show handle
                handles = CiliaMethod.createShowHandle(handles, bbox, k);
            end
            % update handles
            handles.roiNum = ciliaNum;
            handles.data = data;
            handles.label = label;
            handles.parentImage = {};
            for k = 1 : handles.roiNum
                handles.parentImage{k} = handles.imageStack{handles.imageCursor};
            end
            % show cilia in axes
            LabelMethod.showAllCilia(handles);
            handles.ciliaShowIdx = 1;
            handles = LabelMethod.showCiliaImage(handles);
        end
        
        function handles = showCilia(handles,roiId)
            % get label
            label = handles.label(roiId);
            % define color
            if isequal(label,0)
                color = [1,0,0]; % red
            elseif isequal(label,1)
                    color = [0,1,0]; % green
            elseif isequal(label,2)
                    color = [1,1,0]; % yellow
            end
            value1 = handles.showRectCheckbox.Value;
            value2 = handles.showOutlineCheckbox.Value;
            value3 = handles.showLenCheckbox.Value;
            % if show rectangle
            if value1
                handles.showRectHandle{roiId}.EdgeColor = color;
                handles.showRectHandle{roiId}.Visible = 'on';
            else
                handles.showRectHandle{roiId}.Visible = 'off';
            end
            % if show outline
            if value2
                handles.showOutlineHandle{roiId}.Color = color;
                handles.showOutlineHandle{roiId}.Visible = 'on';
            else
                handles.showOutlineHandle{roiId}.Visible = 'off';
            end
            % if show cilia length
            if value3
                handles.showLengthHandle{roiId}.Color = color;
                handles.showLengthHandle{roiId}.Visible = 'on';
            else
                handles.showLengthHandle{roiId}.Visible = 'off';
            end
        end
        
        function showAllCilia(handles)
            for i = 1 : length(handles.label)
                handles = LabelMethod.showCilia(handles,i);
            end
        end
        
        function handles = changeSlider(handles)
            if strcmp(handles.startLabelBtn.String,'Start Label')
                return;
            end
            CiliaMethod.deleteShowHandle(handles);
            handles = LabelMethod.filterCilia(handles);
            handles = LabelMethod.computeAndShowCilia(handles);
        end
        
    end
end