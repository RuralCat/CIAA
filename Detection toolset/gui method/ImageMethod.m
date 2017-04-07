classdef ImageMethod
    methods(Static)
        
        function [im, imMode] = readCiliaImage(imdir)
        % read cilia's image and classify it to 'r', 'g', 'b', 'merged', 'undef'
        %

        % read image
        [im, colorMap] = imread(imdir);
        % if colormap is not empty, using color map to do classification
        if ~isempty(colorMap)
            [~, y] = find(colorMap == max(colorMap(:)), 1);
            im = ind2rgb(im, colorMap);
            im = im2uint8(im);
        elseif size(im, 3) == 3
            % if colormap is empty, using the mean of each dimension
            rgbMean(1) = mean(mean(im(:,:,1)));
            rgbMean(2) = mean(mean(im(:,:,2)));
            rgbMean(3) = mean(mean(im(:,:,3)));
            [sortedMean, ind] = sort(rgbMean, 'descend');
            if sortedMean(1) / sortedMean(2) > 5 && ...
                    sortedMean(1) / sortedMean(3) > 5
                y = ind(1);
            else
                y = 4;
            end
        else
            % if colormap is empty and dimension is 1, 'undef'
            y = 5;
        end
        % set imMode
        switch y
            case 1
                imMode = 'r';
            case 2
                imMode = 'g';
            case 3
                imMode = 'b';
            case 4
                imMode = 'merged';
            case 5
                imMode = 'undef';
        end
        end
        
        function handles = processCurrentImage(handles)
            % the image may be merged, Cy3, FITC and DAPI, so we should
            % have different processing method
            
            % get imMode
            imMode = handles.imageMode;
            switch imMode
                case 'r'
                    tempImage = handles.image;
                    if size(handles.image, 3) == 3
%                         handles.image = tempImage(:,:,1);
                        handles.image = handles.image(:,:,[2,1,3]);
                    end
                    handles = LabelMethod.detectCilia(handles);
                    handles.image = tempImage;
                case 'g'
                    handles = LabelMethod.detectCilia(handles);
                case 'b'
                    handles = NucleiMethod.detectNuclei(handles);
                case 'merged'
                    % detect cilia on green channel
                    handles = LabelMethod.detectCilia(handles);
                    % detect nuclei on blue channel
                    handles = NucleiMethod.detectNuclei(handles);
                    % find the corresponding outer length of cilia
                    handles = LabelMethod.detectOuterCilia(handles);
                case 'undef'
                    % do nothing
                    handles.haveCilia = false;
            end

        end


        
    end
end