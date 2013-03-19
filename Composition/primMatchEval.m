%%************************ Documentation **********************************
% After finding any of the 8 labels: bpos,mpos,spos,bneg,mneg,snet,const,impulse
% Determine if the index+window range has one of following outcomes, and
% assign an appropriate action to the combination:
%   Positive
%       Neg:    adjustment, 'a'
%       Pos:    increase,   'i'
%       Const:  increase,   'i'
%       Pimp:   pos contact,'pc'
%       Nimp:   neg contact,'nc'
%
%   Negative
%       Pos:    adjustment, 'a'
%       Neg:    decrease,   'd'
%       Const:  decrease,   'd'
%       Pimp:   pos contact,'pc'
%       Nimp:   neg contact,'nc'
%
%   Constant
%       Pos:    increase,   'i'
%       Neg:    decrease,   'd'
%       Const:  constant,   'k'
%       Pimp:   pos contact,'pc'
%       Nimp:   neg contact,'nc'
%
%   Pimp
%       Pos:    pos contact,'pc'
%       Neg:    pos contact,'pc'
%       Const:  pos contact,'pc'
%       pimp:   unstable,   'u'
%       Nimp:   contact,    'c'
%
%   Nimp
%       Pos:    neg contact,'nc'
%       Neg:    neg contact,'nc'
%       Const:  neg contact,'nc'
%       Pimp:   contact,    'c'
%       Nimp:   unstable,   'u'
%
% Input Parameters:     
%
% index:                    - indicates what primitive segment we are on
% labelType:                - string describing whether 'positive','negative,'constant','impulse'
% szLabel:                  - CELL string array. Indicates whether prim is b/m/s/pos/net/const/impulse/
%
% motComps(motCompsIndex)   - a 1x11 dimensional struc to hold composite primitives info
%                           - [actnClass,avgMagVal,rmsVal,glabel1,glabel2,t1Start,t1End,t2Start,t2End,tAvgIndex]
%                           - defined in CompoundMotionComposition.m
%                           - Usually extract values from:
%                             statData[avg,max,min,start_time,finish_time,gradient,gradientlbl]. 
%
% gradLabels                - gradient label classification structure,
%                             originally defined in fitRegressionCurves.m 
%                             Using the same struc throught all the m files
%                             helps to insure there is consistency across
%                             function calls
%**************************************************************************
function [motComps index actionLbl]=primMatchEval(index,labelType,lbl,statData,gradLabels)
    
%% Initialization    
    
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
    
%%  DEFINE ACTION CLASS    
    % Int Aaray used to describe the kind of action (a=adjustment, i=increase, d=decrease, c=constant).
    actnClass       = -1;
    
    % These variables are used for indexing actnClassLbl. 
    adjustment      = 1;    % a
    increase        = 2;    % i
    decrease        = 3;    % d
    constant        = 4;    % k
    pos_contact     = 5;    % pc
    neg_contact     = 6;    % nc
    contact         = 7;    % c
    unstable        = 8;    % u
%   actionLbl       = ['a';'i';'d';'k';'p';'n';'c';'u'];  % String representation of each possibility in the actnClass set.                 
    actionLbl       = [1,2,3,4,5,6,7,8];                  % This array has been updated to be an int vector
    
%% Initialize other statistical parameters
    amplitudeVal = -1;
    glabel1      = -1;
    glabel2      = -1;
    
%%  Window Parameters

    [r c]           = size(statData);               % rows and columns of statData
    
    % Set the range by looking at a window after the index
    window              = 1;                        % Look for pattern within this window of primitive motion segments segments
    if(index+window<r)
        nextIndex       = index+1;                  % Index indicating start of window range after first primitive found
        Range           = nextIndex+window;         % Index indicating last element of window range        
    elseif(index+window<r+window)                   % This is one before the last iteration
        nextIndex       = index+1;
        Range           = nextIndex+(r-index-1);    % This equation appropriately sets the val of Range independent of window size
    elseif(index+window==r+window)                  % This is the last iteration
        nextIndex       = index;
        Range           = index;
    else                                            % This is when the indeces have been exceeded
        % Return empty info
        motComps=[0,0,0,0,0,0,0,0,0,0,0];
        index = r+1;        
        return;     % maximum index has been passed. do nothing and return 
    end
    
    %Match           = false;                      % If no match look again. 
%%  MATCHES
    % statData(m,[Avg,Max,Min,Start,Finish,gradient,label]) 
    % Pending.... For now, we will only look for direct connections:
    % i.e. bpos and bneg. Not for bpos/mneg, bpos/sneg

