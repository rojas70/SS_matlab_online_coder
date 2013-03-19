%% ************************** Documentation *******************************
% The clean-up phase consists of three steps that filter less significant signals. 
% To do so, compositions are analyzed under two contexts: (1) composition�s 
% amplitude magnitude, and (3) repletion patterns. 
%
% Amplitude Value Context
% The analysis of amplitude value context pertains to the formation of alignment signals. 
% 1.	If there is push-pull or pull-push of similar amplitude and similar average value, then turn into a ALIGN.
% 2.	If there is a shift/alignment followed by a shift/alignment of smaller amplitude respectively, convert into an alignment.
% 3.	If there is a pattern ALIGN/PS, ALIGN/PL or in reverse-order which have about the same amplitude and average value, merge as align. 
%   	a. Same as above with SHIFT. 
% 4.    If there is a push-fix/fix-push or pull-fix/fix-pull of similar amplitude and similar average value then turn into a fix.
%
% Repeated Patterns
% 1.	If there are any repeated signals merge. 
% 
% Input Parameters:
% llbehStruc:       - [actnClass,...
%                      avgMagVal1,avgMagVal1,AVG_MAG_VAL,
%                      rmsVal1,rmsVal2,AVG_RMS_VAL,
%                      ampVal1,ampVal2,AVG_AMP_VAL,
%                      mc1,mc2,
%                      T1S,T1_END,T2S,T2E,TAVG_INDEX]
%
% actionLbl:        - different possible actions for motion compositions.
%**************************************************************************
function llbehStruc = Refinement(llbehStruc,actionLbl)

%% Initialization

    % Get dimensions of llbehStruc
    r = size(llbehStruc);    

%%  Motion Composition Actions
%    adjustment      = 1;    % a
%    increase        = 2;    % i
%    decrease        = 3;    % d
%    constant        = 4;    % k
%    pos_contact     = 5;    % pc
%    neg_contact     = 6;    % nc
%    contact         = 7;    % c
     unstable        = 8;    % u
%    noise           = 9;    % n
     none            = 10;   % z
%    actionLbl       = ('a','i','d','k','pc','nc','c','u','n','z');  % String representation of each possibility in the actnClass set.                     
%%  Low-Level Behaviors
	FIX     = 1;        % Fixed in place
    CONTACT = 2;        % Contact
    PUSH    = 3;        % Push
    PULL    = 4;        % Pull
    ALIGN   = 5;        % Alignment
    SHIFT   = 6;        % Shift
   %UNSTABLE= 7;        % Unstable
   %NOISE   = 8;        % Noise
   %llbehLbl= ('FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N'); % ('fix' 'cont' 'push' 'pull' 'align' 'shift' 'unstable' 'noise');
    llbehLbl= [ 1,   2,   3,   4,   5,   6,   7,  8];
    
    % llbehStruc Indeces
    behLbl          = 1;   % action class
%   averageVal1     = 2;   % averageVal1
%   averageVal2     = 3;
    AVG_MAG_VAL     = 4;
%   rmsVal1         = 5;
%   rmsVal2         = 6;
%   AVG_RMS_VAL     = 7;
%   ampVal1         = 8;
%   ampVal2         = 9;
    AVG_AMP_VAL     = 10;
%   mc1             = 11;
    mc2             = 12;    
    T1S             = 13; 
    T1E             = 14;
%   T2S             = 15; 
    T2E             = 16;    
%   TAVG_INDEX      = 17;
       
%%  DURATION VARIABLES 
   
    % Threshold for merging two primitives according to lengthRatio
    lengthRatio = 5;  % Empirically set
    
%% WINDOW THRESHOLDS

    % For amplitude windows and average value windows for combinations of ALIGN/PS/PL
    AMP_WINDOW_ALIGN_PS_PL = 0.5;
    MAG_WINDOW_ALIGN_PS_PL = 1.0;
    
    % For push pull combinations
    AMP_WINDOW_PS_PL = 1.5;
    MAG_WINDOW_PS_PL = 1.0;
    
    % For FIX push pull combinations
    AMP_WINDOW_FIX = 0.75;
    MAG_WINDOW_FIX = 0.75;
     
