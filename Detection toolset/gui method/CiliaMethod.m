classdef CiliaMethod
    methods(Static)
        function handles = computeCiliaLength(handles, bbox, k)
            % get bounding box
            padlen = 5;
            rowStart = max(bbox(handles.ciliaIdx(k),1)-padlen,1); 
            colStart = max(bbox(handles.ciliaIdx(k),2)-padlen,1);
            rowEnd = min(bbox(handles.ciliaIdx(k),3) + padlen,handles.imageW);
            colEnd = min(bbox(handles.ciliaIdx(k),4) + padlen,handles.imageH);
            % get box binary region
            localRegion = handles.bwCiliaRegion(rowStart:rowEnd,colStart:colEnd);
            localRegion(localRegion~=handles.ciliaIdx(k)) = 0;
            % find outline
            localRegion = imdilate(localRegion,strel('disk',4));
            B = bwboundaries(localRegion,'noholes');
            x = B{1}(:,1) + rowStart - 1;
            y = B{1}(:,2) + colStart - 1;
            handles.outLine{k} = [x,y];
            % find cilia skeleton and compute cilia length
            ciliaSkeleton = bwmorph(localRegion,'thin',Inf);
            ciliaSkeleton = bwboundaries(ciliaSkeleton,'noholes');
            x = ciliaSkeleton{1}(:,1) + rowStart - 1;
            y = ciliaSkeleton{1}(:,2) + colStart - 1;
            handles.skeleton{k} = [x,y];
            ciliaLength = 0;
            for s = 1 : length(x)-1
                ciliaLength = ciliaLength + sqrt(sum((ciliaSkeleton{1}(s,:)...
                    - ciliaSkeleton{1}(s+1,:)).^2, 2));
            end
            handles.ciliaLength{k} = ciliaLength/2;
        end
        
        function deleteShowHandle(handles)
            try
                for k = 1 : handles.roiNum
                    delete(handles.showRectHandle{k});
                    delete(handles.showOutlineHandle{k});
                    delete(handles.showLengthHandle{k});
                end
            end
        end
        
        function handles = createShowHandle(handles, bbox, k)
            hold(handles.imageAxes,'on'); 
            % rect handle
            handles.showRectHandle{k} = rectangle('parent',handles.imageAxes,...
                'Position',[...
                bbox(handles.ciliaIdx(k),2),...
                bbox(handles.ciliaIdx(k),1),...
                bbox(handles.ciliaIdx(k),6),...
                bbox(handles.ciliaIdx(k),5)],...
                'LineWidth',0.01,'EdgeColor','r','Visible','off',...
                'Tag',num2str(k),'ButtonDownFcn',{@CiliaMethod.handleDownFcn});
            % outline handle
            handles.showOutlineHandle{k} = plot(...
                handles.outLine{k}(:,2),handles.outLine{k}(:,1),...
                'b','LineWidth',0.01,'parent',handles.imageAxes,...
                'Visible','off','Tag',num2str(k),...
                'ButtonDownFcn',{@CiliaMethod.handleDownFcn});

            % length handle
            handles.showLengthHandle{k} = text(...
                bbox(handles.ciliaIdx(k),2),...
                bbox(handles.ciliaIdx(k),1),...
                num2str(handles.ciliaLength{k}),...
                'Color','r','Visible','off','parent',handles.imageAxes,...
                'Tag',num2str(k),'ButtonDownFcn',{@CiliaMethod.handleDownFcn});
            hold(handles.imageAxes,'off');
        end
        
        function [handles, ciliaRegion] = getCiliaRegion(handles, bbox, k)
            %
            bbox = bbox(handles.ciliaIdx(k),:);
            roiSize = handles.ts.roiSize;
            handles.roiRegion(bbox(1):bbox(3),bbox(2):bbox(4)) = k;
            ciliaRegion = CiliaMethod.getCiliaTrainingRegion(handles.image,...
                bbox, roiSize);
        end
        
        function localIm = getCiliaTrainingRegion(image, bbox, tsSize)
            % get image size
            [imageH, imageW, imageD] = size(image);
            % we need 3 channel image
            if imageD == 1
                image = repmat(image,[1,1,3]);
            end
            % define padding length
            padl = ceil(0.4*bbox(5:6));
            xstart = max(bbox(1) - padl(1),1);
            xend = min(bbox(3) + padl(1),imageH);
            xl = xend - xstart;
            ystart = max(bbox(2) - padl(2),1);
            yend = min(bbox(4) + padl(2),imageW);
            yl = yend - ystart;
            % make a squre shape
            sl = max(xl, yl);
            diffl = abs(xl - sl);
            xstart = max(xstart - floor(diffl/2), 1);
            xend = min(xend + diffl - floor(diffl/2), imageH);
            diffl = abs(yl - sl);
            ystart = max(ystart - floor(diffl/2), 1);
            yend = min(yend + diffl - floor(diffl/2), imageW);
            % check if it is a squre
            xl = xend - xstart;
            yl = yend - ystart;
            if xl ~= yl
                sl = min(xl, yl);
                diffl = abs(xl - sl);
                xstart = xstart + floor(diffl/2);
                xend = xend - (diffl - floor(diffl/2));
                diffl = abs(yl - sl);
                ystart = ystart + floor(diffl/2);
                yend = yend - (diffl - floor(diffl/2));
            end
            % get local image and resize it to tsSize
            localIm = image(xstart:xend,ystart:yend,:);
            localIm = imresize(localIm, [tsSize, tsSize]); 
        end
        
        function handleDownFcn(hObject,eventdata)
            handles = guidata(hObject);
            % return if it is not a labeling status
            if strcmp(get(handles.startLabelBtn,'Enable'),'off') || ...
                    strcmp(get(handles.startLabelBtn,'string'),'Start Label')
                return;
            end
            % get tag
            idx = str2double(hObject.Tag);
            % change label
            selectionType = get(gcbf,'SelectionType');
            switch selectionType
                case 'normal'
                    handles.label(idx) = xor(handles.label(idx),1);
                    handles = LabelMethod.showCilia(handles,idx);    
                case 'alt'
                    handles.label(idx) = min(bitxor(handles.label(idx),2),2);
                    handles = LabelMethod.showCilia(handles,idx);
                case 'open'
                    handles.label(idx) = xor(handles.label(idx),1);
                    handles = LabelMethod.showCilia(handles,idx);  
                    handles.ciliaShowIdx = idx;
                    handles = LabelMethod.showCiliaImage(handles);
            end
            % update handles
            guidata(hObject,handles);
        end
        
    end
end