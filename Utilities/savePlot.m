%% savePlot
%
% Update: s
% Modified for running online. Save '.fig' in bin/temp directory of HIRO.
% Nov. 2012
%
% This function saves the plot for linux/pc OSs. For PC it will save the
% plot in three types: .png, .fig, and .epsc. 
%
% Inputs:
% fPath              - File path trunk where your results are saved.
% StratTypeFodler   - Strategy Specific Folder
% handle            - Handle for plot you want to save
% plotName          - Name you want to assign the plot in the file
%%
function savePlot(fPath, StratTypeFolder, FolderName, handle, plotName)

%%  Select Handles        
    if(length(handle)>1)
        hdl = handle(1);
        axes(hdl);
    else
        hdl = handle;
        %axes(hdl);
    end
    %% EncoderIncompatibility: saveas(hdl,'/home/vmrguser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin/tmp','fig');
    
% %%  Set Directory    
%     if(ispc)
%         % Make matlab folder
%         dir = strcat(fPath,StratTypeFolder,FolderName);
%         
%         % Check if directory exists, if not create a directory
%         if(exist(strcat(dir,'\\',plotName),'dir')==0)
%             mkdir(dir,plotName);
%         end
%         
% %%      Select Handles        
%         if(length(handle)>1)
%             hdl = handle(1);
%             axes(hdl);
%         else
%             hdl = handle;
%             %axes(hdl);
%         end
%         
% %% Get Time
%         date    = clock;            % y/m/d h:m:s
%         h       = num2str(date(4));
%         min     = date(5);          % minutes before 10 appear as '9', not '09'. 
% 
%     % Fix appearance of minutes
%         if(min<10)                              % If before 10 minutes
%             min = strcat('0',num2str(min));
%         else
%             min = num2str(min);
%         end
%         
% %%      Save         
%         nm = strcat(fPath,StratTypeFolder,FolderName,'\\',plotName,'\\',FolderName);%'plot',num2str(h),num2str(min));
%         saveas(hdl,nm,'png');         
%         saveas(hdl,nm,'fig');
%         saveas(hdl,nm,'epsc');        
%     else
%         print -depsc    diffPlot.eps;
%         print -dpslatex diffPlot.eps;
%         print -dfig     diffPlot.fig;
%         print -dpng     diffPlot.png;
% %        print '\home\juan\Documents\Results\PivotApproach' -depsc Multiplot.eps
%     end
end