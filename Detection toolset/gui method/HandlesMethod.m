classdef HandlesMethod
    methods(Static)
        function handles = initializeHandles(handles)
            handles.tsCursor = 0;
            handles.totalImage = 0;
            handles.imageCursor = 0;
            handles.tsSize = 10000;
            handles.roiSize = 100;
            handles.data = [];
            handles.image = {};
            handles.label = [];
            handles.parentImage = [];
            handles.roiRegion = [];
            handles.roiPosition = [];
            handles.ciliaIdx = [];
            handles.labelMode = 0;
            handles.isExistTs = false;
            handles.imageMode = 'undef';
            if isfield(handles, 'snrSlider')
                handles.snrThreshold = handles.snrSlider.Value;
                handles.directionThreshold = handles.directionSlider.Value;
            end
        end
        
        function handles = setFigureName(handles,name)
            set(handles.tstFigure,'Name',['Detection Toolset','  [',...
                name,']']);
        end
        
        function handles = updateImModePopmenu(handles, imMode)
           % set popmenu string
           handles.imModePopmenu.Enable = 'on';
           switch imMode
               case 'r'
                   handles.imModePopmenu.String = {'Cy3'};
               case 'g'
                   handles.imModePopmenu.String = {'FITC'};
               case 'b'
                   handles.imModePopmenu.String = {'DAPI'};
               case 'merged'
                   handles.imModePopmenu.String = {'Merged'; 'Cy3'; 'FITC'; 'DAPI'};
               case 'undef'
                   handles.imModePopmenu.String = {};
                   handles.imModePopmenu.Enable = 'off';
           end
        end
        
    end
end