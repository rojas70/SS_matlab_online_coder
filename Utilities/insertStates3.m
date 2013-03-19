%%************************** Documentation ********************************
% All data used in this function was generated in snapData3. It plots 6 
% plots for HSA, and 8 subplots. On the left hand side column Fx, Fy, Fz, 
% and the right hand side column Mx, My, and Mz.
% 
% The function will call insertStates for each subplot. It will pass the
% stateData vector which has the times in which new states begin. It will
% use the handles for each subplot to select the appropriate axes when
% drawing the states, and similarly, it will use a top limit and bottom
% limit, to draw matlab "patch boxes" with transparently filled faces, to
% help differentiate each state.
%
% We chose to insertStates at the end of snapData3 instead with each
% subplot, because every time there is an adjustment to the axis limits,
% the patch face color disappears. 
%
% Inputs:
% StrategyType:     - If PA10 data, we have 8 plots, if HIRO 6 plots.
% stateData:        - column vector of state transition times
% EndTime:          - endtime of assembly
% handles:          - a single handle corresponding to one force axis that
%                     we wish to plot
% TOP_LIMIT         - is the adjusted top value of the plot for better viewing 
% BOTTOM_LIMIT      - is the adjusted bottom value of the plot for better viewing 
% Index             - what force axis are we working with
%**************************************************************************
function insertStates3(StrategyType,stateData,EndTime,handles,TOP_LIMIT,BOTTOM_LIMIT,Index)
   
%% Insert EndTime as the last row of the stateData
    r = size(stateData);
    
    % Hiro Side Approach: the stateData vector should consist of 5 elements for states: Approach, Rotation, Snap, and Mating. 
    % PA10 had an additional state: Adjustment after Rotation for a total of 6 states.
    if(strcmp(StrategyType,'HSA') || strcmp(StrategyType,'HIRO')) % Currently we are not using joint angle data and cartesian data. May use later. 
        if(r(1)<5)
            % If less than five add
            stateData(r(1)+1,1) = EndTime;  
        end
    else
        % There is one extra state when having used the PA10
        if(r(1)<6)
            stateData(r(1)+1,1) = EndTime;  
        end
    end
    
    % Determine how many limits do we have: 6 for force moment or 8
    % including snap joints.
    % PA10
    if(strcmp(StrategyType,'HSA') || strcmp(StrategyType,'HIRO')) % Currently we are not using joint angle data and cartesian data. May use later. 
        FX=3; %FY=4; FZ=5; MX=6; MY=7; MZ=8;
    
    % HIRO
    else
        FX=1; %FY=2; FZ=3;
        %MX=4; MY=5; MZ=6;
    end

    % Insert state lines for appropriate force axes as indicated by Index
    stateColorFillFlag = 1;                     % Fill states with color
    
    axes(handles);                             % Axes index
    insertStates(stateData,TOP_LIMIT(FX),BOTTOM_LIMIT(FX),stateColorFillFlag);            
end