%%  TIME DURATION CONTEXT - MERGE AND MODIFY
    index = 1;
    while(index<r(1)-1) % for all compositions except the last one
        
        % Next index
        match=index+1 ;
        
        %% For all behavior pairs that are not contact behaviors or have
        %% unstable or noisy behaviors (has a none or 'z' composition) inside of them. 
        if((~intcmp(llbehStruc(index,behLbl),llbehLbl(CONTACT)) && ~intcmp(llbehStruc(match,behLbl),llbehLbl(CONTACT))) && ...
                (~intcmp(llbehStruc(index,mc2),actionLbl(unstable)) && ~intcmp(llbehStruc(match,mc2),actionLbl(unstable))) && ...
                    (~intcmp(llbehStruc(index,mc2),actionLbl(none)) && ~intcmp(llbehStruc(match,mc2),actionLbl(none))) )
                
            % Get duration of non-noisy compositions
            if(~intcmp(llbehStruc(index,mc2),actionLbl2actionInt('n')) && ~intcmp(llbehStruc(match,mc2),actionLbl2actionInt('n')))
                p1time = llbehStruc(index,T2E)-llbehStruc(index,T1S);   % Get duration of first primitive
                p2time = llbehStruc(match,T2E)-llbehStruc(match,T1S);   % Get duration of second primitive            
            % For the noisy signal
            elseif(intcmp(llbehStruc(index,mc2),actionLbl2actionInt('n')))
                p1time = llbehStruc(index,T1E)-llbehStruc(index,T1S);   % Shortcut duration of first primitive
                p2time = llbehStruc(match,T2E)-llbehStruc(match,T1S);   % 
            else %(intcmp(llbehStruc(match,mc2),actionLbl2actionInt('n'))
                p1time = llbehStruc(index,T2E)-llbehStruc(index,T1S);   % 
                p2time = llbehStruc(match,T1E)-llbehStruc(match,T1S);   % Shortcut duration of first primitive
            end
            
            % If the comparative length of either primitive is superior, merge
            ratio = p1time/p2time;
                        
            if    (ratio > lengthRatio)         
                primLbl = 0;   % First behavior lasts longer                          
            elseif(ratio < inv(lengthRatio))    
                primLbl = 1;   % Second behavior lasts longer    
            else
                primLbl = -1;  % Does not qualify
            end
            
            %% Merge to index
            if(primLbl==0)
                LBL_FLAG = 0; % Don't assign label
                llbehStruc = MergeLowLevelBehaviors(index,llbehStruc,llbehLbl,0,LBL_FLAG);
                
                % Increase index
                index = index + 2; % To skip over deleted row
                
            elseif(primLbl==1)
                % Copy the match row to the index row
                len = length(llbehStruc(index,:));          % Get length of cell array
                temp = zeros(1,len);                        % Create a temp structure
                temp(1,:) = llbehStruc(index,:);            % Copy the data in current index
                llbehStruc(index,:) = llbehStruc(match,:);  % Copy data from next index to current index for use with MergeLowLevelBehaviors()
                llbehStruc(match,:) = temp(1,:);            % Copy the temp data to match 
                
                % Merge
                LBL_FLAG = 0; % Don't assign label
                llbehStruc = MergeLowLevelBehaviors(index,llbehStruc,llbehLbl,0,LBL_FLAG);
                
                % Increase index
                index = index + 2; % To skip over deleted row
                                
            % Signal does not qualify
            else
                break;
            end
        end
        
        index = index + 1;
    end
    
%%  Delete Empty Cells
    [llbehStruc]= DeleteEmptyRows(llbehStruc);        
    % Update size variable of llbehStruc after resizing
    r = size(llbehStruc);    

%%  AMPLITUDE VALUE CONTEXT

%%  1) If there are PUSH/PULL OR PULL/PUSH of similar amplitude and similar
%%  average value, then merge as ALIGN. 

    for index=1:r(1)-1
        
        % Next Index
        match = index+1;
        
        % Find push/pull or pull/push
        if( (intcmp(llbehStruc(index,behLbl),llbehLbl(PUSH)) && intcmp(llbehStruc(match,behLbl),llbehLbl(PULL))) || ...
                (intcmp(llbehStruc(index,behLbl),llbehLbl(PULL)) && intcmp(llbehStruc(match,behLbl),llbehLbl(PUSH))) )
            
            % If similar amplitude (150%)     
            perc1 = computePercentageThresh(llbehStruc,index,AVG_AMP_VAL,AMP_WINDOW_PS_PL);            
            if(perc1)  
                
                % If similar average value (100%)      
                perc2 = computePercentageThresh(llbehStruc,index,AVG_AMP_VAL,MAG_WINDOW_PS_PL);
                
                if(perc2)
                    LBL_FLAG = 1; % Assign label
                    llbehStruc = MergeLowLevelBehaviors(index,llbehStruc,llbehLbl,ALIGN,LBL_FLAG);
                end
            end                       
        end
    end
    
