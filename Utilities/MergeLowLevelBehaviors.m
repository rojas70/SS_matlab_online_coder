%% **************************** Documentation *****************************
% Merges data between two continguous elements in a data composition data
% structure. 
% 
% The llb data structure is a cell array composed of 17 elements: 
% data:(nameLabel,avgVal1,avgVal2,Avg_avgVal,rmsVal1,rmsVal2,Avg_rmsVal,amplitudeVal1,amplitudeVal2,Avg_amplitudeVal,p1lbl,p2lbl,t1Start,t1End,t2Start,t2End,tAvgIndex)
% 
% Input Parameters:
% index:        - first element of contiguous pair.
% data:         - an mx11 cell array data structure.
% llbehLbl      - cell array structure that holds strings for action compositions
% llbehLblIndex - index to select what label to use.
% LBL_FLAG      - Used to indicate whether to change the name to some
%                 indicated name
%**************************************************************************
function data = MergeLowLevelBehaviors(index,data,llbehLbl,llbehLblIndex,LBL_FLAG)

%%  Initialization

    % Define next contiguous element
    match = index+1;

    % CONSTANTS FOR gradLabels (defined in fitRegressionCurves.m)
% 	FIX     = 1;        % Fixed in place
%   CONTACT = 2;        % Contact
%   PUSH    = 3;        % Push
%   PULL    = 4;        % Pull
%   ALIGN   = 5;        % Alignment
%   SHIFT   = 6;        % Shift
%   UNSTABLE= 7;        % Unstable
%   NOISE   = 8;        % Noise
%  llbehLbl    = ('FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N'); % ('fix' 'cont' 'push' 'pull' 'align' 'shift' 'unstable' 'noise');

    % llbehStruc Indeces
    behLbl          = 1;   % action class
    averageVal1     = 2;   % averageVal1
    averageVal2     = 3;
    AVG_MAG_VAL     = 4;
   %rmsVal1         = 5;
    rmsVal2         = 6;
    AVG_RMS_VAL     = 7;
   %ampVal1         = 8;
    ampVal2         = 9;
    AVG_AMP_VAL     = 10;
    mc1             = 11;
    mc2             = 12;    
    T1S             = 13; 
    T1E             = 14;
    T2S             = 15; 
    T2E             = 16;    
    TAVG_INDEX      = 17;    
    
%%  Name Label 
    if(LBL_FLAG)
        data(index,behLbl) = llbehLbl(llbehLblIndex); % Set this tag for adjustment, 'a'.
    end

%% Update values for non-noisy signals
    if(~strcmp(data(index,mc2),actionLbl2actionInt('n')) && ~strcmp(data(match,mc2),actionLbl2actionInt('n')))

%% Values        
        %%  Average Values
        data(index,averageVal2) = data(match,averageVal2);
        data(index,AVG_MAG_VAL) = ( data(index,AVG_MAG_VAL) + data(match,AVG_MAG_VAL) )/2; 
        
        %% RMS Values
        data(index,rmsVal2)     = data(match,rmsVal2);
        data(index,AVG_RMS_VAL) = ( data(index,AVG_RMS_VAL) + data(match,AVG_RMS_VAL) )/2;   
        
        %% Amplitude Value
        data(index,ampVal2)     = data(match,ampVal2);
        data(index,AVG_AMP_VAL) = ( data(index,AVG_AMP_VAL) + data(match,AVG_AMP_VAL) )/2;        

%%  LABELS
        % In this case assign low-level behavior labels for the
        % motion-composition labels. 
        data(index,mc1) = data(index,behLbl);   data(index,mc2) = data(index,behLbl);
        data(match,mc1) = data(match,behLbl);   data(match,mc2) = data(match,behLbl);

