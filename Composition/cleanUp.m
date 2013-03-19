%% ************************** Documentation *******************************
% The clean-up phase consists of three steps that filter less significant signals. 
% To do so, compositions are analyzed under a couple of contexts (in a state??): 
% (1) composition�s time duration, (2) composition�s amplitude magnitude, and (3) 
% repletion patterns. 
%
% Time Duration Context
% 1.	If there is a composition where one of the two primitives that compose it is 
%       5 times smaller than the other (except for contacts c,pc,nc), then merge 
%       by changing the action composition label to correspond to the longer primitive:
%           o bpos/mpos/spos becomes �i'. 
%           o bneg/mneg/sneg becomes �d�. 
%           o const becomes �k�.
%
% Amplitude Value Context
% The analysis of amplitude value context pertains to the formation of alignment signals. 
% 1.	If there are primitives of types PC or NC AND if: 
%           o their amplitude is 10x smaller than the large amplitude registered in the 
%             assembly, then treat them as increase or decrease.
% 2.	If there is an adjustment followed by either an increase or a decrese with similar 
%       average value, merge them into an adjustment. 
% 3.	If there is a d||i||k with similar amplitude and an average value
%       within 50% of each other, merge as constant. 
%
% Repeated Compositions
% 1.	For all compositions, that are adjustments, if they are repeated in states 
%       3 or 4, then merge them. 
% 2.    For any actions that are not adjustments, if they repeat, merge them.
% 
% Input Parameters:
% strategyType      - customize code according to strategies
% motComps:         - [actnClass,...
%                      avgMagVal,RMS_VAL,AMPLITUDE_VAL,...
%                      glabel1,glabel2,...
%                      T1S,T1_END,T2S,T2E,TAVG_INDEX]
%
% stateData:        - time at which states start. First entry (out of four)
%                     indicates the time at which the second state starts.
%                     Assumes the 5 states of the Pivot Approach.
% gradLabels        - vector array of ints [-4,-3,-2,-1,0,1,2,3,4] -- modified July 2012. Old>>cell array containing all of the primitive labels
% actionLbl         - vector array of ints [10,20,30,40,50,60,70,80] -- modified July 2012. Old>>cell array containing all the actions motion
%                     compositions
%**************************************************************************
function motComps = cleanUp(StrategyType,motComps,stateData,gradLabels,actionLbl)

%% Initialization

    % Get dimensions of motComps
    r = size(motComps);
    
    % Amplitude context
    maxAmplitude = 0;
    
    % Threshold values to examine whether the average magnitude value and
    % amplitude value for clean up's of adjustment/increase/decrease
    % combinations
    AMP_WINDOW_AD_ID = 0.50;
    MAG_WINDOW_AD_ID = 0.50; 
    
    % Threshold used for combs of increase/constant/decrease
    AMP_WINDOW_IKD = 1.50;
    MAG_WINDOW_IKD = 1.00; 
    
    % Threshold used for combs of pimp/nimp
    AMP_WINDOW_PC_NC = 0.1; 
    
%%  GRADIENT PRIMITIVES

    % CONSTANTS FOR gradLabels (defined in fitRegressionCurves.m)
    BPOS            = 1;        % big   pos gradient
    MPOS            = 2;        % med   pos gradient
    SPOS            = 3;        % small pos gradient
    BNEG            = 4;        % big   neg gradient
    MNEG            = 5;        % med   neg gradient
    SNEG            = 6;        % small neg gradient
    CONST           = 7;        % constant  gradient
    PIMP            = 8;        % large pos gradient 
    NIMP            = 9;        % large neg gradient
    %NONE            = 10;       % none
%%  MOTION COMPOSITION

    % Action Indeces
    adjustment      = 1;    % a==1
    increase        = 2;    % i==2
    decrease        = 3;    % d==3
    constant        = 4;    % k==4
    pos_contact     = 5;    % pc==5
    neg_contact     = 6;    % nc==6
    contact         = 7;    % c==7
    %unstable        = 8;   % u==8

    % mot Comps Structure Indeces
    ACTN_LBL         = 1;   % action class
    AVG_MAG_VAL      = 2;   % average value
    RMS_VAL          = 3;   % rms value
    AMPLITUDE_VAL    = 4;   % amplitude value 
    
    % Labels
    P1LBL = 5; P2LBL = 6;   % label indeces for both primitives
    
    % Time Indeces
    T1S = 7; T1E = 8;
    T2S = 9; T2E = 10;    
    TAVG_INDEX   = 11;
       
