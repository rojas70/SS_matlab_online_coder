% --------------------------- simulateLoadData ----------------------------
% Loads data upto the counter, which is updated by one at every step. It is
% built on the offline version of loadData.
%
% Includes new variables to reflect better relationship with regressionFit; 
% including globalRangeStart and globalRangeEnd. Also includes a flag to mark 
% the condition in which no more force data was throughput EndConditionFlag.
%
% Updated inputs and outputs. This version of the code distinguishes between 
% a permanent cumulative forceData structure and a small forceData buffer 
% used for analysis in fitRegressionCurves.
%
% Resets it's indeces every iteration whenever fitRegressionCurves finds a 
% correlation. We keep the localRangeStart value and expand the globalRangeEnd 
% value by the appropriate window. This allows us to not use previously
% analyzed data. This also means that regressionFit does not need to keep 
% up with index history, although there is some bookkeeping that needs to be 
% done on that side. 
%
%
% Inputs:
% forceData:        complete force data that is being accumulated over time in
% real-time.
%
% Outputs:
% forceDataBuffer   - nx7x1 data buffer that will be used to obtain
%                     correlation data in fitRegressionCurves.m
% globalRange       - this variable is a vector 1xn containing the first
%                     and last indeces that are currently holding the forceDataBuffer. They
%                     will also be used in fitRegressionCurves to indicate there what position
%                     in the force vector is being occupied.
%
% Globals:
% localRangeStart   - this variable is updated in fitRegressionCurves.m. It
%                     indicates the index at which the regression had initiated but could not 
%                     terminate because the analysis window surpassed the end of the force buffer.
%                     That index is used here to signal a starting point on the next iteration of the data.
%                     Furthermore, we extend the force buffer by: prev_globalRangeEnd + 
%                     local window_length parameter.
% Update:
% Because cannot use globals with online codegen, we are putting variables
% as input and output.
%--------------------------------------------------------------------------
%function [singleFD,dataLoadnextIndex]=simulatedLoadData(forceData,forceIndex)
function [forceDataBuffer,globalRange]=simulatedLoadData(forceData,forceIndex)
    
% Global variables
global runRCBHT;    % Determines whether we have reached the end of the real force data vector 
                    % and whether or not we should keep running the RCBHT

%% Time based variables. Not using this approach currently.
%global startTime;
%global simStep;
%global accumTime;

global curTime;
global prevTime;

%% Ranges
global localRangeStart;
global prev_globalRangeStart;
global prev_globalRangeEnd;
%global dataLoadnextIndex;

%% 1) Initialize Local Variables
    
    % Window Analysis
%     curTime     = 0.0;
%     prevTime    = 0.0;
    timeWindow  = 9;
        

%% 2) Based on clock difference compute the index to load for the force data

    % Initialization - First Iteration
    if(curTime-prevTime==0)
        
        % (1) Generate local and global ranges for data used here and
        % fitRegressionCurves.m
        % Local Range variables             % from regressionFitCurves.m
        localRangeStart     = 1;            % Set the index to the first element of the vector array of ForceData
        prev_localRangeStart= localRangeStart;
        % Global Range Variables
        globalRangeStart    = localRangeStart;
        globalRangeEnd      = globalRangeStart+timeWindow;
        globalRange         = globalRangeStart:globalRangeEnd;
                
        % Previous Local Range variables
        prev_globalRangeStart   = globalRangeStart;
        prev_globalRangeEnd     = prev_localRangeStart + timeWindow;      
        
        %dataLoadnextIndex=1;
        %endIndex=1;         
        
        % (2) Generate a force buffer that contains only the latest data
        % for the appropriate forceAxis in turn.
        forceDataBuffer = forceData(localRangeStart:globalRangeEnd,:,forceIndex); % Rows, Columns, ForceAxis           
        
    % Retrieve update force data buffer for analysis for fitRegressionCurves.m    
    else
        
        % (1) Check for termination conditions: if end of force data for 
        % relevant index has taken place
        if(localRangeStart~=1)
            globalRangeStart    = prev_globalRangeStart + localRangeStart-1;    % The new globalRangeStart is a function of its previous value + localRangeStart value, except when localRangeStarat did not change...
        else
            globalRangeStart    = prev_globalRangeStart;                        % localRangeStart did not move, so we use the same value as before for globalRangeStart
        end
        globalRangeEnd      = prev_globalRangeEnd   + timeWindow;
        globalRange         = globalRangeStart:globalRangeEnd;

        
        % Get the new number of rows in the force data structure
        currForceRows = size(forceData(:,:,forceIndex));                    % Checking the size of the relevant index
        if(globalRangeEnd > currForceRows(1));
            globalRangeEnd   = currForceRows(1);                            % Set the end of the globalrange to the number of rows.
            runRCBHT         = false;                                       % Set the termination condition on.                      
        end                    
        
        % (2) Generate a force buffer that contains only the latest data
        % for the appropriate forceAxis in turn.
        forceDataBuffer = forceData(globalRangeStart:globalRangeEnd,:,forceIndex); % Rows, Columns, ForceAxis   
        
        % (3) Set the value for previous terms and re-initialize localRangeStart
        prev_globalRangeStart   = globalRangeStart;
        prev_globalRangeEnd     = globalRangeEnd;
        localRangeStart         = 1;
        
        
        % Time Update
        % Update the previous time only if the diffindex is one or greater.
        % That is greater than a simulation time step 0.005 secs
        %if(diffIndex>=1)
        %    prevTime = curTime;
        %end
    end

    %accumTime = accumTime + curTime;
    %dataLoadnextIndex = endIndex+1;
end
