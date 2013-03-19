%%************************* Documentation *********************************
% Adjusts axes to get a tight fit around data
%
% Input Parameters:
% Type:             - string determining type of data FxFyFzMxMyMz...
% Data:             - used to compute max and min vals
% TIME_LIMIT_PERC:  - scalar value used to set the length of data to the
%                     correct ending
% Signal Threshold: - a max value threshold used to determine where to set
%                     max and min values for the axis 
% WITHMARGIN:       - if true, places a small margin of white space to axis
%                     limits
% AVERAGE:          - uses the average value of data to compute the axis
%                     limits. useful for data with big impulses
%**************************************************************************
function [TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes(Type,Data,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,WITHMARGIN,AVERAGE)

%% Initialize local variable
    global DB_PRINT;
    
    fmFlag              = 0;
    COMPOUND_FORCE_DATA = 2;
%% Start adjusting the data range for any force and moment plots.

    [r, c] = size(Data);
    
    Range = Data(1:r*TIME_LIMIT_PERC,5:7);   
    fmFlag = COMPOUND_FORCE_DATA;

    % Position data will be arranged at the end. 
    if(strcmp(Type,'Force Plot'))
        Range = Data(1:r*TIME_LIMIT_PERC,2:4);    
        fmFlag = COMPOUND_FORCE_DATA;
        
    elseif(strcmp(Type,'Moment Plot'))
        Range = Data(1:r*TIME_LIMIT_PERC,5:7);   
        fmFlag = COMPOUND_FORCE_DATA;
   
    elseif(strcmp(Type,'Fx'))
        Range = Data(1:r*TIME_LIMIT_PERC,2);    
        fmFlag = true; 

    elseif(strcmp(Type,'Fy'))
        Range = Data(1:r*TIME_LIMIT_PERC,3);   
        fmFlag = true;  

    elseif(strcmp(Type,'Fz'))
        Range = Data(1:r*TIME_LIMIT_PERC,4); 
        fmFlag = true;
     
    elseif(strcmp(Type,'Mx'))
        Range = Data(1:r*TIME_LIMIT_PERC,5); 
        fmFlag = true;
   
    elseif(strcmp(Type,'My'))
        Range = Data(1:r*TIME_LIMIT_PERC,6); 
        fmFlag = true;

    elseif(strcmp(Type,'Mz'))
        Range = Data(1:r*TIME_LIMIT_PERC,7);   
        fmFlag = true;       
    end

%% Compute max and min axis parameters for force and moment plots    
    if(fmFlag==COMPOUND_FORCE_DATA)
        % Compute 1st-order max and min values for compound force data
        x = min(Range); 
        y = max(Range);

        % Max/min value adjustment
        x = sort(x);            % sort in ascending order for 1x3.
        y = sort(y);        

        if(x(1)<-1*SIGNAL_THRESHOLD) % Check the smallest value
                x=x(2);                 % We have a 1x3 array. If the min value of lhs x is less than 50, then choose the next largest value.
        else
            x=x(1);                 % The value is not less than 50, so it's okay to choose the smaller value.
        end

        if(max(y)>SIGNAL_THRESHOLD) % Check the max value
            y=y(2);                 % We have a 1x3 array. If the max value of lhs y is greater than 100, then choose the next smallest value.
        else
            y=y(3);                 % The value is not greater than 50, so it's okay to choose the larger value.
        end

        % Print max/min values
        if(DB_PRINT)
            if(ispc)
                fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
            else
                printf('The max and min values for the Force plot is: %f, %f\n',x,y);
            end 
        end
        
%% For individual Fx, Fy, Fz, Mx, My, Mz quantities.
    elseif(fmFlag==true)        
        x=sort(Range);             % Sort in ascending order
        y=sort(Range,1,'descend'); % Sort in descending order        
        
        % Choose max and min values
        if(AVERAGE==1)
            
            % Create a new index without zeros
            %index=1;
            
            % Ignore for RT Online Gen
            % For PA10 Simulation Results
%            if(strcmp(StrategyType,'HSA') || strcmp(StrategyType,'HIRO')) % Currently we are not using joint angle data and cartesian data. May use later. 
%                 if(length(x)<1000000)
%                     for i=2000:length(x); % no meaningful forces till this point
%                         if(x(i)>abs(0.001))
%                             avg(index) = x(i);
%                             index = index+1;
%                         end
%                     end
%                 end
%             else
%                 % For HIRO Simulation results
%                 avg = x;
%             end
            
            % Compute the average value of the 
%             avg_val = mean(avg);
%             x = -1*avg_val;
%             y =  1*avg_val;
            %WITHMARGIN = 1;        
        
        else
            % the 2nd/3rd/or 4th smallest and largest numbers given that often
            % there is an impulse
            x = x(4); %min(Range);
            y = y(4); %max(Range);    
        end
        
        % Ignored for RT Online Gen
        % Print max/min values
%         if(DB_PRINT)
%             if(ispc)
%                 fprintf('The max and min values for the Force plot is: %f, %f\n',x,y);
%             else
%                 printf('The max and min values for the Force plot is: %f, %f\n',x,y);
%             end 
%         end
    end       
    
%% Adjust range for Position
% Ignored for RT Online Gen
%     if(strcmp(Type,'Rotation Spring'))
%         Range = Data(1:r*TIME_LIMIT_PERC,2:3);
%         
%         % Compute 2nd-order max and min values
%         x = min(min(Range)); %we want to find the max and min value in the area of contact not before that.
%         y = max(max(Range));
% 
%         % Axis adjustment    
%         TOP_LIMIT    = max(y);
%         BOTTOM_LIMIT = min(x);
%     end

%% Adjust the axes for either force or position plots with computed parameters
    % Add a margin of space around the max and min values if true
    if(WITHMARGIN==1)
        TOP_LIMIT       = y+(0.02*y);
        BOTTOM_LIMIT    = x-(0.02*x);
    else
        TOP_LIMIT       = y; 
        BOTTOM_LIMIT    = x;
    end
    
    % Adjust the axes
    axis([Data(1,1) (Data(r,1)*TIME_LIMIT_PERC) BOTTOM_LIMIT TOP_LIMIT]);

%% Write the legend
    if(strcmp(Type,'Rotation Spring'))
        legend('Snap1','Snap2','location','NorthWest');
    elseif(strcmp(Type,'Force Plot'))
        legend('dFx','dFy','dFz','location','NorthWest');
    elseif(strcmp(Type,'Moment Plot'))
        legend('dMx','dMy','dMz','location','NorthWest');
    elseif(strcmp(Type,'Fx'))
        %legend('dFx','location','NorthWest');
    elseif(strcmp(Type,'Fy'))
        %legend('dFy','location','NorthWest');
    elseif(strcmp(Type,'Fz'))
        %legend('dFz','location','NorthWest');
    elseif(strcmp(Type,'Mx'))
        %legend('dMx','location','NorthWest');
    elseif(strcmp(Type,'My'))
        %legend('dMy','location','NorthWest');
    elseif(strcmp(Type,'Mz'))
        %legend('dMz','location','NorthWest');        
    end
end
    