%%  DURATION VARIABLES 
   
    % Threshold for merging two primitives according to lengthRatio
    lengthRatio = 5;  % Empirically set
    
%%  Delete Empty Cells If Any. 
    [motComps]= DeleteEmptyRows(motComps);   
    r = size(motComps);    
     
%%  TIME DURATION CONTEXT - MERGE AND MODIFY Primitives
    for i=1:r(1)
        
        % If it is not a contact label compare the times.
        if(~intcmp(motComps(i,ACTN_LBL),actionLbl(pos_contact)) && ...
                ~intcmp(motComps(i,ACTN_LBL),actionLbl(neg_contact)) && ...
                    ~intcmp(motComps(i,ACTN_LBL),actionLbl(contact)) )
                
            % Get Duration of primitives inside compositions
            p1time = motComps(i,T1E)-motComps(i,T1S);   % Get duration of first primitive
            p2time = motComps(i,T2E)-motComps(i,T2S);   % Get duration of second primitive
            if(p1time == 0 || p2time == 0)              % If a duration is equal to zero, it means that data set was eliminated after a merger
                continue;
            end            

            % If the comparative length of either primitive is superior, merge
            ratio = p1time/p2time;

            % Assign appropriate primitive label to variable to change the
            % motion composition label as it corresponds to the right primitive
            primLbl = 0;
            if(ratio > lengthRatio)
                primLbl = P1LBL;
            elseif(ratio < inv(lengthRatio))
                primLbl = P2LBL;       
            end

            if(~primLbl==0)
                % 1) Change the action class label from the primitive detected to a
                % corresponding action

                % Positive Gradients
                if( intcmp(motComps(i,primLbl), gradLbl2gradInt(gradLabels(BPOS,:)))     || intcmp(motComps(i,primLbl), gradLbl2gradInt(gradLabels(MPOS,:))) || intcmp(motComps(i,primLbl),gradLbl2gradInt(gradLabels(SPOS,:)))) 
                    motComps(i,ACTN_LBL) = actionLbl(increase);

                % Negative Gradients
                elseif( intcmp(motComps(i,primLbl), gradLbl2gradInt(gradLabels(BNEG,:))) || intcmp(motComps(i,primLbl), gradLbl2gradInt(gradLabels(MNEG,:))) || intcmp(motComps(i,primLbl),gradLbl2gradInt(gradLabels(SNEG,:))))
                    motComps(i,ACTN_LBL) = actionLbl(decrease);

                % Impulses
                elseif( intcmp(motComps(i,primLbl), gradLbl2gradInt(gradLabels(PIMP,:))))
                    motComps(i,ACTN_LBL) = actionLbl(pos_contact);
                    
                elseif( intcmp(motComps(i,primLbl), gradLbl2gradInt(gradLabels(NIMP,:))))
                    motComps(i,ACTN_LBL) = actionLbl(neg_contact);   

                % Constant
                elseif(intcmp(motComps(i,primLbl),gradLbl2gradInt(gradLabels(CONST,:))))
                    motComps(i,ACTN_LBL) = actionLbl(constant);   
                end
            end

            % Also collect the maximum amplitude contained by any one
            % composition used in the AMPLITUDE VALUE CONTEXT
            if(motComps(i,AMPLITUDE_VAL)>maxAmplitude)
                maxAmplitude = motComps(i,AMPLITUDE_VAL);
            end
        end
    end
    
%%  Delete Empty Cells
    [motComps]= DeleteEmptyRows(motComps);        
    % Update size variable of motCmops after resizing
    r = size(motComps);     

