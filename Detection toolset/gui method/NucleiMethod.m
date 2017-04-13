classdef NucleiMethod
    methods(Static)
        
        function handles = detectNuclei(handles)
            % get some paras
            minNucleiArea = str2double(handles.minNucleiAreaTxt.String);
            edgeFactor = str2double(handles.edgeFactorTxt.String);
            % detect nuclei
            nucleiBw = nucleiDetection(handles.image, minNucleiArea, edgeFactor);
            % count
            nucleiCC = bwconncomp(nucleiBw, 4);
            handles.nucleiNum = nucleiCC.NumObjects;
            % create show handle
            handles.nucleiBound = bwboundaries(nucleiBw, 4);
            handles = NucleiMethod.createNucleiBoundHandle(handles);
            % show nuclei
            NucleiMethod.showNucleiBound(handles);
        end
        
        function handles = createNucleiBoundHandle(handles)
            hold(handles.imageAxes, 'on');
            for k = 1 : handles.nucleiNum
                handles.showNucleiHandle{k} = plot(...
                    handles.nucleiBound{k}(:,2), handles.nucleiBound{k}(:,1), ...
                    'r', 'LineWidth', 0.01, 'parent', handles.imageAxes, ...
                    'Visible', 'off');
            end
            hold(handles.imageAxes, 'off');
        end
        
        function handles = showNucleiBound(handles)
            % if handle has been deleted
            handles = NucleiMethod.createNucleiBoundHandle(handles);
            % if show
            if handles.nucleiNum == 0
                return;
            end
            if isequal(handles.imModePopmenu.String{handles.imModePopmenu.Value}, ...
                    'DAPI')
                value = handles.showNucleiCheckbox.Value;
            else
                value = 0;
            end
            %
            if value
                for k = 1 : handles.nucleiNum
                    handles.showNucleiHandle{k}.Visible = 'on';
                end
            else
                for k = 1 : handles.nucleiNum
                    handles.showNucleiHandle{k}.Visible = 'off';
                end
            end
        end
        
        function handles = deleteNucleiHandle(handles)
            try
                for k = 1 : handles.nucleiNum
                    delete(handles.showNucleiHandle{k});
                end
            end
        end
        
    end 
end