%%  Delete Empty Cells
    [llbehStruc]= DeleteEmptyRows(llbehStruc);        
    % Update size variable of llbehStruc after resizing
    r = size(llbehStruc);  
    
%%	2) If there are contiguous (SH/SH),(AL/AL),(SH/AL),(AL/SH) and the second one has a smaller amplitude merge as alignment.    

    for index=1:(r(1)-1)
        
        % Next Index
        match = index+1;
        
        % Find either combination
        if((intcmp(llbehStruc(index,behLbl),llbehLbl(SHIFT)) && intcmp(llbehStruc(match,behLbl),llbehLbl(SHIFT))) || ...
                (intcmp(llbehStruc(index,behLbl),llbehLbl(ALIGN)) && intcmp(llbehStruc(match,behLbl),llbehLbl(ALIGN))) || ...
                    (intcmp(llbehStruc(index,behLbl),llbehLbl(SHIFT)) && intcmp(llbehStruc(match,behLbl),llbehLbl(ALIGN))) || ...
                        (intcmp(llbehStruc(index,behLbl),llbehLbl(ALIGN)) && intcmp(llbehStruc(match,behLbl),llbehLbl(SHIFT))) )
        
            % If the second has a smaller amplitude   
            if(llbehStruc(match,AVG_AMP_VAL)<llbehStruc(index,AVG_AMP_VAL))  
                
                % Merge es alignment
                LBL_FLAG = 1;% Assign a label
                llbehStruc = MergeLowLevelBehaviors(index,llbehStruc,llbehLbl,ALIGN,LBL_FLAG);
            end                       
        end
    end
    
    % Delete Empty Cells
    [llbehStruc]= DeleteEmptyRows(llbehStruc);        
    % Update size variable of llbehStruc after resizing
    r = size(llbehStruc);     
        

    
%%  3) Merge repeated signals 
    
    % Do this until there are no more repitions in the entire llbehStruc (multiple loops)     
    % no repeatition flag
    noRepeat    = false;
    
%%  Until no more repeats    
    while(~noRepeat)

        % Set noRepat flag here to true. If there is a reptition inside,
        % set it to false. Such that, when there are no more repetitions, it will exit
        noRepeat = true;
        
        % For all motion compositions
        for index=1:r(1)-1
            match = index+1;
            
            % For all action class labels except assignment
            if(intcmp(llbehStruc(index,behLbl),llbehStruc(match,behLbl)))

                % Merge correspondingly
                LBL_FLAG = 0; % Keep the label of the first low-level behavior
                llbehStruc = MergeLowLevelBehaviors(index,llbehStruc,llbehLbl,0,LBL_FLAG);

                % Change the noRepeat flag
                noRepeat = false;
            end            
        end
    
        % Delete Empty Cells
        [llbehStruc]= DeleteEmptyRows(llbehStruc);        
        % Update size variable of motCmops after resizing
        r = size(llbehStruc);
               
    end % End while no repeat    
    
