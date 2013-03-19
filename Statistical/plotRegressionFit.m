%**************************** Documentation *******************************
% Plots the linear regression fit line. 
% Superimposes the plot on an already created plot for either Fx,Fy,Fz,Mx,My,Mz. 
%
% If a handle is given, it plots only data for that handle. The function
% that calls plotRegressionFit is running a for loop for each of the force
% types. 
% 
% If no handle is given, a new figure is opened, and the plot takes place
% there.
%
% Input parameters:
% x:                - the independent variable (i.e. time)
% yfit:             - fitted data (dependent variable)
% Type:             - string defining type of curve (FxFyFzMxMyMz)
% pHandle:          - handles used to plot the original plots for FxyzMxyz
% TL:               - the top axes limits of each of the eight subplots
%                     Fx,Fy,Fz,Mx,My,Mz,SJ1,SJ2
% BL:               - Same as TL but bottom limits. 
% FolderName:       - Used to set the ending parameter for the result
% Data:             - plot data used to determine y_max and y_min limits
% stateData:        - column vector containing when a new state starts
%
% Output Parameters:
% rHandle:          - handle to new graph
%**************************************************************************
function [rHandle,TOP_LIMIT,BOTTOM_LIMIT]=plotRegressionFit(x,yfit,Type,pHandle,TL,BL,FolderName,Data,stateData,regressionInitializeFlag)

%% Preprocessing and Plotting
    
    % Choose line color
    lineColor = 'r';
    
    % If no handle is given, open a new figure
    if(pHandle==0 || pHandle==-1)
        %figure(2); grid on;
        TIME_LIMIT_PERC = 1;
        SIGNAL_THRESHOLD = 0;
        StrategyType = 'HIRO';
    
        % Plot Data.
        hold on;
        rHandle=plot(x,yfit,lineColor,'linewidth',2.5); 
                   
%%                
    else
        % Set the handle of the corresponding already plotted force data.
        axes(pHandle); hold on;
        rHandle=plot(x,yfit,lineColor,'linewidth',2.5);        
    end                
        
%% Insert State Lines into Diagram
    % Only do this for the first iteration
    if(regressionInitializeFlag)
        % Compute the real end of the signal
        %[TIME_LIMIT_PERC, SIGNAL_THRESHOLD] = CustomizePlotLength(FolderName,Data);                  
        if(x(1)<0.01)

            % Adjust Axes
            %MARGIN = 0;         % Do you want a margin of white space surrounding the max,min values of the curve
            %AVERAGE = 0;        % Do you want to set axis data around average value of curve
            %[TOP_LIMIT, BOTTOM_LIMIT] = adjustAxes(Type,Data,StrategyType,TIME_LIMIT_PERC,SIGNAL_THRESHOLD,MARGIN,AVERAGE);
            TOP_LIMIT=10;
            BOTTOM_LIMIT = -TOP_LIMIT;

            % Insert the states
            FillFlag = 1; % Fill with color
            axes(gca);      % Activate the appropriate subplot/axis handle
            insertStates(stateData,TOP_LIMIT,BOTTOM_LIMIT,FillFlag);       

        
            %% Labels
            % Modified for Online RT Implementation (if we choose to plot)

            % x-axise
            xlabel('Time (secs)','fontsize',12); 

            % y-axis
            if(strcmp(Type,'Fx') || strcmp(Type,'Fy') || strcmp(Type,'Fz'))
                ylabel('Force (N)','fontsize',12); 
            elseif(strcmp(Type,'Mx') || strcmp(Type,'My') || strcmp(Type,'Mz'))
                ylabel('Moment (N-m)','fontsize',12);        
            end

            % Title
            if(strcmp(Type,'Fx'))
                title('Fx Regression Fit','fontsize',12);
            elseif(strcmp(Type,'Fy'))
                title('Fy Regression Fit','fontsize',12);
            elseif(strcmp(Type,'Fz'))
                title('Fz Regression Fit','fontsize',12);        
            elseif(strcmp(Type,'Mx'))
                title('Mx Regression Fit','fontsize',12);
            elseif(strcmp(Type,'My'))
                title('MyRegression Fit','fontsize',12);    
            else
                title('Mz Regression Fit','fontsize',12); 
            end
        end % End if(x(1)<0.01) 
    end     % End if(regressionInitializeFlag)
end % End function