%% POSITIVE LABELS
    if(strcmp(labelType,'positive'))

        % Examine the window range
        for match=nextIndex:Range            

%%          POSITIVE LABEL folled by NEGATIVE LABEL = MATCH = ALIGNMENT
            if(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BNEG,:)) || ...     %bneg
                    strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MNEG,:)) || ...%mneg
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SNEG,:)))  %sneg. match is the index that looks ahead.                                                                 
                    
                % Set the type of the second label
                if(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BNEG,:)));     lbl2=BNEG;
                elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MNEG,:))); lbl2=MNEG;
                else                                                 lbl2=SNEG;
                end
                
                % Class: adjustment
                actnClass = actionLbl(adjustment);

                % amplitudeVal: maxp1,minp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','neg',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));
                glabel2 = gradLbl2gradInt(gradLabels(lbl2,:));    
                
                break;

%%          POSITIVE LABEL follwed by POSITIVE LABEL = REPEAT = INCREASE
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BPOS,:)) || ...     % bpos
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MPOS,:)) || ...% mpos
                            strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SPOS,:)))  % spos. match is the index that looks ahead. 

                % Set the type of the second label
                if(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BPOS,:)));     lbl2=BPOS;
                elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MPOS,:))); lbl2=MPOS;
                else                                                 lbl2=SPOS;
                end                        
                        
                % actnClass: increase
                actnClass = actionLbl(increase);     % Increase

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','pos',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));     % Positive
                glabel2 = gradLbl2gradInt(gradLabels(lbl2,:));    % Positive

                break;
%%          POSITIVE LABEL followed by CONSTANT LABEL = INCREASE
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif( strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(CONST,:)) )  % match is the index that looks ahead. 

                % Increase
                actnClass = actionLbl(increase);                 

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','const',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));              % Positive
                glabel2 = gradLbl2gradInt(gradLabels(CONST,:));            % Constant

                break;
                  
%%          POSITIVE LABEL followed by PIMP = POS_CONTACT
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif( strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(PIMP,:)) )     % match is the index that looks ahead. 

                % Contact
                actnClass = actionLbl(pos_contact);              

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','pos',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));             % Positive
                glabel2 = gradLbl2gradInt(gradLabels(PIMP,:));            % Pimp

                break;
                
%%          POSITIVE LABEL followed by NIMP = NEG_CONTACT
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif( strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(NIMP,:)) )  % match is the index that looks ahead. 
                
                % Contact
                actnClass = actionLbl(neg_contact);           

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','neg',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));             % Positive
                glabel2 = gradLbl2gradInt(gradLabels(NIMP,:));            % Nimp
                    
                break;
                
%%          Pure Increase
            else
                actnClass       = actionLbl(increase);                                      % increase
                amplitudeVal    = statData(index,2)-statData(index,3);                      % max-min
                glabel1         = gradLbl2gradInt(gradLabels(lbl,:));                       % positive
                glabel2         = gradLbl2gradInt(gradLabels(lbl,:));                       % positive
                
                break;
                
            end % End combinations
        end     % End match

%% IF NEGATIVE
    elseif(strcmp(labelType,'negative'))
        
        % Examine the window range
        for match=nextIndex:Range            

%%          NEGATIVE LABEL followed by POSITIVE LABELS = MATCH = ALIGNMENT
            if(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BPOS,:)) || ...     %bpos
                    strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MPOS,:)) || ...%mpos
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SPOS,:)) )  %spos.match is the index that looks ahead.                                                                 
                
                % Set the type of the second label
                if(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BPOS,:)));     lbl2=BPOS;
                elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MPOS,:))); lbl2=MPOS;
                else                                                 lbl2=SPOS;
                end
                
                % Class
                actnClass = actionLbl(adjustment);                            % Alignment

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','pos',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));
                glabel2 = gradLbl2gradInt(gradLabels(lbl2,:)); 
                            
                break;

%%          NEGATIVE LABEL followed by NEGATIVE LABELS = REPEAT = DECREASE
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BNEG,:)) || ...
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MNEG,:)) || ...
                            strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SNEG,:)))  % match is the index that looks ahead. 
                        
                % Set the type of the second label
                if( strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BNEG,:)) );     lbl2=BNEG;
                elseif( strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MNEG,:)) ); lbl2=MNEG;
                else                                                 lbl2=SNEG;
                end
                
                actnClass = actionLbl(decrease);    % Decrease

                % amplitudeVal: maxp1,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','neg',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));     % Negative
                glabel2 = gradLbl2gradInt(gradLabels(lbl2,:));    % Negative

                break;
                
