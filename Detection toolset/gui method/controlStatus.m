classdef controlStatus
    methods(Static)
        function setFileMenu(handles,isEnable)
            if nargin == 1
                isEnable = true;
            end
            if isEnable
                fileMenuEnable = {'on','on','on','on'};
            else
                fileMenuEnable = {'off','off','off','off'};
            end
            set(handles.newtsMenu,'enable',fileMenuEnable{1});
            set(handles.opentsMenu,'enable',fileMenuEnable{2});
            set(handles.savetsMenu,'enable',fileMenuEnable{3});
            set(handles.saveasMenu,'enable',fileMenuEnable{4});
        end
        
        function setOperationMenu(handles,isEnable)
            if nargin == 1
                isEnable = true;
            end
            if isEnable
                operationMenuEnable = {'on','on'};
            else
                operationMenuEnable = {'off','off'};
            end
            set(handles.mergetsMenu,'enable',operationMenuEnable{1});
            set(handles.trainingSetView,'enable',operationMenuEnable{2});
        end
        
        function setTxt(handles)
            set(handles.leftImageNumTxt,'string',num2str(handles.totalImage-handles.imageCursor));
            set(handles.totalImageNumTxt,'string',num2str(handles.totalImage));
            set(handles.lefttsNumTxt,'string',num2str(length(find(handles.ts.label~=2))));
            set(handles.totaltsNumTxt,'string',num2str(handles.ts.trainingSetSize));
            embedWaitbar(length(find(handles.ts.label~=2))/...
                handles.ts.trainingSetSize,handles.progressbar);
        end
        
        function setBtn(handles,btnEnable)
            set(handles.importImageBtn,'enable',btnEnable{1});
            set(handles.startLabelBtn,'enable',btnEnable{2});
            set(handles.nextImageBtn,'enable',btnEnable{3});
            set(handles.previousImageBtn,'enable',btnEnable{4});
            if length(btnEnable) > 4
                set(handles.changeLabelModeBtn,'enable',btnEnable{5});
            else
                set(handles.changeLabelModeBtn,'enable','off');
            end
            if length(btnEnable) > 5
                set(handles.skipImageBtn,'enable',btnEnable{6});
            else
                set(handles.skipImageBtn,'enable','off');
            end
            if length(btnEnable) > 6
                handles.addCiliaBtn.Enable = btnEnable{7};
            else
                handles.addCiliaBtn.Enable = 'off';
            end
        end
        
        function setCiliaBtn(handles,btnEnable)
            if nargin == 1
                btnEnable = {'on','on','on','on'};
            end
            handles.previousCiliaBtn.Enable = btnEnable{1};
            handles.nextCiliaBtn.Enable = btnEnable{2};
            handles.correctBtn.Enable = btnEnable{3};
            handles.okBtn.Enable = btnEnable{4};
        end
            
    end
end