%% Primitives Layer
%
% 2012Oct - Updated to handle online performance. Will deail with a growing
% force data structure instead of having the complete data set from the
% beginning. No plotting in online mode.
%
% Perform regression curves for force moment reasoning          
% Iterate through each of the six force-moment plots Fx Fy Fz Mx My Mz
% generated in snapData3 and superimpose regressionfit lines in each of
% the diagrams.   
%
% Inputs:
% fPath
% StrategyType      - PWD - string
% StratTypeFolder   - What strategy - string
% FolderName        - Folder name string where results are saved
% forceData         - array of forde signals from Fx to Mz, growing over time
% statData          - empty statistical data array
% globalRange       - 
% stateData         - column vector of start times for automata states
% axesHandles       - vector of axes handles
% Index             - what force axis are we running
%
% Output
% statData          -  nx7 int array that holds all statistical information of the signal
% curHanlde         - handle for matlab plots
% gradLabels        - array of gradient labels/strings
% localRangeStart   - index tied to simulatedLoadData and fitRegressionCurves
%--------------------------------------------------------------------------
function [localRangeStart, statData,curHandle, gradLabels] = primitivesLayer(fPath,StrategyType,StratTypeFolder,FolderName,...
                                                            forceData,statData,...
                                                            localRangeStart,globalRange,...
                                                            stateData,axesHandles,TL,BL,Index)

%% Global variables
    %global Optimization;        % Used if performing gradient calibration
%--------------------------------------------------------------------------
    global DB_PRINT;            % Used to plot
    %global DB_WRITE;
%--------------------------------------------------------------------------    
    %global statData;            % nx7 int array that holds all statistical information of the signal
    global statDataInitFlag;    % To init the statData structure
    statDataInitFlag  = false;  % Change flag so we only allocate once
    
    
    global segmentIndex;        % To init the counter for this routine
    segmentIndex = 1;
    %global prevSegmentIndex;   % keep history
    
    % Used in rsqCorrelation->fitRegressionCurves->primitivesLayer to set statData.
    %global curStatData;                % Introduce the variable into input and output
    curStatData = zeros(10,7,'double'); % Initialize global value
    coder.varsize('curStatData');       % Must make change in size explicit
    
    global curStatDataFlag;
    curStatDataFlag = false;
%--------------------------------------------------------------------------
    %global indexStart;          % Value of index to indicate where we should load force data
    %global wStart;              % Value that keeps index for regression fit. Not same as indexStart.
    %global windowStart;         % Value of window that regression studies
%--------------------------------------------------------------------------
    %global gradLabels;           % Structure of gradient thresholds
    global Type;                 % Array of force-moment labels
%--------------------------------------------------------------------------
%% Initialization  

    gradLabels = [ 'bpos';   ... % big   pos grads
                   'mpos';   ... % med   pos grads
                   'spos';   ... % small pos grads
                   'bneg';   ... % big   neg grads
                   'mneg';   ... % med   neg grads
                   'sneg';   ... % small neg grads
                   'cons';   ... % constant  grads
                   'pimp';   ... % large pos grads
                   'nimp';   ... % large neg grads
                   'none'];
               
    Type = ['Fx';'Fy';'Fz';'Mx';'My';'Mz']; 
    
    % Allocate      
%     if(statDataInitFlag)
%         
%         % Counter
%         segmentIndex    =1;                         % global and updated inside fitRegressionCurves
%         %prevSegmentIndex=1;                         % keep a history
%         
%         % Force Indeces: Moving
%         %indexStart  =1;     
%         %wStart      =1;
%         %windowStart =1;
%     end
        
%% Determine how many handles
    if(DB_PRINT)
        pHandle = axesHandles(Index);               % Retrieve the handle for each of the force curves
    else
        pHandle=-1;
    end   

%% Compute regression curves for each force curve
    
    %[curStatData,CurStatDataFlag,curHandle]=fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,...
    %                                                            forceData,globalRange,stateData,pHandle,TL,BL,Index,gradLabels,Type);
%     [localRangeStart,curStatData,curHandle]=fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,...
%                                                                 localRangeStart, globalRange,...
%                                                                 forceData, stateData,...
%                                                                 pHandle,TL,BL,Index,gradLabels,Type,...
%                                                                 curStatData);
    [curStatData,curHandle]=fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,...
                                                                globalRange,...
                                                                forceData, stateData,...
                                                                pHandle,TL,BL,Index,gradLabels,Type,...
                                                                curStatData);                                                            

    % The value of indexStart determines if we will fit chunks of new force data separately or if we want to keep that index at 1 and keep a growing window. 
    % DesForce = forceData(indexStart:end,:); % Start where simulatedLoadedData ends
    %tic;
    % [curStatData,curHandle]=fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,DesForce,stateData,pHandle,TL,BL,Index,gradLabels,Type);  
    %toc;
    
    % If some statistical information was produced add it to the statData structure, otherwise loop around
    r=size(curStatData);
    %if(r(1)==0)
    %   statData = 0;
    %else
    if(r(1)~=0 && curStatDataFlag)
        statData(segmentIndex:segmentIndex+r(1)-1,:) = curStatData(:,:);
        segmentIndex = segmentIndex+r(1);
    end
        
%%  Gradient Calibration is only performed OFFLINE -- comment out  
%     if(Optimization==1)
%        gradientCalibration(fPath,StratTypeFolder,stateData,statData,Index);
%     end        
end