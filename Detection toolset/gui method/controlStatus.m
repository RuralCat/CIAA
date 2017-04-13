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
        
        function setImageBtn(handles,btnEnable)
            set(handles.importImageBtn,'enable',btnEnable{1});
            set(handles.startLabelBtn,'enable',btnEnable{2});
            set(handles.nextImageBtn,'enable',btnEnable{3});
            set(handles.skipImageBtn,'enable',btnEnable{4});
        end
        
        function setLabelControlBtn(handles, btnEnable)
            if btnEnable && isequal(handles.startLabelBtn.String, 'End Analysis')
                e = 'on';
            else
                e = 'off';
            end
            handles.addCiliaBtn.Enable = e;
            handles.changeLabelModeBtn.Enable = e;
            handles.cnnPredictBtn.Enable = e;
            handles.snrThresTxt.Enable = e;
            handles.snrSlider.Enable = e;
            handles.directionThresTxt.Enable = e;
            handles.directionSlider.Enable = e;
            handles.showRectCheckbox.Enable = e;
            handles.showOutlineCheckbox.Enable = e;
            handles.showLenCheckbox.Enable = e;
            
        end
        
        function setCiliaBtn(handles,btnEnable)
            if nargin == 1
                btnEnable = {'on','on','on','on', 'on', 'on'};
            end
            handles.previousCiliaBtn.Enable = btnEnable{1};
            handles.nextCiliaBtn.Enable = btnEnable{2};
            handles.correctBtn.Enable = btnEnable{3};
            handles.okBtn.Enable = btnEnable{4};
            handles.zoomInBtn.Enable = btnEnable{5};
            handles.zoomOutBtn.Enable = btnEnable{6};
        end
        
        function setNucleiBtn(handles, btnEnable)
            if btnEnable
                e = 'on';
            else
                e = 'off';
            end
            handles.minNucleiAreaTxt.Enable = e;
            handles.edgeFactorTxt.Enable = e;
            handles.showNucleiCheckbox.Enable = e;
        end
            
    end
end