%%          NEGATIVE LABEL followed by CONSTANT LABEL = DECREASE
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(CONST,:)))        % match is the index that looks ahead. 
                
                % Decrease
                actnClass = actionLbl(decrease);                 

                % amplitudeVal: minp1,maxp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','const',p1,p2);                   

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));              % Negative
                glabel2 = gradLbl2gradInt(gradLabels(CONST,:));            % Constant
                    
                break;                
 
%%          NEGATIVE LABEL followed by PIMP = POS_CONTACT
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(PIMP,:)))  % match is the index that looks ahead. 

                % Class: contact
                actnClass = actionLbl(pos_contact);                % pos_contact               

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','pos',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));             % Negative
                glabel2 = gradLbl2gradInt(gradLabels(PIMP,:));            % Pimp
                
                break;
                
%%          NEGATIVE LABEL followed by NIMP = NEG_CONTACT
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(NIMP,:)))  % match is the index that looks ahead. 

                actnClass = actionLbl(neg_contact);                % neg_contact               

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','neg',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));             % Positive
                glabel2 = gradLbl2gradInt(gradLabels(NIMP,:));            % Nimp

                break;                                
                
%%          NONE
            else
                actnClass   = actionLbl(decrease);                                      % pure decrease
                amplitudeVal    = statData(index,2)-statData(index,3);  % max-min
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));                              % NEG
                glabel2 = gradLbl2gradInt(gradLabels(lbl,:));                              % NEG
                
            end % End combinations
        end     % End match
        
%% IF CONSTANT: only looks at the next index
    elseif(strcmp(labelType,'constant'))
        
        % Examine the nextIndex only but check for index limits
        if(nextIndex==Range)
            lastIndex = nextIndex;
        else
            lastIndex = nextIndex+1;
        end
        for match=nextIndex:lastIndex           

%%          CONSTANT WITH INCREASE
            if(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BPOS,:)) || ...
                    strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MPOS,:)) || ...
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SPOS,:)))            % CONSTANT + POSITIVE
                                   
                    % Class
                    actnClass = actionLbl(increase);                               % Increase

                    % amplitudeVal: minp1,maxp2
                    % Max and min values of first and second primitives
                    p1max = statData(index,2); p1min = statData(index,3);
                    p2max = statData(match,2); p2min = statData(match,3); 
                    p1 = [p1max p1min]; p2 = [p2max p2min];                
                    amplitudeVal = computedAmplitude('const','pos',p1,p2);

                    % Gradient labels
                    glabel1 = gradLbl2gradInt(gradLabels(CONST,:));
                    glabel2 = gradLbl2gradInt(gradLabels(MPOS,:));                           % Positive. Have not refined the exact dimension here.
                
                break;

%%          CONSTANT WITH DECREASE
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BNEG,:)) || ...
                    strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MNEG,:)) || ...
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SNEG,:)))        % CONSTANT + NEGATIVE
               
                % Class: decrease
                actnClass = actionLbl(decrease);                             % Decrease

                % amplitudeVal: maxp1,minp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('const','neg',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(CONST,:));                    % Constant
                glabel2 = gradLbl2gradInt(gradLabels(MNEG,:));                     % Negative. % Have not refined the exact dimension here
                
                break;
                
%%          CONSTANT WITH CONSTANT
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(CONST,:)))  % match is the index that looks ahead. 
              
                % Class
                actnClass = actionLbl(constant);                   % CONSTANT

                % amplitudeVal: maxp1 - minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('const','const',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(CONST,:));                       % Constant
                glabel2 = gradLbl2gradInt(gradLabels(CONST,:));                       % Constant. % Have not refined the exact dimension here
                
                break;           

%%          CONSTANT LABEL followed by PIMP = POS_CONTACT
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(PIMP,:)))  % match is the index that looks ahead. 

                % Contact
                actnClass = actionLbl(pos_contact);       % pos_contact                            

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('const','pos',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));             % Constant
                glabel2 = gradLbl2gradInt(gradLabels(PIMP,:));            % Pimp

                break;
                
%%          CONSTANT LABEL followed by NIMP = NEG_CONTACT
            %  Need a flag to see if we get constant repeat or a single
            %  case for the length of the window
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(NIMP,:)))  % match is the index that looks ahead. 

                % Contact
                actnClass = actionLbl(neg_contact);                % neg_contact               

                % amplitudeVal: maxp2,minp1
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('const','neg',p1,p2);

                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(lbl,:));             % Constant
                glabel2 = gradLbl2gradInt(gradLabels(NIMP,:));            % Nimp
                    
                    break;                                
                
