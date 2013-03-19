%% ********************************* Documentation ************************
% Function that computes the difference of the "average value" of a
% motion composition structure between index i and i+1, and compares it to
% see if it is less than a trehshold defined by AmplitudeRatio.
%
% The threshold defined up in the stack, is defined to be typically 10% of the
% value.
%
% The greatest average value is used to compute the percentage between
% contiguous elements. 
%
% Returns boolean result. 
% data:         - data to be analyzed
% dataIndex:    - selects what row in the data will be studies
% strucIndex:       - selects what element of the data to compare
% AmplitudeRation:  - sets the threshold
%**************************************************************************
function boolPerc = computePercentageThresh(data,dataIndex,strucIndex,AmplitudeRatio)

%% Initialization    
    
    % match is next contiguous element
    match = dataIndex + 1;
    
    % llbehStruc Indeces
%     behLbl          = 1;   % action class
%     averageVal1     = 2;   % averageVal1
%     averageVal2     = 3;
      AVG_MAG_VAL     = 4;
%     rmsVal1         = 5;
%     rmsVal2         = 6;
%     AVG_RMS_VAL     = 7;
%     ampVal1         = 8;
%     ampVal2         = 9;
      AVG_AMP_VAL     = 10;
%     mc1             = 11;
%     mc2             = 12;    
%     T1S             = 13; 
%     T1E             = 14;
%     T2S             = 15; 
%     T2E             = 16;    
%     TAVG_INDEX      = 17;   
    
%%  Compute the percentage value that we will compare against
    percThresh = AmplitudeRatio*abs(max([data(dataIndex,strucIndex),data(match,strucIndex)]));
%%  If difference is smaller, return a true value, else false.
    if(AVG_AMP_VAL) % Take the absolute value of each number
        a = abs(data(dataIndex,strucIndex));
        b = abs(data(match,    strucIndex));
        c = abs(a-b);
        if(c <= percThresh)
            boolPerc = true;
        else
            boolPerc = false;
        end

    % Take the absolute value of the difference
    elseif(AVG_MAG_VAL) 
        if(abs(data(dataIndex,strucIndex) - data(match,strucIndex)) <= percThresh)
            boolPerc = true;
        else
            boolPerc = false;
        end        
    end
end