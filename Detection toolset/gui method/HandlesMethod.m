classdef HandlesMethod
    methods(Static)
        function handles = initializeHandles(handles)
            handles.tsCursor = 0;
            handles.totalImage = 0;
            handles.imageCursor = 0;
            handles.tsSize = 10000;
            handles.roiSize = 100;
            handles.startLabelBtn.String = 'Start Analysis';
            handles.labelMode = 0;
            handles.isExistTs = false;
            handles.haveCilia = false;
            handles = HandlesMethod.initializeImage(handles);
            if isfield(handles, 'snrSlider')
                handles.snrThreshold = handles.snrSlider.Value;
                handles.directionThreshold = handles.directionSlider.Value;
            end
        end
        
        function handles = initializeImage(handles)
            % delete show handle
            CiliaMethod.deleteShowHandle(handles);
            NucleiMethod.deleteNucleiHandle(handles);
            % initial paras
            handles.data = [];
            handles.image = {};
            handles.label = [];
            handles.parentImage = [];
            handles.roiRegion = [];
            handles.roiPosition = [];
            handles.ciliaIdx = [];
            handles.skeleton = [];
            handles.ciliaLength = [];
            handles.manualCiliaLength = [];
            handles.outerSkeleton = [];
            handles.outerCiliaLength = [];
            handles.manualOuterCiliaLength = [];
            handles.autoAnalysisTime = [];
            handles.manualAnalysisTime = [];
            handles.imageMode = 'undef';
            handles.nucleiNum = 0;
        end
        
        function handles = setFigureName(handles,name)
            set(handles.tstFigure,'Name',['Detection Toolset','  [',...
                name,']']);
        end
        
        function handles = updateImModePopmenu(handles, imMode)
           % set popmenu string
           handles.imModePopmenu.Enable = 'on';
           handles.imModePopmenu.Value = 1;
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