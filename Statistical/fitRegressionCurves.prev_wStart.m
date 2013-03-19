%%************************** Documentation *********************************
% Analyze a single force or moment element curve for snap assembly, and,
% using a linear regression with corrleation thresholds, segement the data,
% into segmentes of linear plots. 
%
% Online analysis: 
% This algorithm runs in parallel and incrementally as the force
% data size grows over time. See workings of standar algorithm below. If, a
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
% Input Parameters:
% fPath             : path string to the "Results" directory
% StrategyType      : refers to PA10-PivotApproach, or HIRO SideApproach "HSA"
% StratTypeFolder   : path string to Position/ForceControl: //StraightLineApproach or Pivot Approach or Side Approach
% Type              : type of data to analyze: Fx,Fy,Fz,Mx,My,Mz
% forceData         : Contains an nx1 vector of the type of force data
%                     indicated
% stateData         : column vector of state transition times
% wStart            : the time, in milliseconds, at which this segment
%                     clock starts
% pHandle           : handle to the corresponding FxyzMxyz plot, to
%                     superimpose lines. 
% TL                : the top axes limits of each of the eight subplots SJ1,SJ2,
%                     Fx,Fy,Fz,Mx,My,Mz
% BL                : Same as TL but bottom limits. 
% Output Parameters:
% curStatData          : contains 1 index, and 7 statistics of each segmented line fit:
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
%**************************************************************************
function [curStatData,rHandle] = fitRegressionCurves(fPath,StrategyType,StratTypeFolder,FolderName,forceData,stateData,pHandle,TL,BL,index,gradLabels,Type)
    
%% Global variables

    % Read/Write Variables
    global DB_PRINT;                                % Declared in snapVerification. These take those values.
    global DB_WRITE;
%--------------------------------------------------------------------------
    % Resuming regression when an end was not found
    global regressionInitializeFlag;                % Set in pRCBHT to true; Set to false when end of window reached but with no correlation break. Helps us resume
    
    global indexStart;
    global wStart;
    global windowStart;
%--------------------------------------------------------------------------

%% Initialization
    CORREL = 0; RSQ = 1;                            % 0 used for correlation coefficient, 1 used for R^2 
    WHATCOEFF = RSQ;                                % Select which coefficient you want to use for thresholding. Adjust threshold value accordingly
    
    %global write2FileFlag; 
    write2FileFlag = false;                          % Used to set a date on files
    
    % Size
    [rows c]            = size(forceData);          % size elements of force data
    
    % Set the window length - ideal length is 5
    if(rows>5)
    	window_length	= 5;                        % Length of window used to analyze the data

    % If shorter set to 1
    elseif(rows>1 && rows<5)
        window_length 	= 1;
    else
        window_length   = 0;
    end
    
    % Thresholds
    % PA10
%    if(~strcmp(StrategyType,'HSA'))                 % For PA10, 60% seemed to give better results than 70-90%
%        GoodFitThreshold    = 0.70;                 % Lower correlation is good for PA10 b/c simulation results yielded very high values
    %HIRO
%    else
        GoodFitThreshold    = 0.90;                 % Higher correlation coefficients will detect contacts better       
%    end
                                                
    % Bools
   iterFlag            = true;                     % Flag used to indicate when to exit while loop    
                          
    %domain = abs(TL(index))+abs(BL(index));        % A measure of how wide the Force Value domain is (top limit - - low limit).
                                                    % Aug 2012 - not computd anymore. Use gradientCalibration with My value
    % Indeces
    forceIndex = 2; % The first index of the force data structure is for time 
    
    % Handle
    rHandle = -1;
    
    % Initialize start and finish
    if(regressionInitializeFlag)
        
        % Preallocate for current statistical data
        curStatData = zeros(10,7);
        curStatIndex = 1;
        
        % Local Indeces
        if(wStart==0)               % Initialize local index
            wStart = 1;
        end
        i=wStart;                   % indexStart to 1
        wFinish = rows;                 % wFinish is equal to the number of rows


    else
        %wStart  = windowStart;
        i       = wStart;           % Set indexStart to the index equal to the last sz of the structure + 1
    end
    