%%  TIME DURATION CONTEXT - MERGE AND MODIFY Composite Actions
    for i=1:r(1)-1
        
        % If it is not a contact label compare the times.
        if(~intcmp(motComps(i,ACTN_LBL),actionLbl(pos_contact)) && ...
                ~intcmp(motComps(i,ACTN_LBL),actionLbl(neg_contact)) && ...
                    ~intcmp(motComps(i,ACTN_LBL),actionLbl(contact)) )
                
            % Get Duration of primitives inside compositions
            c1duration = motComps(i,T2E)-motComps(i,T1S);       % Get duration of first composition
            c2duration = motComps(i+1,T2E)-motComps(i+1,T1S);   % Get duration of second composition
            if(c1duration == 0 || c2duration == 0)              % If a duration is equal to zero, it means that data set was eliminated after a merger
                continue;
            end

            % If the comparative length of either composition is superior, merge
            ratio = c1duration/c2duration;

            % Assign appropriate primitive label to variable to change the
            % motion composition label as it corresponds to the right
            % action
            if(ratio > lengthRatio)
                 % Merge the second unto the first
                LABEL_FLAG      = true;
                AMPLITUDE_FLAG  = false;
                
                % Find the type of action label that we have to pass to
                % MergeCompositions
                if(intcmp( motComps(i,ACTN_LBL),actionLbl2actionInt('a')))
                    actionLblIndex = 1;
                elseif(intcmp(motComps(i,ACTN_LBL),actionLbl2actionInt('i')))
                    actionLblIndex = 2;
                 elseif(intcmp(motComps(i,ACTN_LBL),actionLbl2actionInt('d')))
                    actionLblIndex = 3;
                elseif(intcmp(motComps(i,ACTN_LBL),actionLbl2actionInt('k')))
                    actionLblIndex = 4;
                else
                    actionLblIndex = -1;
                end
                
                % Merge unto the first composition
                motComps = MergeCompositions(i,motComps,actionLbl,actionLblIndex,LABEL_FLAG,AMPLITUDE_FLAG,1);           
                
            elseif(ratio < inv(lengthRatio))  
                % Merge the first unto the second
                LABEL_FLAG      = false;
                AMPLITUDE_FLAG  = false;
                                % Find the type of action label that we have to pass to
                % MergeCompositions
                if(intcmp( motComps(i+1,ACTN_LBL),actionLbl2actionInt('a')) )
                    actionLblIndex = 1;
                elseif(intcmp(motComps(i+1,ACTN_LBL),actionLbl2actionInt('i')))
                    actionLblIndex = 2;
                elseif(intcmp(motComps(i+1,ACTN_LBL),actionLbl2actionInt('d')))
                    actionLblIndex = 3;
                elseif(intcmp(motComps(i+1,ACTN_LBL),actionLbl2actionInt('k')))
                    actionLblIndex = 4;
                else
                    actionLblIndex = -1;
                end
                
                % Merge unto the SECOND composition
                motComps = MergeCompositions(i+1,motComps,actionLbl,motComps(i+1,ACTN_LBL),LABEL_FLAG,AMPLITUDE_FLAG,2);  % The last argument represents 2nd composition         
            end            
        end
    end
    
%%  Delete Empty Cells
    [motComps]= DeleteEmptyRows(motComps);        
    % Update size variable of motCmops after resizing
    r = size(motComps); 
    
%%  Repeated Compositions

%% 1) REPEATED ADJUSTMENT'S {aaa...)
%%  Inintialization

    % Number of states to analyze:
    % Analyze states where there is force contact. 
    % In thePA10 experiments and the PivotApproach, only the Adjustment and Contact Position use force contact.
    % In HIRO and the side approach we include the Rotation and Insertion
    if(~strcmp(StrategyType,'HSA'))
        NumStates       = length(stateData)-2;
        
    % HIRO Side Approach
    else
        NumStates       = length(stateData)-3;
    end
        
    
    % Set the simulation time step
    if(~strcmp(StrategyType,'HSA'))
        SIM_TIME_STEP   = 0.001;                % Uses OpenHRP-3.1.1 or higher release.  
    else
        SIM_TIME_STEP   = 0.002;                % Uses 3.0.0 version
    end
