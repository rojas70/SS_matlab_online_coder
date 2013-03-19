%% ********************** Documentation ***********************************
% The LLBeh structure holds low-level behaviors for each force dimension.
%
% This level combines motion composition actions to produce lower-level behaviors in states 
% in which there is contact between parts (State 2 through end). This level compares degrees 
% of change across two motion compositions per state. There are six low-level behaviors which 
% are defined as follows:
% �	Fixed
%	Def: Occurs when the part is no longer moving and remains fixed in
%	place. If single occurrence, duration must be greater than 0.1 secs or
%	otherwise it will be considered noise.
%	Conditions: No change and a total minimum of time 0.10 seconds
%	Sequence of mot. Comps: {k, kk)
% �	Contact
%	Def: Occurs when the male part hits the back wall of the female part 
%	Conditions: any action, except for an unstable one, followed by a
%               contact, or pc/nc,nc/pc followed by any action except an unstable action. 
%	Sequence of mot. Comps: { *c*)
% �	Pushing
%	Def: Occurs when a part moves along the negative direction of motion.
%	If single occurrence, duration must be greater than 0.1 secs or otherwise it will be considered noise.
%	Conditions: action is produced by one or more decrement actions and a total minimum 
%   of time 0.25 seconds. 
%	Sequence of mot. Comps: {d,dd).
% �	Pulling
%	Def: Occurs when a part moves along the positive direction of motion.
%	If single occurrence, duration must be greater than 0.1 secs or otherwise it will be considered noise.
%	Conditions: action is produced by one or more increment actions and a total minimum 
%   of time 0.25 seconds. 
%	Sequence of mot. Comps: {i,ii).
% �	Aligning
%	Def: Occurs when contiguous adjustments have smaller amplitudes.If
%	single occurrence, duration must be greater than 0.1 secs or otherwise it will be considered noise.
%	Conditions: action is produced by increasingly smaller adjustments. 
%	Sequence of mot. Comps: {aa).
% �	Shift
%	Def: Occurs when contiguous adjustments increase in value indicated
%	small alignments over time. If single occurrence, duration must be greater than 0.1 secs or otherwise it will be considered noise.
%	Conditions: action is produced by increasingly smaller adjustments and a total minimum of time 
%   0.25 seconds. 
%	Sequence of mot. Comps: {u,uu).
% �	Noise
%	If any of the previous ones cannot be recognized.
%
% Input Parameters:
% index:        - currend for loop index iterating through data
% labelType:    - label for the kind of motion composition that it is
% motComps:     - motion composition cell array data structure. mx11.
% timeCheckFlag:- a flag that indicates whether the first composition has a
%                 duration greather than the time threshold. Used for
%                 conditions that look for repeated signals: kk,ii,dd
% windowSZ:     - the size of the window to study if there is a match for
%                 the second composition. IF 0, we will examine the next
%                 element only. If one, we will examine the next two
%                 elements. 
% 
% Output Parameters:
% llbehStruc:   - the 1x17 cell array low-level beh struc 
% index:        - the index that is traversing the motion compositions 
% llbehLbl:     - label structure to be used by the hlbehComposition function
%**************************************************************************
function [llbehStruc index llbehLbl] = motCompsMatchEval(index,labelType,motComps,timeCheckFlag,windowSZ)

%% Initialization
   
    r = size(motComps);         % Size of motion compositions
%    DURATION_THRESHOLD = 0.10;  % Duration in seconds. Necessary condition to label low-level behavior

%%  Motion Composition Labels
    % Labels for actions in motion compositions
    adjustment      = 1;    % a
    increase        = 2;    % i
    decrease        = 3;    % d
    constant        = 4;    % k
    pos_contact     = 5;    % pc
    neg_contact     = 6;    % nc
    contact         = 7;    % c
    unstable        = 8;    % u
    noisy           = 9;    % n
    none            = 10;    % z
   %actionLbl       = {'a','i','d','k','pc','nc','c','u','n','z');  % String representation of each possibility in the actnClass set.                 
    actionLbl       = [ 1,  2,  3,  4,  5,   6,   7,  8,  9,  10];  % Updated July 2012. Represent the actionLbl's directly by integers. Facilitates conversion into C++