%% 2) ALIGN/PS, ALIGN/PL or in reverse-order which have about the same 
%%    amplitude and average value, merge as align. Also with shift. 

    for index=1:r(1)-1
        
        % Next Index
        match = index+1;
        
        % Find either combination
        if( ((intcmp(llbehStruc(index,behLbl),llbehLbl(ALIGN)) || intcmp(llbehStruc(index,behLbl),llbehLbl(SHIFT))) && intcmp(llbehStruc(match,behLbl),llbehLbl(PUSH))) || ...
                ((intcmp(llbehStruc(index,behLbl),llbehLbl(ALIGN)) || intcmp(llbehStruc(index,behLbl),llbehLbl(SHIFT))) && intcmp(llbehStruc(match,behLbl),llbehLbl(PULL))) || ...
                    (intcmp(llbehStruc(index,behLbl),llbehLbl(PUSH)) && intcmp(llbehStruc(match,behLbl),llbehLbl(ALIGN)) && (intcmp(llbehStruc(match,behLbl),llbehLbl(SHIFT)))) || ...
                        (intcmp(llbehStruc(index,behLbl),llbehLbl(PULL)) && intcmp(llbehStruc(match,behLbl),llbehLbl(ALIGN)) && (intcmp(llbehStruc(match,behLbl),llbehLbl(SHIFT)))) ) 
            
            % If they have the similar amplitude (50%)     
            perc1 = computePercentageThresh(llbehStruc,index,AVG_AMP_VAL,AMP_WINDOW_ALIGN_PS_PL);            
            if(perc1)       
                
                % If their average value is within 100% of each other
                perc2 = computePercentageThresh(llbehStruc,index,AVG_MAG_VAL,MAG_WINDOW_ALIGN_PS_PL);            
                if(perc2)                
                   % Merge es alignment
                    LBL_FLAG = 1;% Assign a label
                    llbehStruc = MergeLowLevelBehaviors(index,llbehStruc,llbehLbl,ALIGN,LBL_FLAG);
                end                
            end 
        end
    end
    
    % Delete Empty Cells
    [llbehStruc]= DeleteEmptyRows(llbehStruc);        
    % Update size variable of llbehStruc after resizing
    r = size(llbehStruc);     
    
%% 4) PUSH/PULL/ALGN/SHIFT-FIX or vice-versa llBehs that are contiguous that have similar amplitude and their avg value is within 50% to each other, merge as constant

    % Go through all compositions except the last one
    for index = 1:r(1)-1
        
        % Next Index
        match = index+1;
        
        if( (intcmp(llbehStruc(index,behLbl),llbehLbl(PUSH)) && intcmp(llbehStruc(match,behLbl),llbehLbl(FIX))) || ...
                (intcmp(llbehStruc(index,behLbl),llbehLbl(FIX)) && intcmp(llbehStruc(match,behLbl),llbehLbl(PUSH))) || ...
                    (intcmp(llbehStruc(index,behLbl),llbehLbl(PULL)) && (intcmp(llbehStruc(match,behLbl),llbehLbl(FIX)))) || ...
                        (intcmp(llbehStruc(index,behLbl),llbehLbl(FIX)) && (intcmp(llbehStruc(match,behLbl),llbehLbl(PULL)))) || ...
                            (intcmp(llbehStruc(index,behLbl),llbehLbl(ALIGN)) && intcmp(llbehStruc(match,behLbl),llbehLbl(FIX))) || ...
                                (intcmp(llbehStruc(index,behLbl),llbehLbl(FIX)) && intcmp(llbehStruc(match,behLbl),llbehLbl(ALIGN))) || ...
                                    (intcmp(llbehStruc(index,behLbl),llbehLbl(SHIFT)) && intcmp(llbehStruc(match,behLbl),llbehLbl(FIX))) || ...
                                        (intcmp(llbehStruc(index,behLbl),llbehLbl(FIX)) && intcmp(llbehStruc(match,behLbl),llbehLbl(SHIFT))) ) 
            
            % If they have the similar amplitude (50%)     
            perc1 = computePercentageThresh(llbehStruc,index,AVG_AMP_VAL,AMP_WINDOW_FIX);            
            if(perc1)       
                
                % If their average value is within 25% of each other
                perc2 = computePercentageThresh(llbehStruc,index,AVG_MAG_VAL,MAG_WINDOW_FIX);            
                if(perc2)                
                   % Merge es alignment
                    LBL_FLAG = 1;% Assign a label
                    llbehStruc = MergeLowLevelBehaviors(index,llbehStruc,llbehLbl,FIX,LBL_FLAG);
                end                
            end 
        end
    end
    
%%  Delete Empty Cells
    [llbehStruc]= DeleteEmptyRows(llbehStruc);        
    % Update size variable of motCmops after resizing
    r = size(llbehStruc);               
end