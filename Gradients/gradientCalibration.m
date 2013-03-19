%% PreGradientClassificationOptimization
%
% This function seeks to recognize gradient classification values
% associated with CONTACT events and CONSTANT gradient classifications
% according to the Relative-Change-Based-Hierarchical-Taxonomy (RCBHT).
% 
% The classification of CONTACTS and CONSTANTS will be separated for Force
% values and Moment values (as obtained by the 6 DoF FT sensor).
%
% A CONSTANT value will be computed for each of the 6 DoF of the FT data.
% This value, however, will be extracted by looking at the "maximum value
% gradient" that occurs during the ROTATION state of the task. 
%
% As for the CONTACT value, we will look at the max gradient values in the
% Snap state of the task. The max value associated with Fz will be used to
% classify both Fz and Fy. The value of Fx will be used for itself. And the
% value of My will be used for Mx and Mz as well. 
% This last arbitration was selected based on the fact that Fx, Fz, and My
% are the key axes to study for contacts. The other axes do not experience
% contacts during successful assemblies so their data is of no use for this
% selection.
%
% Care needs to be taken to understand if the max gradients are positive or
% negative. Then, as per the original gradient classification of the RCBHT
% we need to compute the 4 positive and 4 negative gradient
% classifications: [pimp, bpos, mpos, spos, const, sneg, mneg, bneg, nimp]. 
%
% Since we have computed the impulse and the constant the rest of the space
% is divided by three. 
%
% The stateData vector is used to divide the time series 
% Inputs:
% stateData     - vector of state times
% statData      - nx6 statistical data where the [dAvg dMax dMin dStart dFinish dGradient dLabel]
% forceAxes     - what force axes is being used for computation
%--------------------------------------------------------------------------
function gradientCalibration(fPath,StratTypeFolder,stateVec,statData,index)      
    
%% Initialization

    % Variables
    %GradientNum	= 2;                               % Used to describe two values for gradient limits 
    
    % Statistical Data
    startTime   = 4;                                % start time for statistical vector
    endTime     = 5;                                % end time for statistical vector
    dGradient   = 6;                                % gradient value for statistical vector
    
    % State Vector
    rotStart    = 2;
    rotEnd      = 3;
    snapStart   = 3;
    snapEnd     = 4;
    
    % Size
    rStatistical = size(statData);   % Size of statistical data vector
    
    % Gradients
    scalingConstRange   = 0.10;          % Used to scale the constant values by a certain percentage.    
    scalingCtctRange    = 0.15;          % Used to scale the contact values by a certain percentage.    
	maxContact          = 0;
    %maxConst           = 0;
    
    % Store the 9 values (and for each force axis) of gradient classification values
    %gradClassification = zeros(GradientNum,1);       % Store [pimp pConst]
    
%%  Work with FIXED Behaviors -- Rotation Automata State

    % FORCE AXES -- 1 -- {Fx}
    % Moment AXES -- 1 -- {My}
    
    % Only compute for Fx and My
    if(index==1 || index==5)
        % Look at all the primitives within the Rotation state        
        for i = 1:rStatistical(1)
            if( statData(i,startTime)>stateVec(rotStart,1) )
                startIndex = i;
                break;
            end
        end

        for i = 1:rStatistical(1)
            if(statData(i,endTime)>stateVec(rotEnd,1))
                endIndex = i-1;
                break;
            end
        end

        % Compute the maxConst as the mean of all gradients
        if(index==5)
            pConst = abs(mean(statData(startIndex:endIndex,dGradient)));
            %modeConst = abs(mode(statData(startIndex:endIndex,dGradient)));
        elseif(index==1)
            pConst = abs(mean(statData(startIndex:endIndex,dGradient)));
        end

        % Assign the maximum value Pimp and Nimp
        %meanConst = meanConst - (scalingConstRange*meanConst);
        pConst = pConst - (scalingConstRange*pConst);
    else
        pConst = 0;
    end
    
    
%% Work with CONTACT Behaviors   

    % FORCE AXES -- 2 -- {(Fx),(Fz->Fy)}
    % Moment AXES -- 1 -- {My}
    %if(index==1 || index==3 || index==5)
        % Look at all the primitives within the snap state
        for i = 1:rStatistical(1)
            if( statData(i,startTime)>stateVec(snapStart,1) && statData(i,endTime)<stateVec(snapEnd,1))
                if ( abs(statData(i,dGradient)) > maxContact ) % Look for the absolute value
                    maxContact = abs(statData(i,dGradient));
                end
            end        
        end   

%% Assign the maximum value Pimp and Nimp with a 15% leniency in the
        % range of the avalue.
        if(index==5)
            maxContact = maxContact - (scalingCtctRange*maxContact);    
            maxContact = 0.85*maxContact; % Double scaling here. Based on experimental results if we use My's contact, we need a 0.85 further scaling.            
        else
            maxContact = maxContact - (scalingCtctRange*maxContact);    
        end
        
        pimp = maxContact;            
        gradClassification = [pimp pConst];        
    
%% Studying what mean/mode/median might look here:
%         for i = 1:rStatistical(1)
%             if( statData(i,startTime)>stateVec(snapStart,1) )
%                 startIndex = i;
%                 break;
%             end
%         end
% 
%         for i = 1:rStatistical(1)
%             if(statData(i,endTime)>stateVec(snapEnd,1))
%                 endIndex = i-1;
%                 break;
%             end
%         end
% 
%         % Compute the maxConst as the mean of all gradients
%         meanContct   = abs(mean(statData(startIndex:endIndex,dGradient)));
%         modeContct   = abs(mode(statData(startIndex:endIndex,dGradient)));
%         medianContct = abs(median(statData(startIndex:endIndex,dGradient)));
                        
%% Write to File
%% Later we will copy the force values of Fz into Fy and My into Mx and Mz
    WriteGradientClassification(fPath,StratTypeFolder,gradClassification,index);
end