%%  Define the state vector for states 3-5.
    % Create a 3x2 vector that does not contains the first and last items of each
    % state. Create a for loop that iterates through all time indeces of a
    % given state, and at the end, changes the indeces of the for loop to
    % go through the next state. 
    stateVec        = zeros(NumStates,2);
    stateVec(1,:)   = [stateData(2,1),(stateData(3,1)-SIM_TIME_STEP)];  % State 2. Need to subtract one time step based on simulation timing.
    stateVec(2,:)   = [stateData(3,1),(stateData(4,1)-SIM_TIME_STEP)];  % State 3 
            
    % Do this until there are no more repitions in the entire data
    % (multiple loops)    
    
    % Repetition variables
    noActionRepeat  = true;
    repeatCtr       = 0;
       
%%  Iterate through all compositions except last one
    for i=1:r(1)-1

        % Next Index
        j = i+1;

        % Do this if there aren't any empty cells
        %if( ~isempty([motComps(i,:)]))
        if( ~all(motComps(i,:)==0)) % Updated July 2012

            % Merge for iterations in relevants states: PA10-PivApp: states
            % 3 and 4; HIRO-SideApp: states 2 and 3.
            if(motComps(i,T1S)>stateVec(1,1) && motComps(j,T2E) < stateVec(2,2))

                % If there are two contiguous actionLbl2actionInt('a')s accross compositions
                if(intcmp( motComps(i,ACTN_LBL),  actionLbl2actionInt('a')) && intcmp(motComps(j,ACTN_LBL),actionLbl2actionInt('a')))

                    % If their avg value are within a threshold percentage
                    % of each other merge them, and make them a constant. 
                    perc1 = computePercentageThresh(motComps,i,AVG_MAG_VAL,AMP_WINDOW_AD_ID);
                    if(perc1)
                        noActionRepeat  = false;
                        repeatCtr       = repeatCtr + 1;
                    end

                    % Difficult condition: if repeatCtr and not
                    % ActionRepeat, the the next next motComps is not a, then:
                    % This is necessary b/c in the last iteration of
                    % actionLbl2actionInt('a'),actionLbl2actionInt('a'), this part will be skipped if use elseif,
                    % then counter counts for two different segments.
                    if(~noActionRepeat && repeatCtr > 0)
                        if(j+1 < (r(1)) && (~intcmp(motComps(j+1,ACTN_LBL),actionLbl2actionInt('a')) || ~computePercentageThresh(motComps,j+1,AVG_MAG_VAL,AMP_WINDOW_AD_ID)))
                        
                            % Set first and last indeces
                            fI = i-(repeatCtr-1);  % A way to retrieve the index with the first occurence of actionLbl2actionInt('a')
                            lI = fI+repeatCtr;
                            
                            % Total num of elements
                            n = repeatCtr+1;

                            % Change action label of repatIndex to adjustment
                            motComps(fI,ACTN_LBL)     = actionLbl(adjustment);     

                            % Merge according to the number of repeated values                                                         
                            motComps(fI,AVG_MAG_VAL)  = sum( [motComps(fI:lI,AVG_MAG_VAL)])  /n;       % avg val
                            motComps(fI,RMS_VAL)      = sum( [motComps(fI:lI,RMS_VAL)])      /n;       % rms val
                            motComps(fI,AMPLITUDE_VAL)= max( [motComps(fI:lI,AMPLITUDE_VAL)]);       % set this value to the maximum amplitude found in the set

                            % T1_END,i = T2E - T1S/2
                            motComps(fI,T1E) = ((motComps(lI,T2E)+motComps(fI,T1S))/2)-SIM_TIME_STEP;
                            % T2S,i = T1S,j
                            motComps(fI,T2S) = motComps(fI,T1E)+0.001;
                            % T2E,i = T2E,j
                            motComps(fI,T2E) = motComps(lI,T2E);

                            % TAVG_INDEX
                            motComps(fI,TAVG_INDEX) = ( motComps(fI,T1S)+motComps(fI,T2E) )/2 ;                

                            % Delete second motComps
                            for rep = fI+1:lI
                                % motComps(rep,:)={[] [] [] [] [] [] [] [] [] [] []);  
                                motComps(rep,:)=0;      % Changed to int representation. July 2012
                            end

                            % Change the repeat flag                           
                            noActionRepeat= true;                             
                            repeatCtr   = 0;    
                        end
                    end % End Action Repeat                                                            
                end     % End if two contiguous actionLbl2actionInt('a')s                
            end         % End iterations through if statment                        
        end             % End if not empty
    end                 % For loop
    
    % Delete empty rows
    [motComps]= DeleteEmptyRows(motComps);
    
