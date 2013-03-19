%%************************** Documentation *********************************
% Analyze a single force or moment element curve for snap assembly, and,
% using a linear regression with corrleation thresholds, segement the data,
% into segmentes of linear plots. 
%
% Online analysis: 
% This algorithm runs in parallel and incrementally as the force
% data size grows over time. See workings of standard algorithm below. If a
% correlation threshold is not broken and the end of the data size is
% reached before the actual task has finished (i.e., beginning, middle,
% near end stages of the algorithm) we want to take a snap shot of relevant
% variables and start there next time around instead of having to
% recompute everything. Saves time and more computationally inexpensive.
% Part of online implementation - August 2012.
%
% Stanard Algorithm Assumes:
% (1) that the correlation of fitted data will be high until there is
% significant change in data. It is at that time, that we want to segment. 
% (2) Each forceAxis plot has their own scope. No need to worry about
% overwriting variables.
%
% Tests:
% localRange = index range for vector used to analyze data
% globalRange = different than local range. This is a vector that reprsents
% the size and indeces of the buffered force data. This vector will usually
% be larger than localRange. However, localRange grows over each iteration
% and will eventualy be greater than globalRange.
%
% (1) We want to compare localRangeEnd to globalRangeEnd while the terminal 
% condition is false. If 
%           "localRangeEnd > globalRangeEnd && runRCBHT==1",
% then exit the function and save indeces. Flag locGglob is set to true here. 
% Analysis will continue next iteration with a larger globalRange vector
% and updated localRange indeces.
%
% (2) Terminal Condition is true.
% Elseif the local range is greater than global and the terminal condition is
% true:
%            "localRangeEnd > globalRangeEnd && runRCBHT==0",
% Then, if localRangeStart >= globalRangeEnd; terminate. 
% Else, localRange = localRangeStart:globalRangeEnd;
%
%% Input Parameters:
% fPath             : path string to the "Results" directory
% StrategyType      : refers to PA10-PivotApproach, or HIRO SideApproach "HSA"
% StratTypeFolder   : path string to Position/ForceControl: //StraightLineApproach or Pivot Approach or Side Approach
% Type              : type of data to analyze: Fx,Fy,Fz,Mx,My,Mz
% forceData         : Contains an nx1 vector of the type of force data
%                     indicated
% globalRange       : a 1xn vector whose first and last element represent the indeces for the currentForceData's true window
% stateData         : column vector of state transition times
% wStart            : the time, in milliseconds, at which this segment
%                     clock starts
% pHandle           : handle to the corresponding FxyzMxyz plot, to
%                     superimpose lines. 
% TL                : the top axes limits of each of the eight subplots SJ1,SJ2,
%                     Fx,Fy,Fz,Mx,My,Mz
% BL                : Same as TL but bottom limits. 
% curStatData       : curStatData is a nx7 array that holds statistical data of each linear fit segment. 
%                     It needs to be a global to maintain its scope when we move to rsqCorrelation and use this array there over multiple
%                     iterations. 
%
%% Output Parameters:
% curStatData       : contains 1 index, and 7 statistics of each segmented line fit:
%                     average value of segmen, max val, min val, start
%                     time, end time, gradient value, gradient label string.
% rHandle           : handle to the segmented plot. 
% gradLabels        : very important structure. Used by
%                     GradientClassification.m and by primMatchEval.m
%                     Consists of all possible gradient classifications. 
%                     It is important to define here, to keep coherence
%                     with any changes that may take place and avoid
%                     braking other parts of the code
% index             : the axis that we are analyzing
% curStatData       : curStatData is a nx7 array that holds statistical data of each linear fit segment. 
%                     It needs to be a global to maintain its scope when we move to rsqCorrelation and use this array there over multiple
%                     iterations. 
%
%% Globals
%
%**************************************************************************
% function [localRangeStart, curStatData, rHandle] = fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,...
%                                                      localRangeStart, globalRange,...
%                                                      forceData, stateData,...
%                                                      pHandle,TL,BL,index,gradLabels,Type,...
%                                                      curStatData)
function [curStatData, rHandle] = fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,...
                                                     globalRange,...
                                                     forceData, stateData,...
                                                     pHandle,TL,BL,index,gradLabels,Type,...
                                                     curStatData)
    % Resuming regression when an end was not found
    global regressionInitializeFlag;                % Set in pRCBHT to true; Set to false when end of window reached but with no correlation break. Helps us resume
    regressionInitializeFlag = 1; 
    
    %global curStatDataFlag;                         % Flag that determines whether or not curStatData has been updated or not. 
    %curStatDataFlag = false;
    %global curStatData;                            % curStatData is a nx7 array that holds statistical data of each linear fit segment. 
                                                    % It needs to be a global to maintain its scope when we move to rsqCorrelation and use this array there over multiple
                                                    % iterations. 
    global curStatIndex;                            % Accompanying index.
    
    % global indexStart;
    % global windowStart;
    global localRangeStart;                         % This value is used in simulatedLoadData.m to tell where to start the globalRange on the next iteration. 
                                                    % Also note that simulatedLoadData.m always initializes this variable to 1 after use. No need to init here.
    global movingIndex;                             % It's important to maintain the value of movingIndex in situations where correlation happens and we grow 
                                                    % our analysis window (the local range), and we do not want to repeat the analysis but start from where we took off.
