%% **************************** Documentation *****************************
% Merges data between two continguous elements in a data composition data
% structure. 
% 
% The data structure is a cell array composed of 11 elements: 
% data:(nameLabel,avgVal,rmsVal,amplitudeVal,p1lbl,p2lbl,t1Start,t1End,t2Start,t2End,tAvgIndex)
% 
% Input Parameters:
% index:            - first element of contiguous pair.
% data:             - an mx11 cell array data structure containing action compositions
% actionLbl         - cell array structure that holds strings for action compositions
% actionLblIndex    - index to select what label to use, i.e.: adjust, clean, etc.
% LABEL_FLAG        - if true, sets the value of the label
% AMPLITUDE_FLAG    - if true, computes the average amplitude. 
% whatComposition   - if value = 1, indicates we should merge the 2nd
%                     composition unto the first. if 2, the other way around.
%**************************************************************************
function data = MergeCompositions(index,data,actionLbl,actionLblIndex,LABEL_FLAG,AMPLITUDE_FLAG,whatComposition)

%%  Initialization

    % Define next contiguous element
    if(whatComposition==1)
        match = index+1;
    else
        match = index-1;
    end

    % mot Comps Structure Indeces
    ACTN_LBL         = 1;   % action class
    AVG_MAG_VAL      = 2;   % average value
    RMS_VAL          = 3;   % rms value
    AMPLITUDE_VAL    = 4;   % amplitude value 
    
    % Labels indeces for both primitives
    P1LBL = 5; 
    P2LBL = 6;    
    
    % Time Indeces
    T1S = 7; T1E = 8;
    T2S = 9; T2E = 10;    
    TAVG_INDEX   = 11;
    
%%  Name Label 
    if(LABEL_FLAG)
        data(index,ACTN_LBL) = actionLbl(actionLblIndex); % Set the name of the ACTN_LBL to the one passed by in actionLblIndex. Could be 'a' or 'c', etc.
    end
    
%%  Values                                                        
    % Average magnitude value: (index+match)/2
    data(index,AVG_MAG_VAL)   = ( data(index,AVG_MAG_VAL)   + data(match,AVG_MAG_VAL) )/2; 
    
    % RMS value: (index+match)/2
    data(index,RMS_VAL)       = ( data(index,RMS_VAL)       + data(match,RMS_VAL) )/2; 
    
    if(AMPLITUDE_FLAG)
        % Amplitude value: (index+match)/2
        data(index,AMPLITUDE_VAL) = ( data(index,AMPLITUDE_VAL) + data(match,AMPLITUDE_VAL) )/2; 
    end

%%  LABELS
    % Arrange lables appropriately
    % If whatComposition==1,
    % Let the second label of the first composition to be the
    % second label of the second composition. Ignore the inbetween values. 
    if(whatComposition==1)
        data(index,P2LBL) = data(match,P2LBL);
    % Else set the first label of the second composition to be the label of
    % the first composition
    else
        data(index,P1LBL) = data(match,P1LBL);        
    end
%%  Time
    if(whatComposition==1)
        % T2_END,index = T2_END,match
        data(index,T2E) = data(match,T2E);       

        % T2_START,index = T1_START,match
        data(index,T2S) = data(match,T1S);   
        
        % T1_END,index = T2_END,index
        data(index,T1E) = data(index,T2E);        
    
    % if(whatComposition==2)
    % Copy T2S first; otherwise you will copy a data that has been updated by a new value
    else
        % T2_START,index = T1_START,inedex
        data(index,T2S) = data(index,T1S);

        % T1_END,index = T2_END,match
        data(index,T1E) = data(match,T2E); 
                
        % T1_START,index = T1_START,match
        data(index,T1S) = data(match,T1S);        
    end
    
    % TAVG_INDEX
    data(index,TAVG_INDEX) = ( data(index,T1S)+data(index,T2E) )/2 ;

%%  Delete Data                    
    % Delete p2 data
    % data(match,:)=([] [] [] [] [] [] [] [] [] [] []); 
    data(match,:)=0; % Updated July 2012.
end