%%  2) Merge repeated signals. // Do this until there are no more repitions in the entire data (multiple loops)   
    
    % Recompute the rows of motComps after row deletion
    r = size(motComps);
    
    % no repeatition flag
    noRepeat    = false;
    
%%  Until no more repeats    
    while(~noRepeat)

        % Set noRepat flag here to true. If there is a reptition inside,
        % set it to false. Such that, when there are no more repetitions, it will exit
        noRepeat = true;
        
        % For all motion compositions
        for i=1:r(1)-1
            j = i+1;
            
%%          For all action class labels except assignment
            if(intcmp(motComps(i,1),actionLbl2actionInt('a'))==0)
                if(intcmp(motComps(i,1),motComps(j,1)))

                    % Copy relevant data from p2 to p1: [actnClass,avgMagVal,RMS_VAL,glabel1,glabel2,
                                                        %T1S,T1_END,T2S,T2E,TAVG_INDEX]                                                        
                    % Merge into alignment
                    LABEL_FLAG      = false;
                    AMPLITUDE_FLAG  = false;
                    motComps = MergeCompositions(i,motComps,actionLbl,adjustment,LABEL_FLAG,AMPLITUDE_FLAG,1);
                                                        
                    % Change the noRepeat flag
                    noRepeat = false;
                end
            end
        end
    
%%      Delete Empty Cells
        [motComps]= DeleteEmptyRows(motComps);        
        % Update size variable of motCmops after resizing
        r = size(motComps);
               
    end % End while no repeat    

%%  AMPLITUDE VALUE CONTEXT

%%  1) If there are pos_contacts or neg_contacts whose amplitude is 10x
    % smaller than the largest amplitude convert them into 'i' or 'd'
    % correspondingly.  

    for i=1:r(1)
        
        % Find positive contacts
        if(intcmp(motComps(i,ACTN_LBL),actionLbl(pos_contact)))
            if(abs(motComps(i,AMPLITUDE_VAL))<AMP_WINDOW_PC_NC*abs(maxAmplitude))
                motComps(i,ACTN_LBL)=actionLbl(increase);
            end

        % Find negative contacts
        elseif(intcmp(motComps(i,ACTN_LBL),actionLbl(neg_contact)))
            if(abs(motComps(i,AMPLITUDE_VAL))<AMP_WINDOW_PC_NC*abs(maxAmplitude))
                motComps(i,ACTN_LBL)=actionLbl(decrease);
            end            
        end
    end

%%  The code below was merged with the i/d/k combination sequences
% %%	2) If there are contiguous i+d or d+i with similar average values (within 20% of each  
% %   other),merge them into an adjustment.    
% 
%     AmplitudeRatio = 0.2;
%     AverageValue   = 0.2;
%     % For all compositions except the last one
%     for index = 1:r(1)-1
%         
%         % Create an index for the contiguous element
%         match = index +1;        
%         
%         % If 'id' or 'di' pair
%         if( intcmp(motComps(index,ACTN_LBL),actionLbl(increase)) && intcmp(motComps(match,ACTN_LBL),actionLbl(decrease)) || ...
%                 intcmp(motComps(index,ACTN_LBL),actionLbl(decrease)) && intcmp(motComps(match,ACTN_LBL),actionLbl(increase)) )
%             
%             % If the absolute value of the difference is within 10% of each other
%             perc1 = computePercentageThresh(motComps,index,AVG_MAG_VAL,AverageValue);            
%             if(perc1)
%                 
%                 % Merge as adjustment into the first element, adjust times,
%                 % and then empty the second composition
%                 LABEL_FLAG      = true;
%                 AMPLITUDE_FLAG  = true;
%                 motComps = MergeCompositions(index,motComps,actionLbl,adjustment,LABEL_FLAG,AMPLITUDE_FLAG);
%             end            
%         end               
%     end
% 
% %%  Delete Empty Cells
%     [motComps]= DeleteEmptyRows(motComps);        
%     % Update size variable of motCmops after resizing
%     r = size(motComps);    
        