%%  Time
        %      (index)             (match)
        %   t1S,t1E  t2s,t2E    t1S,t1E  t2s,t2E
        % T1_END,index = T2_END,index
        data(index,T1E) = data(index,T2E);

        % T2_START,index = T1_START,match
        data(index,T2S) = data(match,T1S);

        % T2_END,index = T2_END,match
        data(index,T2E) = data(match,T2E);
        
        % Check limits - for strange cases
        
        %% index and match are in reverse order
        % if t2e,match = t1s,index then set (t1s,match) as the beginning.
        % The end won't need to be changed because  t2e,index is already
        % pointing to the end
        if(data(match,T2E) == data(index,T1S))
            data(index,T1S)=data(match,T1S);
        end
        
        % If the ending of T1E is greater than T2E
        if(data(index,T1E)>data(index,T2E))
            data(index,T2E)=data(index,T1E);   
        end
            
        % If t1S > t2S in the same one
        if(data(index,T2S)<data(index,T1S))
            data(index,T1S)=data(index,T2S);
        end
            
        % If the end of index is less than the start of match
        if(data(index,T2E)<data(match,T1S))
            data(index,T1S)=data(index,T2S);                     
        end

        % TAVG_INDEX
        data(index,TAVG_INDEX) = ( data(index,T1S)+data(index,T2E) )/2 ;

%%  FIRST composition is NOISY and the 2ND is NOT
    elseif( strcmp(data(index,mc2),actionLbl2actionInt('n')) && ~strcmp(data(match,mc2),actionLbl2actionInt('n')) )
       
        %%  Values                                                        
        % Copy values of 2nd into first
        data(index,averageVal2) = data(match,averageVal2);
        data(index,AVG_MAG_VAL) = data(match,AVG_MAG_VAL);  % Do not average 
        
        %% RMS Values
        data(index,rmsVal2)     = data(match,rmsVal2);
        data(index,AVG_RMS_VAL) = data(match,AVG_RMS_VAL);  % Do not average 
        
        %% Amplitude Value
        data(index,ampVal2)     = data(match,ampVal2);
        data(index,AVG_AMP_VAL) = data(match,AVG_AMP_VAL);  % Do not average 

%%  LABELS
        % In this case assign low-level behavior labels for the
        % motion-composition labels. 
        data(index,mc1) = data(index,behLbl);
        data(match,mc2) = data(match,behLbl);

%%  Time
        % T1_END,index = T1_END,match
        % data(index,T1E) = data(match,T1E);

        % T2_START,index = T1_START,match
        data(index,T2S) = data(match,T1S);

        % T2_END,index = T2_END,match
        data(index,T2E) = data(match,T2E);

        % TAVG_INDEX
        data(index,TAVG_INDEX) = ( data(index,T1S)+data(index,T2E) )/2 ;        
%%  SECOND composition is NOISY and the 1ST one is NOT. 
    % At the end we keep the data in index and eliminate the data in match. 
    elseif(strcmp(data(match,mc2),actionLbl2actionInt('n')) && ~strcmp(data(index,mc2),actionLbl2actionInt('n')))
    
%%  Values                                                        
        % Do NOT Average values that include noisy signal
%         for i = averageVal1:AVG_AMP_VAL
%             data(index,i) = ( data(index,i) + data(match,i) )/2; 
%         end

%%  LABELS
        % In this case assign low-level behavior labels for the
        % motion-composition labels. 
        data(index,mc1) = data(index,behLbl);
        data(match,mc2) = data(match,behLbl);

%%  Time
        
        % T1_END, index = T2_END, index
        data(index,T1E) = data(index,T2E);
        
        % T2_START,index = T1_START,match
        data(index,T2S) = data(match,T1S);

        % T2_END,index = T1_END,match
        data(index,T2E) = data(match,T1E);

        % TAVG_INDEX
        data(index,TAVG_INDEX) = ( data(index,T1S)+data(index,T2E) )/2 ;    
    
%%  Both compositions are noisy        
    else 
%%  Values                                                        
        % Average all values from 2 to 10
        for i = averageVal1:AVG_AMP_VAL
            data(index,i) = ( data(index,i) + data(match,i) )/2; 
        end

%%  LABELS

        % In this case assign low-level behavior labels for the
        % motion-composition labels. 
        data(index,mc1) = data(index,behLbl);
        data(match,mc2) = data(match,behLbl);

%%  Time
        % T2_START,index = T1_START,match
        data(index,T2S) = data(match,T1S);

        % T2_END,index = T1_END,match
        data(index,T2E) = data(match,T1E);

        % TAVG_INDEX
        data(index,TAVG_INDEX) = ( data(index,T1S)+data(index,T2E) )/2 ;         
    end

%%  Delete Data
    data(match,:)=0; % Updated July 2012. data(match,:)=([] [] [] [] [] [] [] [] [] [] [] [] [] [] [] [] []); 
end