%--------------------------------------------------------------------------
    % Have we reached the end of all data? Terminal condition
    global runRCBHT;                                % If this flag is false it says that the terminal condition is true    
%--------------------------------------------------------------------------

%% Initialization

    %global write2FileFlag; 
    write2FileFlag = false;                          % Used to set a date on files
    
    % Size
    [rows, c]            = size(forceData);          % size elements of force data
    
    %% Set the window length - ideal length is 5
    if(rows>5)
    	window_length	= 5;                        % Length of window used to analyze the data

    % If shorter set to 1
    elseif(rows>1 && rows<5)
        window_length 	= 1;
    else
        window_length   = 0;
    end
    
                                          
   %% Bools
    %iterFlag            = true;                        % Flag used to indicate when to exit while loop
    %locGreaterglob      = false;                       % This flag indicates whether the localRange is greater than the globalRange.    
    %cycleCompleted       = false;                       % This flag indicates whether or not we have completed                       
    %domain = abs(TL(index))+abs(BL(index));            % A measure of how wide the Force Value domain is (top limit - - low limit).
                                                        % Aug 2012 - not computd anymore. Use gradientCalibration with My value    
    % Handle
    rHandle = -1;
    
    %% Initialize Starting values for localRange. These are updated after correlation/no-correlation.
    if(regressionInitializeFlag)
        
        % Preallocate for current statistical data
        curStatData = zeros(10,7);
        curStatIndex = 1;
               
        % Set our starting and finishing range along with a moving index.
        %localRangeStart=1;                                 % DO NOT initialize localRangeStart. This has to be done in simulatedLoadData.m after it has read the latest value of localRangeStart to update the force buffer.
        localRangeEnd = localRangeStart+window_length;      % localRangeEnd tells where our analysis stops. Grows with each iteration where there is correlation. 
        movingIndex = 1;
        
        % Compute global range indeces
        %globalRangeStart = globalRange(1);
        globalRangeEnd   = length(globalRange);             % We are taking the length b/c we just want to compute how many indeces there are in the global range. This is so, because localRange is re-initialized to 1 everytime we cycle through this program.
        
    else
        globalRangeEnd  = length(globalRange);              % We are taking the length b/c we just want to compute how many indeces there are in the global range. This is so, because localRange is re-initialized to 1 everytime we cycle through this program.
        localRangeEnd   = localRangeStart+window_length;    % localRangeEnd tells where our analysis stops. Grows with each iteration where there is correlation. 
    end
    