%% Motion Composition Structure indeces
    aLbl    = 1;  
    avgVal  = 2;
    rmsVal  = 3;
    ampVal  = 4;
    t1S     = 7;  
    t1E     = 8;
    t2S     = 9;  
    t2E     = 10; 
    tAvg    = 11;
    
%%  Labels for low-level behaviors
	FIX     = 1;        % Fixed in place
    CONTACT = 2;        % Contact
    PUSH    = 3;        % Push
    PULL    = 4;        % Pull
    ALIGN   = 5;        % Alignment
    SHIFT   = 6;        % Shift
    UNSTABLE= 7;        % Unstable
    NOISE   = 8;        % Noise
   %llbehLbl   = {'FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N');   % {'fix' 'cont' 'push' 'pull' 'align' 'shift' 'unstable' 'noise');
   llbehLbl    = [ 1,   2,   3,   4,   5,   6,   7,  8];
   %llbehStruc = {[] [] [] [] [] [] [] [] [] [] []);        %[llbehLbl avgVal rmsVal amplitudeVal mc1Lbl mc2Lbl t1Start t1End t2Start t2End tAvgIndex]    
   llbehStruc  = zeros(1,11);                               % Updated July 2012 to facilitate the conversion to C++.

%% Other Param Initialization
    mc1     = actionLbl(none);
    mc2     =mc1;
    llBehClass = llbehLbl(NOISE);
   
%% Window Parameters

    % Set the range by looking at a window after the index
    window              = windowSZ;                        
    
    % Look for patterns within motion compositions
    if(index+window<r(1))
        nextIndex       = index+1;                  % Index indicating start of window range after first composition found
        Range           = nextIndex+window;         % Index indicating last element of window range        
    
    % This is one before the last iteration
    elseif(index+window<r(1)+window)                   
        nextIndex       = index+1;
        Range           = nextIndex+(r(1)-index-1);    % This equation appropriately sets the val of Range independent of window size
    
    % Last iteration
    elseif(index+window==r(1)+window)                  
        nextIndex       = index;
        Range           = index;
        
    % If indeces are exceeded    
    else                                            
        % Return empty motComps of length (1,11)
        %llbehStruc={[],[],[],[],[],[],[],[],[],[],[]);
        llbehStruc(:) = 0;                              % Updated July 2012.
        index = r(1)+1;        
        return;     % maximum index has been passed. do nothing and return 
    end