%%          PURE CONSTANT
            else
                actnClass       = actionLbl(constant);                           % constant
                amplitudeVal    = 0;
                glabel1         = gradLbl2gradInt(gradLabels(lbl,:));             % constant
                glabel2         = gradLbl2gradInt(gradLabels(lbl,:));             % constant
                
                break;

            end % End combinations
        end     % End match

%% IF PIMP: only looks at the next index
    elseif(strcmp(labelType,'pimp'))    

        % Examine the window range        % Examine the nextIndex only
        if(nextIndex==Range)
            lastIndex = nextIndex;
        else
            lastIndex = nextIndex+1;
        end
        for match=nextIndex:lastIndex          

%%          Positive impulse with positive = POS_CONTACT
            if(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BPOS,:)) || ...
                    strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MPOS,:)) || ...
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SPOS,:)) || ...
                            strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(PIMP,:)))  	% PIMP + POSITIVE
                                                                    
                % Class
                actnClass = actionLbl(pos_contact);                           % pos_contact

                % amplitudeVal: minp1,maxp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','pos',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(PIMP,:));                               % Impulse
                glabel2 = gradLbl2gradInt(gradLabels(MPOS,:));                               % Increase. Have not refined the exact dimension here.
                
                break;

%%          IF POSITIVE IMPULSE (PIMP) WITH NEG GRADIENT = POS_CONTACT
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BNEG,:)) || ...
                    strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MNEG,:)) || ...
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SNEG,:)))        % IMPULSE + NEGATIVE
               
                % Class
                actnClass = actionLbl(pos_contact);                       % pos_contact
                
                % amplitudeVal: maxp1,minp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','neg',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(PIMP,:));                             % POSITIVE IMPULSE
                glabel2 = gradLbl2gradInt(gradLabels(MNEG,:));                             % Decrease. % Have not refined the exact dimension here
                
                break;
                
                
%%          POSITIVE IMPULSE (PIMP) WITH CONSTANT = POS_CONTACT
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(CONST,:)))  % match is the index that looks ahead. 
              
                % Class
                actnClass = actionLbl(pos_contact);             % pos_contact

                % amplitudeVal: maxp1,minp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','const',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(PIMP,:));                 % Pimp
                glabel2 = gradLbl2gradInt(gradLabels(CONST,:));                % Constant
                
                break;
            
%%          POSITIVE IMPUSLE (PIMP) WITH PIMP = UNSTABLE
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(PIMP,:)))  % match is the index that looks ahead. 
                
                % Class
                actnClass = actionLbl(unstable);               % unstable

                % amplitudeVal: minp1,maxp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','pos',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(PIMP,:));     % impulse
                glabel2 = gradLbl2gradInt(gradLabels(PIMP,:));     % impulse
                
                break;
                
%%          PIMP WITH NIMP = CONTACT
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(NIMP,:)))  % match is the index that looks ahead. 
                
                % Class
                actnClass = actionLbl(contact);                % contact

                % amplitudeVal: minp1,maxp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('pos','neg',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(PIMP,:));     % impulse
                glabel2 = gradLbl2gradInt(gradLabels(NIMP,:));     % impulse
                
                break;

%%          NONE
            else
                actnClass       = actionLbl(pos_contact) ;                                  % contact
                amplitudeVal    = statData(index,2)-statData(index,3);  % max-min
                glabel1         = gradLbl2gradInt(gradLabels(lbl,:));                      % constant
                glabel2         = gradLbl2gradInt(gradLabels(lbl,:));                      % none
                
                break;

            end % End combinations
        end     % End match
        
        
%% IF NIMP: only looks at the next index
    elseif(strcmp(labelType,'nimp'))    

        % Examine the window range
        % Examine the nextIndex only
        if(nextIndex==Range)
            lastIndex = nextIndex;
        else
            lastIndex = nextIndex+1;
        end
        for match=nextIndex:lastIndex            

%%          NEGATIVE IMPULSE (NIMP) WITH POSITIVE = NEG_CONTACT
            if(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BPOS,:)) || ...
                    strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MPOS,:)) || ...
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SPOS,:)))  	% NIMP + pos
                                                                    
                % Class
                actnClass = actionLbl(neg_contact);                   % neg_contact

                % amplitudeVal: minp1,maxp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','pos',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(NIMP,:));                               % Neg. Impulse
                glabel2 = gradLbl2gradInt(gradLabels(MPOS,:));                               % Increase. Have not refined the exact dimension here.
                
                break;