%%	2) For patterns of a+i or a+d or d+a or d+i, merge if similar. 
    % If there are contiguous i+d or d+i with similar average values
	% (within 10% of each other),merge them into an adjustment.    
    
    % For all compositions except the last one
    for index = 1:r(1)-1
        
        % Create an index for the contiguous element
        match = index +1;        
        
        % If 'a+i' or 'a+d' or 'i+a' or 'd+a'
        if( (intcmp(motComps(index,ACTN_LBL),actionLbl(adjustment)) && intcmp(motComps(match,ACTN_LBL),actionLbl(increase))) || ...
                (intcmp(motComps(index,ACTN_LBL),actionLbl(adjustment)) && intcmp(motComps(match,ACTN_LBL),actionLbl(decrease))) || ...
                     (intcmp(motComps(index,ACTN_LBL),actionLbl(increase)) && intcmp(motComps(match,ACTN_LBL),actionLbl(adjustment))) || ...
                        (intcmp(motComps(index,ACTN_LBL),actionLbl(decrease)) && intcmp(motComps(match,ACTN_LBL),actionLbl(adjustment))) )
            
            % If they have the similar amplitude (50%)             
            perc1 = computePercentageThresh(motComps,index,AMPLITUDE_VAL,AMP_WINDOW_AD_ID);            
            if(perc1)       
                
                % If their average value is within 100% of each other
                perc2 = computePercentageThresh(motComps,index,AVG_MAG_VAL,MAG_WINDOW_AD_ID);            
                if(perc2)                
                    % Merge as adjustment into the first element, adjust times,
                    % and then empty the second composition
                    LABEL_FLAG      = true;
                    AMPLITUDE_FLAG  = true;
                    motComps = MergeCompositions(index,motComps,actionLbl,adjustment,LABEL_FLAG,AMPLITUDE_FLAG,1);
                end                
            end                        
        end     
    end
    
%%  Delete Empty Cells
    [motComps]= DeleteEmptyRows(motComps);        
    % Update size variable of motCmops after resizing
    r = size(motComps);        
    
%% 3) ik/ki/dk/kd compositions that are contiguous that have similar amplitude and their avg value is within 50% to each other, merge as constant

    % Go through all compositions except the last one
    for index = 1:r(1)-1
        
        % Next Index
        match = index+1;
        
        if( (intcmp(motComps(index,ACTN_LBL),actionLbl(increase))&& intcmp(motComps(match,ACTN_LBL),actionLbl(constant))) || ...
             (intcmp(motComps(index,ACTN_LBL),actionLbl(constant))&& intcmp(motComps(match,ACTN_LBL),actionLbl(increase))) || ...
                (intcmp(motComps(index,ACTN_LBL),actionLbl(decrease))&& intcmp(motComps(match,ACTN_LBL),actionLbl(constant))) || ...
                    (intcmp(motComps(index,ACTN_LBL),actionLbl(constant))&& intcmp(motComps(match,ACTN_LBL),actionLbl(decrease))) || ...
                        (intcmp(motComps(index,ACTN_LBL),actionLbl(decrease))&& intcmp(motComps(match,ACTN_LBL),actionLbl(increase))) || ...
                            (intcmp(motComps(index,ACTN_LBL),actionLbl(increase))&& intcmp(motComps(match,ACTN_LBL),actionLbl(decrease))) )
                
            % If they have the similar amplitude (150%)     
            perc1 = computePercentageThresh(motComps,index,AMPLITUDE_VAL,AMP_WINDOW_IKD);            
            if(perc1)       
                
                % If their average value is within 100% of each other
                perc2 = computePercentageThresh(motComps,index,AVG_MAG_VAL,MAG_WINDOW_IKD);            
                if(perc2)                

                    LABEL_FLAG      = true;
                    AMPLITUDE_FLAG  = true;
                    motComps = MergeCompositions(index,motComps,actionLbl,constant,LABEL_FLAG,AMPLITUDE_FLAG,1);
                end
            end
        end
    end
    
%%  Delete Empty Cells
    [motComps]= DeleteEmptyRows(motComps);        
    % Update size variable of motCmops after resizing
    r = size(motComps);           
end