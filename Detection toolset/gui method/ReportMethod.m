classdef ReportMethod
    methods(Static)
        function report = createNewReport(handles)
            imageNum = length(handles.imageStack);
            report.imageNum = imageNum;
            report.imageMode = cell(1, imageNum);
            report.nucleiNum = zeros(1, imageNum);
            report.ciliaNum = zeros(1, imageNum);
            report.ciliaPosition = cell(1, imageNum);
            report.ciliaLength = cell(1, imageNum);
            report.outerCiliaLength = cell(1, imageNum);
            report.inOutRatio = cell(1, imageNum);
            report.autoAnalysisTime = cell(1, imageNum);
            report.manualCiliaLength = cell(1, imageNum);
            report.manualOuterCiliaLength = cell(1, imageNum);            
            report.manualInOutRatio = cell(1, imageNum);
            report.manualAnalysisTime = cell(1, imageNum);
        end
        
        function handles = addToCurrentReport(handles)
            report = handles.report;
            idx = handles.imageCursor;
            report.imageMode{idx} = handles.imageMode;
            report.nucleiNum(idx) = handles.nucleiNum;
            report.ciliaNum(idx) = handles.roiNum;
            report.ciliaPosition{idx} = handles.roiPosition(handles.ciliaIdx);
            report.ciliaLength{idx} = handles.ciliaLength;
            report.outerCiliaLength{idx} = handles.outerCiliaLength;
            report.autoAnalysisTime{idx} = handles.autoAnalysisTime;
            report.manualCiliaLength{idx} = handles.manualCiliaLength;
            report.manualOuterCiliaLength{idx} = handles.manualOuterCiliaLength;
            report.manualAnalysisTime{idx} = handles.manualAnalysisTime;
            
        end
        
        function writeReportToExcel(handles)
            
        end
        
        
    end
end