%%          IF NEGATIVE IMPULSE (NIMP) WITH NEG GRADIENT = NEG_CONTACT
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(BNEG,:)) || ...
                    strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(MNEG,:)) || ...
                        strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(SNEG,:)))        % NIMP + NEGATIVE
               
                % Class
                actnClass = actionLbl(neg_contact);                       % neg_contact
                
                % amplitudeVal: maxp1,minp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','neg',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(NIMP,:));                             % NEGATIVE IMPULSE
                glabel2 = gradLbl2gradInt(gradLabels(MNEG,:));                             % Decrease. % Have not refined the exact dimension here
                
                break;
                
                
%%          NEGATIVE IMPULSE (NIMP) WITH CONSTANT = NEG_CONTACT
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(CONST,:)))  % match is the index that looks ahead. 
              
                % Class
                actnClass = actionLbl(neg_contact);             % neg_contact

                % amplitudeVal: maxp1,minp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','const',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(NIMP,:));                 % Pimp
                glabel2 = gradLbl2gradInt(gradLabels(CONST,:));                % Constant
                
                break;
            
%%          NEGATIVE IMPULSE (NIMP) WITH PIMP = CONTACT
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(PIMP,:)))  % match is the index that looks ahead. 
                
                % Class
                actnClass = actionLbl(contact);                % CONTACT

                % amplitudeVal: minp1,maxp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','pos',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(NIMP,:));     % impulse
                glabel2 = gradLbl2gradInt(gradLabels(PIMP,:));     % impulse
                
                break;

%%          NEGATIVE IMPULSE (NIMP)  WITH NIMP = UNSTABLE
            elseif(strcmp(gradInt2gradLbl(statData(match,7)), gradLabels(NIMP,:)))  % match is the index that looks ahead. 
                
                % Class
                actnClass = actionLbl(unstable);                % unstable

                % amplitudeVal: minp1,maxp2
                % Max and min values of first and second primitives
                p1max = statData(index,2); p1min = statData(index,3);
                p2max = statData(match,2); p2min = statData(match,3); 
                p1 = [p1max p1min]; p2 = [p2max p2min];                
                amplitudeVal = computedAmplitude('neg','neg',p1,p2);
                
                % Gradient labels
                glabel1 = gradLbl2gradInt(gradLabels(NIMP,:));     % neg impulse
                glabel2 = gradLbl2gradInt(gradLabels(NIMP,:));     % neg impulse
                
                break;                
%%          NONE
            else
                actnClass       = actionLbl(neg_contact);                                   % neg_contact
                amplitudeVal    = statData(index,2)-statData(index,3);  % max-min
                glabel1         = gradLbl2gradInt(gradLabels(lbl,:));                       % constant
                glabel2         = gradLbl2gradInt(gradLabels(lbl,:));                       % none
                
                break;

            end % End combinations
        end     % End match        
    end         % IF positive/negative/constant/impulse

%% Compute values, time indeces, and return the motComps structure    
    % Average magnitude value 
    avgMagVal = (statData(index,1)+statData(match,1))/2;   

    % Root mean square
    rmsVal = sqrt((statData(index,1)^2 + statData(match,1)^2)/2);

    % Compute time indeces
    t1Start = statData(index,4);            % Starting time for primitive 1
    t1End   = statData(index,5);%-0.001;      % Ending time for primitive 1

    % Indeces Check: ensure no array is exceeded by the index
    if(match+1<r)                            
        t2Start = statData(match,4);         % Starting time for primitive 2
        t2End   = statData(match,5);%-0.001;   % Ending time for primitive 2.  Previous code: statData(match+1,5)-0.001;
    else
        t2Start = statData(match,4);         % Starting time for primitive 2
        t2End   = statData(match,5);         % We are in the last element
    end
    
    tAvgIndex = (t1Start+t2End)/2;

    % Enter the following data into the motComps structure:
    motComps=[actnClass,...          % type of motion actnClass: "adjustment", "constant", or "impulse". 
              avgMagVal,...          % Magnitude of data (average value). Needs to be averaged when second match is found
              rmsVal,...             % Root mean square value
              amplitudeVal,...       % Largest difference from one edge of p1 to the other edge of p2              
              glabel1,...            % bpos...snet...impulse
              glabel2,...            % type of label b/m/s/pos/neg/const/impulse
              t1Start,...            % time at which first primitive starts
              t1End,...              % time at which first primitive ends
              t2Start,...            % time at which second primitive starts
              t2End,...              % time at which second primitive ends
              tAvgIndex              % Avg time
              ];                     % [actnClass,avgMagVal,rmsVal,glabel1,glabel2,t1Start,t1End,t2Start,t2End,tAvgIndex]

    % Update index
    index = match+1;      
    
end