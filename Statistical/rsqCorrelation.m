


function [localRangeStart,          localRangeEnd,  movingIndex,...
          regressionInitializeFlag, rHandle,        write2FileFlag,...
          curStatData]                                    = rsqCorrelation( fPath,StrategyType,StratTypeFolder,FolderName,stateData,forceData,...
                                                                            pHandle,TL,BL,index,Type,window_length,rows,...
                                                                            localRangeStart,localRangeEnd,regressionInitializeFlag,write2FileFlag,movingIndex,...
                                                                            curStatData)
%% Globals
    global DB_WRITE;
    %global DB_PRINT;
        
    % Current statistic data variables
    %global curStatData; % Cannot make the global variable work. Need to include it as input/output.
    global curStatIndex;
    global curStatDataFlag;
%% Initialization

    if(regressionInitializeFlag)
        % curStatDataFlag
        curStatDataFlag = false;                    % Used to indicate whenever there are updates to the curStatData vector.
    end     

    % Correlation Parameters
    CORREL = 0; RSQ = 1;                            % 0 used for correlation coefficient, 1 used for R^2 
    WHATCOEFF = RSQ;                                % Select which coefficient you want to use for thresholding. Adjust threshold value accordingly
    
    % Thresholds
    % PA10
    %if(~strcmp(StrategyType,'HSA'))                % For PA10, 60% seemed to give better results than 70-90%
    %   GoodFitThreshold    = 0.70;                 % Lower correlation is good for PA10 b/c simulation results yielded very high values
    %HIRO
    %else
    GoodFitThreshold    = 0.90;                     % Higher correlation coefficients will detect contacts better       
    %end
   
    % Indeces
    forceIndex = 2; % The first index of the force data structure is for time     
    
    % Plot
    rHandle=-1;

    %% A) Perform a polyfit for our growing window of data
    %   Establish length of time window and data range
    %   windowIndex = localRangeStart + window_length;        % Index value when added by window_length

    % Compute the local range                
    localRange  = localRangeStart:localRangeEnd;

    Time        = forceData(localRange,1);                      % Keep the time buffer that correspons to the data that is still correlated. This should be the same size as dataFit.
    Data        = forceData(localRange,forceIndex);             % Corresponding force data for a given force element in a given window. Can be bigger than time. 
    
    %% B) Fit data with a linear polynomial. Retrieve coefficients. 
    polyCoeffs  = polyfit(Time,Data,1);            % First-order fit

    %% C) Compute the values of 'y' (dataFit) for a fitted line.
    dataFit = polyval(polyCoeffs, Time);

    %% D) Perform a correlation test
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
                if(SSresid<0.0001)
                    SSresid = 0; 
                end
                if(SStotal<0.0001)
                    SStotal = 0;
                end

            % Compute rsq
            rsq = 1 - SSresid/SStotal;              % Variance in yfit over variance in y. 

                % Check for NaN condition
                if(isnan(rsq));      rsq = 1;    % Set to 1, to continue to analyze data
                elseif(isinf(rsq));  rsq = 1;       
                end 

            % Copy for test
            coeffThshld = rsq;
        end
    %% e) Thresholding for correlation data

    %% ei) If good correlation, increase the localRangeEnd vector by a windows size jump
    % localRangeStart does not move, so that we know where we started. 
    % Our moving index, movingIndex, is also increased by size window_length
    if(coeffThshld > GoodFitThreshold)
        movingIndex = movingIndex + window_length;                  % The moving index grows whenever there is correlation.
        localRangeEnd   = localRangeEnd + window_length;     

    %% Temporary iteration without having had a break in correlation
    elseif(coeffThshld > GoodFitThreshold && movingIndex==rows-1) 
        % I.e. make a copy of indeces: where we started and where we stopped
        localRangeStart  = localRangeStart + 1;         % Next time, start at the next index.
        localRangeEnd    = localRangeEnd   + 1; 
        %does not change
        %windowStart     = localRangeStart;             % localRangeStart stays the same. It's the variable that indicates the beginning of the window we are studying to fit.

        regressionInitializeFlag = 0;   % Change the flag

    %% e2) If NO CORRELATION, Segment and save data window, plot, & perform statistics for newly formed segment 
    else

        % i) Adjust window parameters except for first iteration
        if(~(localRangeEnd-window_length==1))                       % If not the beginning
            localRangeEnd   = localRangeEnd-window_length;          % Readjust the localRangeEnd parameter since there is no correlation, we should not 
            localRange      = localRangeStart:localRangeEnd;
            Time            = forceData(localRange,1);              % Time indeces that we are working with
            currDataFit     = dataFit(localRange,1);                % Data fit - window components

        % First iteration. Keep index the same. 
        else
            %localRangeEnd   = windowIndex;
            localRange      = localRangeStart:localRangeEnd;
            Time            = forceData(localRange,1);              % Time indeces that we are working with
            currDataFit     = dataFit(localRange);                  % Corresponding force data for a given force element in a given window      
        end
        %% ii) Retrieve the segment's statistical Data and write to file
        [dAvg, dMax, dMin, dStart, dFinish, dGradient, dLabel]=statisticalData(Time(1), Time(length(localRange)),...
                                                                         currDataFit,   polyCoeffs,...              % Aug 2012 - variable "domain" removed
                                                                         FolderName,    StrategyType,index);        % 1+windowlength

        % iii) Keep history of statistical data 
        % All data types are numerical in this version. // Prior versions: Given that the datatypes are mixed, we must use cells. See {http://www.mathworks.com/help/techdoc/matlab_prog/br04bw6-98.html}       
        curStatData(curStatIndex,:) = [dAvg dMax dMin dStart dFinish dGradient dLabel];
        
        % Change curStatDataFlag to true
        curStatDataFlag = true;
        
        % iv) Write to file
        if(DB_WRITE)
            [write2FileFlag]=WritePrimitivesToFile(fPath,StratTypeFolder,FolderName,...
                                              Type(index,:),write2FileFlag, ...
                                              curStatIndex,dAvg,dMax,dMin,dStart,dFinish,dGradient,dLabel);
        end
%         %% v) Plot data
%         if(DB_PRINT)
%             rHandle=plotRegressionFit(Time,currDataFit,Type(index,:),pHandle,TL,BL,FolderName,forceData,stateData,regressionInitializeFlag);                                
%         else
%             rHandle=-1;
%         end

        %% Wrap Up 
        % vi) Increase counter
        curStatIndex = curStatIndex + 1;                            % Increase the current statistic index.
        movingIndex = 1;                                            % Reset the moving index to 1. 

        % Increase both the starting and ending ranges when there was no correlation. I.e. moving the whole window forward
        localRangeStart     = localRangeEnd+1;                      % Start with the last "out-of-threshold" window                        
        localRangeEnd       = localRangeEnd + window_length;
        %windowStart        = localRangeEnd;                        % Also update where the new window will start


    end % End coefficient threshold
end