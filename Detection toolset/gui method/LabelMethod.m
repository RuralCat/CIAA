classdef LabelMethod
    methods(Static)
        function handles = showImage(handles, image, showMode)
            % parse inputs
            if nargin < 3
                showMode = 1;
            end
            % if image is dir, read image
            if ischar(image)
                [image, imageMode] = ImageMethod.readCiliaImage(image);
                if isequal(imageMode, 'r') || isequal(imageMode, 'g') ...
                        || isequal(imageMode, 'merged')
                    handles.haveCilia = true;
                else
                    handles.haveCilia = false;
                end
                handles.image = image;
                handles.imageMode = imageMode;
                % update control status
                handles = HandlesMethod.updateImModePopmenu(handles, imageMode);
            end
            % if imModePopmenu changed
            if isequal(handles.imageMode, 'merged')
               if showMode > 1
                   image = image(:, :, showMode - 1);
               end
            end
            % show image
            if ~any(image)
                imshow(image, 'Parent', handles.imageAxes);
            elseif ~isequal(image, handles.curShowImage)
                % show image
%                 hold(handles.imageAxes, 'on');
                hImage = imshow(image,[],'Parent',handles.imageAxes);
%                 hold(handles.imageAxes, 'off');
                % bind with event
                if isequal(handles.imageMode, 'r') || ...
                        isequal(handles.imageMode, 'g') || ...
                        (isequal(handles.imageMode, 'merged') && ...
                        (showMode == 1 || showMode == 2 || showMode == 3))
                    set(hImage,'ButtonDownFcn',{@(hObject,eventdata)tst(...
                        'imageAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject))});
                end
                % update current show image
                handles.curShowImage = image;
            end
            % show outline
            LabelMethod.showAllCilia(handles);
            handles = NucleiMethod.showNucleiBound(handles);
            % show cilia image
            if ~isempty(handles.imModePopmenu.String)
                if isequal(handles.imModePopmenu.String{handles.imModePopmenu.Value}, ...
                    'DAPI') || isempty(handles.ciliaIdx)
                    LabelMethod.showCiliaImage(handles, -1);
                else
                    LabelMethod.showCiliaImage(handles, 1);
                end
            else
                LabelMethod.showCiliaImage(handles, -1);
            end
            % set button status
            if handles.haveCilia
                controlStatus.setLabelControlBtn(handles, true);
                controlStatus.setNucleiBtn(handles, false);
                if isequal(handles.imageMode, 'merged') && ...
                        showMode == 4
                    controlStatus.setLabelControlBtn(handles, false);
                    controlStatus.setNucleiBtn(handles, true);
                end
            elseif isequal(handles.imageMode, 'b')
                controlStatus.setLabelControlBtn(handles, false);
                controlStatus.setNucleiBtn(handles, true);
            elseif isequal(handles.imageMode, 'undef')
                controlStatus.setLabelControlBtn(handles, false);
                controlStatus.setNucleiBtn(handles, false);
            end
        end
        
        function handles = showCiliaImage(handles, idx)
            if nargin < 2
                if isempty(handles.label)
                    idx = -1;
                else
                    idx = handles.ciliaShowIdx;
                end
            end
            if idx == -1
                imshow(zeros(500),'Parent',handles.ciliaAxes);
                controlStatus.setCiliaBtn(handles,{'off','off','off','off', 'off', 'off'});
            else
                % show image
                box = handles.roiPosition(handles.ciliaIdx(idx),:);
                padl = ceil(handles.padFactor * box(5:6));
                xstart = max(box(1) - padl(1), 1);
                xend = min(box(3) + padl(1),handles.imageH);
                ystart = max(box(2) - padl(2), 1);
                yend = min(box(4) + padl(2),handles.imageW);
                localIm = handles.image(xstart:xend, ystart:yend, :);
                imshow(localIm, [], 'Parent', handles.ciliaAxes);
                % show skeleton
                showFlag = 1;
                if isequal(handles.imModePopmenu.String{handles.imModePopmenu.Value}, ...
                        'Cy3') && ~isempty(handles.outerSkeleton)
                    skeletonX = handles.outerSkeleton{idx}(:,1) - xstart;
                    skeletonY = handles.outerSkeleton{idx}(:,2) - ystart;
                elseif ~isequal(handles.imModePopmenu.String{handles.imModePopmenu.Value}, ...
                        'Cy3') && ~isempty(handles.skeleton)
                    skeletonX = handles.skeleton{idx}(:,1) - xstart;
                    skeletonY = handles.skeleton{idx}(:,2) - ystart;
                else
                    showFlag = 0;
                end
                if showFlag
                    if isfield(handles, 'skeletonHandle') && ...
                            ishandle(handles.skeletonHandle)
                        delete(handles.skeletonHandle);
                    end
                    hold(handles.ciliaAxes,'on');
                    handles.skeletonHandle = plot(handles.ciliaAxes,...
                        skeletonY, skeletonX, 'r', 'LineWidth', 0.01);
                    hold(handles.ciliaAxes,'off');
                end
                % set btn status
                if idx == 1
                    if handles.roiNum == 1
                        controlStatus.setCiliaBtn(handles,{'off','off','on','off','on','on'});
                    else
                        controlStatus.setCiliaBtn(handles,{'off','on','on','off','on','on'});
                    end
                elseif idx == length(handles.ciliaIdx)
                    controlStatus.setCiliaBtn(handles,{'on','off','on','off','on','on'});
                else
                    controlStatus.setCiliaBtn(handles,{'on','on','on','off','on','on'});
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
                    if ~strcmp(fileStruct(i).name(1),'.')
                        [imageStack,imageNum] = LabelMethod.getImage(...
                            fullfile(imageDir,fileStruct(i).name),imageStack,imageNum);
                    end
                else if strcmp(fileStruct(i).name(end-2:end),'tif') && ...
                            ~strcmp(fileStruct(i).name(1), '.')
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
            handles.imageW = size(handles.image,2);
            handles.imageH = size(handles.image,1);
            % get candidate cilia
            embedWaitbar(0.1,handles.waitbar,'Detect Cilia...'); %!!!
            pause(0.1);
            [imBw, ciliaBox, ciliaIdx, snrRatio, directionRatio] = ...
                semiCiliaDetection(handles.image, ...
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
        
        function handles = detectOuterCilia(handles)
            % get histIm
            histIm = im2double(handles.image);
            if size(handles.image,3) == 3
                histIm = imagePreProcessing(histIm(:,:,1));
            else
                histIm = imagePreProcessing(histIm);
            end
            % get roi position
            ciliaIdx = handles.ciliaIdx;
            ciliaNum = length(ciliaIdx);
            bbox = handles.roiPosition;
            % compute outer length
            for k = 1 : ciliaNum
                tic;
                handles = CiliaMethod.computeOuterCiliaLength(handles, ...
                    histIm, bbox, k);
                handles.autoAnalysisTime(k) = handles.autoAnalysisTime(k) + toc;
            end
            
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
            data = cell(1,ciliaNum);
%             data = zeros(roiSize,roiSize,3,ciliaNum,'uint8');
            label = ones(1,ciliaNum) * handles.labelMode;
            % create a binary cilia region
            handles.bwCiliaRegion = bwlabel(handles.imageBw);
            % get histim
            histIm = im2double(handles.image);
            if size(handles.image, 3) == 3
                if isequal(handles.imageMode, 'r')
                    histIm = imagePreProcessing(histIm(:,:,1));
                else
                    histIm = imagePreProcessing(histIm(:,:,2));
                end
            else
                histIm = imagePreProcessing(histIm);
            end
            handles.autoAnalysisTime = zeros(1, ciliaNum);
            handles.manualAnalysisTime = zeros(1, ciliaNum);
            for k = 1 : ciliaNum
                % get cilia region
                [handles,ciliaRegion] = CiliaMethod.getCiliaRegion(handles, bbox, k);
                data{k} = ciliaRegion;
                % compute cilia length
                tic;
                handles = CiliaMethod.computeCiliaLength(handles, histIm, bbox,k);
                handles.autoAnalysisTime(k) = handles.autoAnalysisTime(k) + toc;
                % create show handle
                handles = CiliaMethod.createShowHandle(handles, bbox, k);
            end
            % update handles
            handles.roiNum = ciliaNum;
%             handles.data = data;
            handles.data = data;
            handles.label = label;
            handles.parentImage = ones(1,handles.roiNum) * handles.imageCursor;
            % show cilia in axes
            LabelMethod.showAllCilia(handles);
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
            if isequal(handles.imModePopmenu.String{handles.imModePopmenu.Value}, ...
                    'DAPI')
                value1 = 0;
                value2 = 0;
                value3 = 0;
            end
            % if handle has been deleted, recreate it
            if ~ishandle(handles.showRectHandle{roiId})
                handles = CiliaMethod.createShowHandle(handles, ...
                    handles.roiPosition, roiId);
            end
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
            if strcmp(handles.startLabelBtn.String,'Start Analysis')
                return;
            end
            CiliaMethod.deleteShowHandle(handles);
            handles = LabelMethod.filterCilia(handles);
            handles = LabelMethod.computeAndShowCilia(handles);
            handles = LabelMethod.detectOuterCilia(handles);
        end
        
    end
end