%% Data Analysis
    % Two while loops: (a) run until all data has been analyzed; (b) run until
    % a segment has been finished
    while(i<rows+window_length) % For all force data points including a window (allow the last iteration to pass), appropriate limit checks come later        
        if(i<rows) % All iterations except the last one
            
            % Reset iterFlag to true - enable the while loop to run
            iterFlag = true;
            while(iterFlag)

                % a) Perform a polyfit for our growing window of data
                %    Establish length of time window and data range
                windowIndex = i + window_length;           % Index value when added by window_length
                Range       = indexStart:windowIndex;      % Use indexStart from loadData to maintain history of data
                    
                % Check limits at the end
                if(windowIndex > rows) 
                    Range    = indexStart:rows;             % Use indexStart from loadData to maintain history of data
                    iterFlag = false;
                end
                
                Time        = forceData(Range,1);          % Time indeces that we are working with
                Data        = forceData(Range,forceIndex); % Corresponding force data for a given force element in a given window

%%              % b) Fit data with a linear polynomial. Retrieve coefficients. 
                polyCoeffs  = polyfit(Time,Data,1);            % First-order fit

                % c) Compute the values of 'y' (dataFit) for a fitted line.
                dataFit = polyval(polyCoeffs, Time);

%%              % d) Perform a correlation test
                    if(WHATCOEFF==CORREL)
                        
                        % i) Correlation Coefficient
                        correlCoeff=corrcoef(Data,dataFit);

                        % If perfrect correlation, size is 1x1
                        if(size(correlCoeff)~=[1 1])
                           correlCoeff = correlCoeff(1,2);
                        end

                        % Check for NaN condition
                        if(isnan(correlCoeff)) 
                            correlCoeff = 1;    % Set to 1, to continue to analyze data
                        end

                        % Copy for test
                        coeffThshld = correlCoeff;

                    else
                        % ii) Determination Coefficient, R^2
                        yresid = Data - dataFit;                % Compute residuals
                        SSresid = sum(yresid.^2);               % Sum of squares of residuals
                        SStotal = (length(Data)-1) * var(Data); % Sum of squares of "y". Implmented by multiplying the variance of y by the number of observations minus 1:

                        %% Floating Point Checks
                            % Check if SSresid or SStotal are almost zero
                            if(SSresid<0.0001); SSresid = 0; end
                            if(SStotal<0.0001); SStotal = 0; end

                        % Compute rsq
                        rsq = 1 - SSresid/SStotal;              % Variance in yfit over variance in y. 

                            % Check for NaN condition
                            if(isnan(rsq));      rsq = 1;    % Set to 1, to continue to analyze data
                            elseif(isinf(rsq));  rsq = 1;       
                            end 

                        % Copy for test
                        coeffThshld = rsq;
                    end
%%              % e) Thresholding for correlation data

                % ei) If good correlation, grow index by a windows size jump
                if(coeffThshld > GoodFitThreshold)
                    i= i+window_length;

                elseif(coeffThshld > GoodFitThreshold && i==rows-1) % Temporary iteration without having had a break in correlation
                    % I.e. make a copy of indeces: where we started and where we stopped
                    indexStart      = i+1;          % Next time, start at the next index.
                    %does not change
                    %windowStart     = wStart;       % wStart stays the same. It's the variable that indicates the beginning of the window we are studying to fit.
                    
                    regressionInitializeFlag = 0;   % Change the flag

%%              % e2) If false, save data window, plot, & perform statistics for newly formed segment 
                else
                   
                    % i) Adjust window parameters except for first iteration
                    if(~(windowIndex-window_length==1))             % If not the beginning
                        wFinish     = windowIndex-window_length;
                        Range       = indexStart:wFinish;           % Save from wStart to the immediately preceeding index that passed the threshold
                        Time        = forceData(Range,1);           % Time indeces that we are working with
                        %Data        = forceData(Range,forceIndex); % Corresponding force data for a given force element in a given window
                        currDataFit     = dataFit(1:length(Range),1);   % Data fit - window components

                    % First iteration. Keep index the same. 
                    else
                        wFinish     = windowIndex;
                        Range       = indexStart:wFinish;           % Save from wStart to the immediately preceeding index that passed the threshold
                        Time        = forceData(Range,1);           % Time indeces that we are working with
                        %Data        = forceData(Range,forceIndex); % Corresponding force data for a given force element in a given windowdataFit     = dataFit(Range);               % Corresponding force data for a given force element in a given window                    
                        currDataFit = dataFit(Range);               % Corresponding force data for a given force element in a given window      
                    end
