%%************************** Documentation ********************************
% Different plots have different endings and hence different lengths. In
% order to know which index is the last one, a constant 'Time_Limit_Perc'
% is computed, so that when multiplied by the length, data length agrees
% with true ending time.
% 
% Output Parameters:
% TIME_LIMIT_PERC:      - constant used to multiply against the time series
%                         to get the right ending.
% AMPLITUDE_THRESHOLD   - threshold used to determine how to set the axis
%                         of a plot
% Input Parameters:
% FolderName:           - used to identify data
% Data:                 - used to extract it's length
%**************************************************************************
function [TIME_LIMIT_PERC, AMPLITUDE_THRESHOLD] = CustomizePlotLength(FolderName,Data)

%% Initialize Data    
   % Customize the length of axis per result  
   len = length(Data);
   
    if(nargin==0)
        secs                = 10.0;       % Standard length for simulation 
        AMPLITUDE_THRESHOLD = 50;         % Threshold used to select max and min values
        FolderName          = '';
        Data                = 0;
    end
%%  Write Ending Time    
    % Assign ending time based on visual insepction of simulation/experiment
    if(strcmp(FolderName,'20120201-1752-StraightLineApproach-S')) 
        secs=6.3;                   % Hand coded end
        AMPLITUDE_THRESHOLD = 50;
    elseif(strcmp(FolderName,'20120126-1710-PivotApproach-FullSnap-S')) 
        secs=8.3;                   % Hand coded end
        AMPLITUDE_THRESHOLD = 50;
    elseif(strcmp(FolderName,'20120126-1636-PivotApproach-FullSnap-S'))
        secs=8.3;
        AMPLITUDE_THRESHOLD = 50;
    else
        secs = 10.0;
        AMPLITUDE_THRESHOLD = 50;
        len = 10000;                % Equal to 10 secs measured in millisecs
    end

%%  Calculate the appropriate time percentage equivalent to duration based on signals length. 
    TIME_LIMIT_PERC=(secs * 1000)/len;       
end