classdef HandlesMethod
    methods(Static)
        function handles = initializeHandles(handles)
            handles.tsCursor = 0;
            handles.totalImage = 0;
            handles.imageCursor = 0;
            handles.tsSize = 10000;
            handles.roiSize = 100;
            handles.data = [];
            handles.label = [];
            handles.parentImage = [];
            handles.roiRegion = [];
            handles.roiPosition = [];
            handles.labelMode = 0;
            handles.isExistTs = false;
            handles.snrThreshold = handles.snrSlider.Value;
            handles.directionThreshold = handles.directionSlider.Value;
        end
        
        function handles = setFigureName(handles,name)
            set(handles.tstFigure,'Name',['Detection Toolset','  [',...
                name,']']);
        end
        
    end
end