%%                  ii) Retrieve the segment's statistical Data and write to file
                    [dAvg, dMax, dMin, dStart, dFinish, dGradient, dLabel]=statisticalData(Time(1),       Time(length(Range)),...
                                                                                     currDataFit,   polyCoeffs,... % Aug 2012 - domain removed
                                                                                     FolderName,    StrategyType,index); % 1+windowlength

                    % iii) Keep history of statistical data 
                    % All data types are numerical in this version. // Prior versions: Given that the datatypes are mixed, we must use cells. See {http://www.mathworks.com/help/techdoc/matlab_prog/br04bw6-98.html}       
                    curStatData(curStatIndex,:) = [dAvg dMax dMin dStart dFinish dGradient dLabel];

                    % iv) Write to file
                    if(DB_WRITE)
                        [write2FileFlag]=WritePrimitivesToFile(fPath,StratTypeFolder,FolderName,...
                                                          Type(index,:),write2FileFlag, ...
                                                          curStatIndex,dAvg,dMax,dMin,dStart,dFinish,dGradient,dLabel);
                    end
%%                  % v) Plot data
                    if(DB_PRINT)
                        rHandle=plotRegressionFit(Time,currDataFit,Type(index,:),pHandle,TL,BL,FolderName,forceData,stateData);                                
                    else
                        rHandle=-1;
                    end

%%                  % Wrap Up 
                    % vi) Increase counter
                    curStatIndex = curStatIndex + 1; 
                    i = i+window_length;

                    % vii) Reset the window start and the window finish markers
                    indexStart  = wFinish;         % Start with the last "out-of-threshold" window
                    windowStart = wFinish;   % Also update where the new window will start

                    % viii) Set iterflag to false. Exit inner loop and restart
                    % outside loop
                    iterFlag = false;
                    wFinish  = rows;
                    break;
                end % End coefficient threshold
            end     % End while(iterFlag)
        
%%      WRAP-UP: Last iteration        
        % This is the very last iteration for our analysis, wrap up. 
        else
            % If regressionInitializeFlag is true this must be the very
            % last iteration, otherwise we are not and we should not write
            % segmentation data
            if(regressionInitializeFlag)
                % Set the final variables
                wFinish     = rows;                        % Set to the last index of curStatData (the primitives space)
                Range       = indexStart:wFinish;          % Save from wStart to the immediately preceeding index that passed the threshold// Changed wStart to indexStart.
                Time        = forceData(Range,1);          % Time indeces that we are working with
                Data        = forceData(Range,forceIndex);% Corresponding force data for a given force element in a given window
                currDataFit = dataFit(1:length(Range),1);  % Data fit - window components
                
                indexStart  = 1;                           % Reset
                windowStart = rows+1;

    %%          ii) Retrieve the segment's statistical Data and write to file
                [dAvg, dMax, dMin, dStart, dFinish, dGradient, dLabel]=statisticalData(Time(1),    Time(length(Time)),...
                                                                                 currDataFit,polyCoeffs,FolderName,StrategyType,index); % 1+windowlength

                % iii) Keep history of statistical data 
                % All data types are numerical in this version. // Prior
                % versions: Given that the datatypes are mixed, we must use cells. See {http://www.mathworks.com/help/techdoc/matlab_prog/br04bw6-98.html}       
                curStatData(curStatIndex,:) = [dAvg dMax dMin dStart dFinish dGradient dLabel];

%%          CleanUp the statistical data
                % For contiguous pairs of primitives, if one is 5 times longer
                % than the other, absorb it.
                curStatData = primitivesCleanUp(curStatData,gradLabels);

                % iv) Write to file
                if(DB_WRITE)
                    [write2FileFlag]=WritePrimitivesToFile(fPath,StratTypeFolder,FolderName,...
                                                                    Type(index,:),write2FileFlag, ...
                                                                    curStatIndex,dAvg,dMax,dMin,dStart,dFinish,dGradient,dLabel);
                end

%%          % v) Plot data
                if(DB_PRINT)
                    rHandle=plotRegressionFit(Time,currDataFit,Type(index,:),pHandle,TL,BL,FolderName,forceData,stateData);     % Index added to type to do one at a time                           
                else 
                    rHandle=-1;
                end

                % Get out of the while loop
                break;
            end     % End last iteration
        end         % End i<rows
    end             % End while(i<rows+window_length)
    
    
%% Resize curStatData in case not all of its rows were occupied
    % Only do so if we truly finished. We can also be caught in the middle
    % of a linear fit, in that case skip. August 2012.
    if(regressionInitializeFlag)
        curStatData = resizeData(curStatData);  

%% Save curStatData.mat to the bin tmp folder
        % The .mat file is not necessary for execution. So we place it in
        % the same category as the plot. 
%         if(DB_PRINT)
%             save('/home/vmrguser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin/tmp/curStatData.mat'),'curStatData','-mat')        
%         end
    end
    
end     % End function