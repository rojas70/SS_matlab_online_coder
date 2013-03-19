%%*************************** snapVerification ****************************
% Very different in its "Online Version" that Offline version. This
% function runs the following layers of the RCBHT system for only a single
% force axis at a time: Primitives Layer, Motion Composition Layer,
% Low-Level Behavior Layer, Low-Level Belief Layer
%
% Inputs:
% fPath         : Working path
% StratTypeFolder: folder corresponding to strategy type
% StrategyType     : HIRO - Online Snap Verification for Side Approach
% FolderName    : Name of folder where results are stored, user based.
% Index         : indicates what force axis is currently being evalueated
% forceData     : it's a growing matrix of forceData accumulated over the
%                 lifetime of the experiment. It's a [nx1] structure of 
%                 doubles indicating: [curTime correspondingForce]
% stateData     : a 5x1 vector indicating the transition times for the PA
%                 automata states:[startApproach,startRot,startSnap,startMat,End]
% snapJointData : when using the PA10 in simulation. Not yet implemented.
%
% Outputs:
% posteriorBelief       - the belief per unit time on high-level behaviors: [Rot, Snap, Mating]
% EndRot,EndSnap,EndMat - time at which these automata states end
% time                  - current time
% stateTimes            - column vector of state times
% localRangeStart       - variable tied to simulatedLoadData and fitRegressionCurves
% August 2012 - J. Rojas.
%**************************************************************************
% function  [posteriorBelief,EndRot,EndSnap,EndMat,time,stateTimes,localRangeStart] = snapVerification(fPath,StratTypeFolder,StrategyType,FolderName,...
%                                                                                                      Index,forceData,...
%                                                                                                      localRangeStart,globalRange,...
%                                                                                                      stateData) % The argument for JointSnapData has been removed from here for now. Aug 2012
function  [posteriorBelief,EndRot,EndSnap,EndMat,time,stateTimes] = snapVerification(fPath,StratTypeFolder,StrategyType,FolderName,...
                                                                                                     Index,forceData,...
                                                                                                     globalRange,...
                                                                                                     stateData) % The argument for JointSnapData has been removed from here for now. Aug 2012

%% Global Variables
%-----------------------------------------------------------------------------------------
%     global Optimization;    % No optimization in Online version. Set in %TOP: pRCBHT.m - The Optimization variable is used to extract gradient classifications from a first trial. Normally should have a zero value.    
%-----------------------------------------------------------------------------------------
    %global statData;    % Initialize all globas in their first instantiation        
    statData            = zeros(100,7,'double');
    motComps            = 0; % temporary initialization
%-----------------------------------------------------------------------------------------
    global localRangeStart;
%-----------------------------------------------------------------------------------------        
    global gradLabels;
%-----------------------------------------------------------------------------------------    
    global PRIM_LAYER;      % Used to indicate if we should run the primitives layer
    global MC_LAYER;        % Used to indicate if we should run the MC layer
    global LLB_LAYER;       % Used to indicate if we should run the LLB layer
    global LLB_BELIEF;      % Used to indicate if we should run the LLB Belief    
    HLB_LAYER   = 1;
    pRCBHT      = 0;    % Compute the llb and hlb Beliefs  
%-----------------------------------------------------------------------------------------
    
%% 1) Plot Snap Data (snapJointProfiles for PA10 also)
%     if(DB_PRINT)
%         plotOptions=1;  % if plotOptions=0, then plot separate figures. if plotOptions=1, then plot in subplots
%         [axesHandles,TL,BL]=snapData3(fPath,StratTypeFolder,StrategyType,FolderName,plotOptions,forceData,stateData,Index); % The argument for JointSnapData has been removed from here for now. Aug 2012
%         fprintf('\nRan snapData3\n')
%     % No printing
%     else
        axesHandles=-1;TL=1*ones(1,6);BL=TL;curHandle=-1;pType=0;
%     end

%% 2) Generate the Primitives Layer
    if(PRIM_LAYER)
        
        [localRangeStart,statData, curHandle,gradLabels] = primitivesLayer(fPath,StrategyType,StratTypeFolder,FolderName,...
                                                           forceData,statData,...
                                                           localRangeStart, globalRange,...
                                                           stateData,axesHandles,TL,BL,Index);
        %if(DB_PRINT);fprintf('\nRan primitivesLayer\n')
        %end
    end

%% 3) Generate the compound motion compositions for each of the six force elements

        if(MC_LAYER)
            pType = Index;
            % If you want to save the .mat of motComps, set saveData to 1. 
            saveData = 0;
            motComps = CompoundMotionComposition(StrategyType,statData,saveData,gradLabels,curHandle,TL(Index),BL(Index),fPath,StratTypeFolder,FolderName,pType,stateData); %TL(Index+2) skips limits for the first two snapJoint suplots    
        end

%% 4) Generate the low-level behaviors

        if(LLB_LAYER)
            % Combine motion compositions to produce low-level behaviors
            %[llbehStruc,llbehLbl,lblHandle] = 
            llbehComposition(StrategyType,motComps,curHandle,TL(Index),BL(Index),fPath,StratTypeFolder,FolderName,pType,Index);
        end
        
%% 5a) Compute the low-level Belief through a Bayesian Filter

%     if(LLB_BELIEF) % No calibration in online system && Optimization==0)
%         Status = 'Offline'; % Can be online as well.             
%         [posteriorBelief,EndRot,EndSnap,EndMat,time,stateTimes] = llbBayesianFiltering(StrategyType,FolderName,Status,Index);          
%     else
        posteriorBelief=-1;EndRot=-1;EndSnap=-1;EndMat=-1;time=-1;stateTimes=-1;
%     end 

%% 5b) Compute the high-level behavior (Snap Verification) Layer

    if(HLB_LAYER) % No calibration in online system && Optimization==0)
        posteriorBelief=-1;EndRot=-1;EndSnap=-1;EndMat=-1;time=-1;stateTimes=-1;        
        hlbehStruc = hlbehComposition(llbehFM,llbehLbl,stateData,curHandle,TL,BL,fPath,StratTypeFolder,FolderName)
      else
        posteriorBelief=-1;EndRot=-1;EndSnap=-1;EndMat=-1;time=-1;stateTimes=-1;
     end 
end