%% Data Analysis
    %% A) Perform analysis when we have not reached the END of the true force data vector.
    while(runRCBHT)  
        
        %% A.1) Perform the analysis while the end of the local range is still smaller than the global range (ie.e force data buffer)  
        if(localRangeEnd<globalRangeEnd)                
            
            % Reset iterFlag to true - enable the while loop to run
            %iterFlag = true;
            %while(iterFlag)
                
            % Perform Correlation. If correlation grow window. If not save data, compute stats, write primites, and optionally plot data.
            [localRangeStart,localRangeEnd,movingIndex,...
             regressionInitializeFlag,rHandle,write2FileFlag,...
             curStatData]                                     = rsqCorrelation(fPath,StrategyType,StratTypeFolder,FolderName,...
                                                                               stateData,forceData,...
                                                                               pHandle,TL,BL,index,Type,window_length,rows,...
                                                                               localRangeStart,localRangeEnd,regressionInitializeFlag,write2FileFlag,movingIndex,...
                                                                               curStatData);
            regressionInitializeFlag = 0;
            % Set iterflag to false. Exit inner loop and restart
            % outside loop
            %break;
            %end         % End while(iterFlag)
            
        %% A.2) In this case, localRangeEnd>globalRangeEnd and requires that we exit so that globalRange can grow and give us a chance next time to analyze it.     
        else
            % The values for localRangeStart must be updated in the prior
            % iteration under the rsqCorrelation.m function. And in the
            % ensuing iteration it arrives at this point. localRangeStart
            % is a global and will be saved automatically. We need to clean
            % the statData vector to ensure there are no zero rows and then
            % exit to reach loadSimulatedData.m and increase globalRange 
            
            %% CleanUp the statistical data if it's our last cycle. 
            % For contiguous pairs of primitives, if one is 5 times longer
            % than the other, absorb it.  
            
            %TODO: ??May need to check to see if empty in case the if statement is skipped??
            curStatData = primitivesCleanUp(curStatData,gradLabels);

            break;
        end     % End  if(localRangeEnd<globalRangeEnd)                
    end         % End while(runRCBHT)               
    
    
    %% B) WRAP-UP: Last iteration runRCBHT is false and we have reached the end of our data.     
        % This is the very last iteration for our analysis, wrap up. 
    while (~runRCBHT) 
        
        %% B.1) Truncate and perform correlation
        if(localRangeEnd>globalRangeEnd)
           

            % Set the final variables
            localRangeEnd   = length(globalRange);              % Set to the last index of the buffered force data. Remember that simulatedLoadData is updating the buffered force data to match the latest force data.

            % Perform Correlation. If correlation grow window. If not save data, compute stats, write primites, and optionally plot data.
            [localRangeStart,localRangeEnd,movingIndex,...
             regressionInitializeFlag,rHandle,write2FileFlag,...
             curStatData]                                     = rsqCorrelation(fPath,StrategyType,StratTypeFolder,FolderName,...
                                                                               stateData,forceData,...
                                                                               pHandle,TL,BL,index,Type,window_length,rows,...
                                                                               localRangeStart,localRangeEnd,regressionInitializeFlag,write2FileFlag,movingIndex,...
                                                                               curStatData);
            % Reset variables
            regressionInitializeFlag = 0;
            localRangeStart     = 1;
           
        %% B.2) Last choice is just to terminate: filter, clean up, and exit.
        else
            
            %% CleanUp the statistical data if it's our last cycle. 
            % For contiguous pairs of primitives, if one is 5 times longer
            % than the other, absorb it.  
            
            %TODO: ??May need to check to see if empty in case the if statement is skipped??
            curStatData = primitivesCleanUp(curStatData,gradLabels);   
            
            %% Resize curStatData in case not all of its rows were occupied
            % Only do so if we truly finished. We can also be caught in the middle
            % of a linear fit, in that case skip. August 2012.
            if(regressionInitializeFlag)
                curStatData = resizeData(curStatData);  
            end
            
            %% Save curStatData.mat to the bin tmp folder
            % The .mat file is not necessary for execution. So we place it in
            % the same category as the plot. 
            % if(DB_PRINT)
            %   save('/home/vmrguser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin/tmp/curStatData.mat'),'curStatData','-mat')        
            % end            
            
            
        end         % End while(localRangeEnd>globalRangeEnd)               
    end             % End if(runRCHBT)       
end     % End function