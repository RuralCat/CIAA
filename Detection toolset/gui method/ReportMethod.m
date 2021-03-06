classdef ReportMethod
    methods(Static)
        
        function report = createNewReport(handles)
            imageNum = length(handles.imageStack);
            report.imageNum = imageNum;
            report.imageStack = handles.imageStack;
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
            trueCiliaIdx = 1 : 1 : handles.roiNum;
            trueCiliaIdx = trueCiliaIdx(handles.label == 1);
            trueCiliaNum = length(trueCiliaIdx);
            report.imageMode{idx} = handles.imageMode;
            report.nucleiNum(idx) = handles.nucleiNum;
            report.ciliaNum(idx) = trueCiliaNum;
            report.ciliaPosition{idx} = handles.roiPosition(handles.ciliaIdx(trueCiliaIdx), :);
            report.ciliaLength{idx} = handles.ciliaLength(trueCiliaIdx);
            report.outerCiliaLength{idx} = handles.outerCiliaLength(trueCiliaIdx);
            report.autoAnalysisTime{idx} = handles.autoAnalysisTime(trueCiliaIdx);
            report.manualCiliaLength{idx} = handles.manualCiliaLength(trueCiliaIdx);
            report.manualOuterCiliaLength{idx} = handles.manualOuterCiliaLength(trueCiliaIdx);
            report.manualAnalysisTime{idx} = handles.manualAnalysisTime(trueCiliaIdx);
            % compute ratio
            report.inOutRatio{idx} = 100 * report.outerCiliaLength{idx} ./ ...
                (report.ciliaLength{idx} + 1e-4);
            report.manualInOutRatio{idx} = 100 * report.manualOuterCiliaLength{idx} ./ ...
                (report.manualCiliaLength{idx} + 1e-4);
            handles.report = report;
        end
        
        function writeReportToExcel(handles, filePath)
            % get report
            report = handles.report;
            blankRow = cell(1, 10);
            % create report name
            time = clock;
            time = [num2str(time(1)), '_', num2str(time(2)), '_', ...
                num2str(time(3)), '_', num2str(time(4)), '_', num2str(time(5))];
            reportName = ['Cilia Report ', time];
            reportFile = blankRow;
            reportFile{1,5} = reportName;
            reportFile = cat(1, reportFile, blankRow);
            % create image's format and cilia's format
            imageFormat = blankRow;
            imageFormat{1} = 'Image Id';
            imageFormat{2} = 'Image Name';
            imageFormat{3} = 'Image Type';
            imageFormat{4} = 'Nuclei Number';
            ciliaFormat = blankRow;
            ciliaFormat{1} = 'Cilium Id';
            ciliaFormat{2} = 'Position';
            ciliaFormat{3} = 'Total Length(pixel)';
            ciliaFormat{4} = 'Outer Length(pixel)';
            ciliaFormat{5} = 'Out/In Ratio(%)';
            ciliaFormat{6} = 'Analysis Time(ms)';
            ciliaFormat{7} = 'Manual Total Length(pixel)';
            ciliaFormat{8} = 'Manual Outer Length(pixel)';
            ciliaFormat{9} = 'Manual Out/In Ratio(%)';
            ciliaFormat{10} = 'Manual Analysis Time(ms)';
            % loop over image
            for k = 1 : report.imageNum
                if isempty(report.imageMode{k})
                    break;
                end
                imageProp = blankRow;
                imageProp{1} = k;
                imageProp{2} = report.imageStack{k};
                imageProp{3} = report.imageMode{k};
                imageProp{4} = report.nucleiNum(k);
                reportFile = cat(1, reportFile, imageFormat);
                reportFile = cat(1, reportFile, imageProp);
                reportFile = cat(1, reportFile, ciliaFormat);
                % loop over cilia
                for t = 1 : report.ciliaNum(k)
                    ciliaProp = blankRow;
                    ciliaProp{1} = t;
                    ciliaPosi = report.ciliaPosition{k}(t, [1,2,5,6]);
                    ciliaPosi = ['[', num2str(ciliaPosi(1)), ',', ...
                        num2str(ciliaPosi(2)), ',', num2str(ciliaPosi(3)), ',',...
                        num2str(ciliaPosi(4)), ']'];
                    ciliaProp{2} = ciliaPosi;
                    ciliaProp{3} = report.ciliaLength{k}(t);
                    ciliaProp{4} = report.outerCiliaLength{k}(t);
                    ciliaProp{5} = report.inOutRatio{k}(t);
                    ciliaProp{6} = report.autoAnalysisTime{k}(t);
                    ciliaProp{7} = report.manualCiliaLength{k}(t);
                    ciliaProp{8} = report.manualOuterCiliaLength{k}(t);
                    ciliaProp{9} = report.manualInOutRatio{k}(t);
                    ciliaProp{10} = report.manualAnalysisTime{k}(t);
                    reportFile = cat(1, reportFile, ciliaProp);
                end
                reportFile = cat(1, reportFile, blankRow);
            end
            % write to excel or csv
            try
                % get full path
                fullPath = fullfile(filePath, [reportName, '.xlsx']);
                % create a excel server
                excel = actxserver('Excel.application');
                % add a work book
                workbook = excel.Workbooks.Add;
                % get excel sheet
                sheets = workbook.Sheets.Item(1);
                sheets.Activate;
                % set write range
                N = num2str(size(reportFile, 1));
                Select(Range(excel, ['A1:J', N]));
                % export data to selected region
                excel.selection.Value = reportFile;
                % merge cells
                sheets.Range('A1:J1').MergeCells = 1;
                % save ('xlsx format code: 51')
                workbook.SaveAs(fullPath, 51);
                % close file
                workbook.Close(false);
                excel.Quit;
                excel.delete;
            catch
                % get full path
                fullPath = fullfile(filePath, [reportName, '.dat']);
                % open a file
                fid = fopen(fullPath, 'w');
                % write image name
                fprintf(fid, '%s\n\n', reportName);
                % define formatSpec
                imageHeadFormatSpec = '%s\t %s\t %s\t %s\n';
                imagePropFormatSpec = '%d\t %s\t %s\t %d\n';
                ciliaHeadFormatSpec = '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n';
                ciliaPropFormatSpec = '%d\t %s\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\n';
                % loop over image to write image
                count = 3;
                for k = 1 : report.imageNum
                    if isempty(report.imageMode{k})
                        break;
                    end
                    fprintf(fid, imageHeadFormatSpec, reportFile{count, 1:4});
                    count = count + 1;
                    fprintf(fid, imagePropFormatSpec, reportFile{count, 1:4});
                    count = count + 1;
                    fprintf(fid, ciliaHeadFormatSpec, reportFile{count, :});
                    count = count + 1;
                    for t = 1 : report.ciliaNum(k)
                        fprintf(fid, ciliaPropFormatSpec, reportFile{count, :});
                        count = count + 1;
                    end
                    fprintf(fid, '\n');
                end
                fclose(fid);
            end
                    
        end
        
    end
end