%%  MATCHES
% Match labels passed by calling function. motComps(m,[actionLbl,avgVal,rmsVal,amplitudeVal,p1Lbl,p2Lbl,t1Start,t1End,t2Start,t2End,tAvgIndex]

%% CONSTANT LABELS - Determine FIX
    if( intcmp(labelType, actionLbl(constant)) )
        for match=nextIndex:Range         % Examine the window range            
            
%%          FIRST COMPOSITE IS LONG
            % IF pair, then merge both
            % IF no, then assign only original index
            if(timeCheckFlag)
          
                %% CONSTANT FOLLOWED BY CONSTANT
                if( intcmp(motComps(match,aLbl), labelType) )

                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(FIX);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = motComps(match,aLbl);

                    break;

                % Assign original index
                else
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(FIX);

                    % Set the second composition label as none. 
                    mc1 = motComps(index,aLbl);
                    mc2 = actionLbl(none);
                end

%%          THE FIRST ONE IS NOT LONG. IS THERE A PAIR THAT WE CAN MERGE?
            else
                %% CONSTANT FOLLOWED BY CONSTANT
                if(intcmp(motComps(match,aLbl), labelType))

                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(FIX);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = motComps(match,aLbl);

                    break;
                    
                % We could not find a pair. Render noisy. 
                else
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(NOISE);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = actionLbl(none); 

                    break;
                end
            end
        end
%% CONTACT LABELS - Determine CONTACT
    elseif(intcmp(labelType,actionLbl(contact)))
        for match=nextIndex:Range         % Examine the window range            
%%          CONTACT FOLLOWED BY CONTACT
            if(intcmp(motComps(match,aLbl), labelType))
                                   
                % Set the type of the low-level behavior
                llBehClass = llbehLbl(CONTACT);

                % Set motion composition labels
                mc1 = motComps(index,aLbl);
                mc2 = motComps(match,aLbl);

                break;                
%%          PC FOLLOWED BY NC
            elseif(intcmp(motComps(index,aLbl),actionLbl(pos_contact)) && intcmp(motComps(match,aLbl),actionLbl(neg_contact)))
                                   
                % Set the type of the low-level behavior
                llBehClass = llbehLbl(CONTACT);

                % Set motion composition labels
                mc1 = motComps(index,aLbl);
                mc2 = motComps(match,aLbl);

                break;                
%%          NC FOLLOWED BY PC
            elseif(intcmp(motComps(index,aLbl),actionLbl(neg_contact)) && intcmp(motComps(match,aLbl),actionLbl(pos_contact)))
                
                % Set the type of the low-level behavior
                llBehClass = llbehLbl(CONTACT);

                % Set motion composition labels
                mc1 = motComps(index,aLbl);
                mc2 = motComps(match,aLbl);      
                
                break;
                
%%          Single contact. Still consider as contact. (should depend on state) 
            else
                % Set the type of the low-level behavior
                llBehClass = llbehLbl(CONTACT);

                % Set motion composition labels
                mc1 = motComps(index,aLbl);
                mc2 = actionLbl(none);                
            end
        end

%% DECREASE LABELS - Determine PUSH
    elseif(intcmp(labelType,actionLbl(decrease)))        
        for match=nextIndex:Range         % Examine the window range            

%%          FIRST COMPOSITE IS LONG
            % IF pair, then merge both
            % IF no, then assign only original index
            if(timeCheckFlag)
                
                %% DECREASE FOLLOWED BY DECREASE
                if(intcmp(motComps(match,aLbl), labelType))
                                    
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(PUSH);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = motComps(match,aLbl);
                    
                    break;
                    
                % No match assign the original one
                else
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(PUSH);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = actionLbl(none);    
                    
                    break;
                end
%%          THE FIRST ONE IS NOT LONG. IS THERE A PAIR THAT WE CAN MERGE?        
            else
                %% DECREASE FOLLOWED BY DECREASE
                if(intcmp(motComps(match,aLbl), labelType))
                                    
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(PUSH);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = motComps(match,aLbl);
                    
                    break;
                    
                % We could not find a pair. Render noisy. 
                else
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(NOISE);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = actionLbl(none); 

                    break;
                end
            end
        end
        
%% INCREASE LABELS - Determine PULL
    elseif(intcmp(labelType,actionLbl(increase))) 
        for match=nextIndex:Range         % Examine the window range            

%%          FIRST COMPOSITE IS LONG
            % IF pair, then merge both
            % IF no, then assign only original index
            if(timeCheckFlag)
                
                %% DECREASE FOLLOWED BY DECREASE
                if(intcmp(motComps(match,aLbl), labelType))
                                    
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(PULL);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = motComps(match,aLbl);
                    
                    break;
                
                % No match assign the original one
                else
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(PULL);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = actionLbl(none);    
                    
                    break;
                end
%%          THE FIRST ONE IS NOT LONG. IS THERE A PAIR THAT WE CAN MERGE?        
            else
                %% DECREASE FOLLOWED BY DECREASE
                if(intcmp(motComps(match,aLbl), labelType))
                                    
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(PULL);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = motComps(match,aLbl);
                    
                    break;
                    
                % We could not find a pair. Render noisy. 
                else
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(NOISE);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = actionLbl(none); 

                    break;
                end
            end
        end
%% ADJUSTMENT LABELS - Determine ALIGNMENT
    elseif(intcmp(labelType,actionLbl(adjustment))) 
        
        alignmentFlag = false;
        
        % Check duration of intermediate point
        if(motComps(index,t2E)-motComps(index,t1S)>0.1)
            Range = nextIndex;
        end
        for match=nextIndex:Range                       % Examine the window range            
            
            
            
%%          ADJUSTMENT FOLLOWED BY SMALLER ADJUSTMENT
            % Otherwise, single adjustment
            if(intcmp(motComps(match,aLbl), labelType))                
                
                % If the second amplitude value is smaller proceed
                % Otherwise we have an shift signal
                if(motComps(match,ampVal) < motComps(index,ampVal))                                        
                                            
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(ALIGN);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = motComps(match,aLbl);

                    % Set alignment flag to true
                    alignmentFlag = true;

                    break;           

%%                  Adjustments are growing shifting
                else
                    % Set the type of the low-level behavior
                    llBehClass = llbehLbl(SHIFT);

                    % Set motion composition labels
                    mc1 = motComps(index,aLbl);
                    mc2 = motComps(match,aLbl);

                    % Set alignment flag to true
                    alignmentFlag = true;
                    break;                                                             
                end     % End amplitude measurement
            end         % End Adjustment Label
        end             % End for loop
        
%%      ISOLATED ALIGNMNENT.
        if(alignmentFlag==0)
            % If long alignment, still consider as ALIGN. Otherwise noisy.
            if(timeCheckFlag)
                llBehClass = llbehLbl(ALIGN);

                % Set motion composition labels
                mc1 = motComps(index,aLbl);
                mc2 = actionLbl(none);                       
            else
                llBehClass = llbehLbl(NOISE);

                % Set motion composition labels
                mc1 = motComps(index,aLbl);
                mc2 = actionLbl(none);       
            end
        end
        
%% UNSTABLE LABELS - Determine UNSTABLE
    elseif(intcmp(labelType,actionLbl(unstable)))         
        for match=nextIndex:Range         % Examine the window range            
%%          UNSTABLE FOLLOWED BY UNSTABLE
            if(intcmp(motComps(match,aLbl), labelType))
                                   
                % Set the type of the low-level behavior
                llBehClass = llbehLbl(UNSTABLE);

                % Set motion composition labels
                mc1 = motComps(index,aLbl);
                mc2 = motComps(match,aLbl);

                break;
                    
           % Single Unstable element
            else
                % Set the type of the low-level behavior
                llBehClass = llbehLbl(UNSTABLE);

                % Set motion composition labels
                mc1 = motComps(index,aLbl);
                mc2 = actionLbl(none);           
                
                break;
            end
        end         
%% NOISY LABELS - Determine NOISE
    else
        match = nextIndex;
                        
        % Set the type of the low-level behavior
        llBehClass = llbehLbl(NOISE);

        % Set motion composition labels
        mc1 = motComps(index,aLbl);
        mc2 = actionLbl(noisy);                    
    end
    
%% Compute values, time indeces, and return the llbehStruc structure    
    
    % For compositions with a match 
    if(~intcmp(mc2,actionLbl(none)) && ~intcmp(mc2,actionLbl(noisy)) )
        % Average magnitude values
        avgMagVal1  = motComps(index,avgVal);
        avgMagVal2  = motComps(match,avgVal);
        AVG_MAG_VAL = (avgMagVal1+avgMagVal2)/2;   

        % Root mean square
        rmsVal1 = motComps(index,rmsVal);
        rmsVal2 = motComps(match,rmsVal);
        AVG_RMS_VAL = sqrt(rmsVal1^2 + rmsVal2^2)/2;

        % Amplitude value 
        amplitudeVal1 = motComps(index,ampVal);
        amplitudeVal2 = motComps(match,ampVal);
        AVG_AMP_VAL = (amplitudeVal1+amplitudeVal2)/2;       

        % Compute time indeces
        t1Start = motComps(index,t1S);              % Starting time of first  part for composition 1
        t1End   = motComps(index,t2E);              % Ending   time of second part for composition 1

        % Indeces Check: ensure no array is exceeded by the index
        if(match+1<r(1))                            
            t2Start = motComps(match,t1S);          % Starting time of first  part for composition 2
            t2End   = motComps(match,t2E);          % Ending   time of second part for composition 2
        else
            t2Start = motComps(match,t1S);          % Starting time for composition 2
            t2End   = motComps(match,t2E);          % We are in the last element
        end

        tAvgIndex   = (motComps(index,tAvg)+motComps(match,tAvg))/2;

        % Enter the following data into the llbehStruc structure:
        llbehStruc=[llBehClass,...         % type of low-level behavior: "fixed","contact","push","pull","aligned","unstable","noisy"
                    avgMagVal1,...         % Magnitude of data (average value). Needs to be averaged when second match is found
                    avgMagVal2,...         % avgMagVal 2
                    AVG_MAG_VAL,...        % their average 
                    rmsVal1,...            % Root mean square value 1
                    rmsVal2,...            % rms value 2
                    AVG_RMS_VAL,...        % their average
                    amplitudeVal1,...      % Largest difference from one edge to the other              
                    amplitudeVal2,...      % the second
                    AVG_AMP_VAL,...        % their average
                    mc1,...                % Adjustment, increase, decrease, constant, contact, pos contact, neg contact, unstable
                    mc2,...                % [a,i,d,k,c,pc,nc,u]
                    t1Start,...            % time at which first composition starts
                    t1End,...              % time at which first composition ends
                    t2Start,...            % time at which second composition starts
                    t2End,...              % time at which second composition ends
                    tAvgIndex              % Avg time of both compositions
                    ];                     % [llBehClass,avgMagVal,rmsVal,mC1,mC2,t1Start,t1End,t2Start,t2End,tAvgIndex]

        % Update index
        index = match+1;  
    
%%  Behaviors with only one composition. The second composition (both parts are not to be considered) 
    else 
        % Average magnitude value 
        avgMagVal = motComps(index,avgVal);

        % Root mean square
        rmsVal = avgMagVal;

        % Amplitude value 
        amplitudeVal = motComps(index,ampVal);

        % Compute time indeces
        t1Start = motComps(index,t1S);          % Starting time for first  part for composition 1        
        t1End   = motComps(index,t1E);          % Ending   time for second part for composition 1.
        
        t2Start = motComps(index,t2S);          % Starting time of first part for composition 2
        t2End   = motComps(index,t2E);          % Ending   time of first part for composition 2
%         else
%             t2Start = motComps(index,t1S);      % Starting time for composition 1
%             t2End   = motComps(index,t1E);      % Ending   time of second part for composition 1.            
%         end
        tAvgIndex   = (t1Start+t2End)/2;

        % Enter the following data into the llbehStruc structure:
        llbehStruc=[llBehClass,...         % type of low-level behavior: "fixed","contact","push","pull","aligned","unstable","noisy"
                    avgMagVal,...          % Magnitude of data (average value). Needs to be averaged when second match is found
                    avgMagVal,...          % Repeat
                    avgMagVal,...          % Repeat
                    rmsVal,...             % Root mean square value 1
                    rmsVal,...             % Repeat
                    rmsVal,...             % Repeat
                    amplitudeVal,...       % Largest difference from one edge to the other              
                    amplitudeVal,...       % Repeat
                    amplitudeVal,...       % Repeat
                    mc1,...                % Adjustment, increase, decrease, constant, contact, pos contact, neg contact, unstable
                    mc2,...                % [a,i,d,k,c,pc,nc,u]
                    t1Start,...            % time at which first composition starts
                    t1End,...              % time at which first composition ends
                    t2Start,...            % time at which second composition starts
                    t2End,...              % time at which second composition ends
                    tAvgIndex              % Avg time of both compositions
                    ];                     % [llBehClass,avgMagVal,rmsVal,mC1,mC2,t1Start,t1End,t2Start,t2End,tAvgIndex]

        % Update index to the next index. 
        index = nextIndex;                
    end
end