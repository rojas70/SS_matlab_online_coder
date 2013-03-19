%% pRCBHT
%  1) Loads force data
%  2) Calls RCBHT
%  3) Performs pRCBHT
%
% OVERVIEW
% Central program to execute bayes filtering at both the
% low-level-behavior (llb) level and the high-level-behavior (hlb) level specific 
% to the Side Approach (Pivot Approach with 4 snaps).
%
% READING AND WRITING DATA
% In the online version of this program, we read data from HIROs filesystem
% '/home/grxuser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin';
% See LoadData()
%
% Data produced by the RCBHT is stored at:
% '/home/vmrguser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin/tmp';
% See snapData() and savePlot()
% 
% Inputs:
% StratTypeFolder   - Stringed input describing thpe of strategy to be
%                     pursed. See AssignDir.m. Could be 'HSA','FP',etc.
% FolderName        - The name of the folder where the current results are
%                     stored.
% Status            - determines whether the program is running on offline
%                   or online mode.
% 
% Outputs:
% postTime          - The output is a (3 x Time x 6) structure that reflects the posterior
%                   probability for each of the three (force-containing) HLB automata states: Rotation, Snap,
%                   and Mating .
% hlbBelief         - a nx1 struc reprenting the product of the llb posteriors
%                   for selected llb's wrt the rotation, snap, and mating
%                   states. It represents the overall belief of the SUCCESS
%                   OF THE TASK over time
% stateTimes        - times at which states start and end. this is a
%                   modified version that takes into account that the llb
%                   structure is slightly different for each axis and that
%                   different axes have different finish times. this one is
%                   the minimum time across a given set of axes. 
%%
%function [hlbBelief llbBelief stateTimes]= pRCBHT(StrategyType,FolderName,forceIndex)
function pRCBHT 

%% 0) Initialization of output params for Matlab Coder

%     fPath           = char(zeros(1,512));
%     StratTypeFolder = char(zeros(1,512));
%     StrategyType    = char(zeros(1,512));
%     FolderName      = char(zeros(1,512));
%     Index           = int32(1);
%     forceIndex      = zeros(1,6,'int32');
%     forceData       = zeros(5000,7,'double');
%     globalRange     = zeros(1,512,'int32');
%     stateData       = zeros(1,5,'double');
    
    StrategyType    ='HIRO';                         % To be run in the real robot
    FolderName      ='20121126-1000-SideApproach-S';
    forceIndex      =1:6;

%% Global Allocation

    %% Matlab Coder. Set inlining code to never to ease reading. 
    %#codegen
    coder.inline('never');

    % GRADIENT CALIBRATION FOR PRIMITIVES LAYER
%     global Optimization;    % The Optimization variable is used to extract gradient classifications from a first trial. Normally should have a zero value.
%     Optimization = 0;       % If you want to calibrate gradient values turn this to 1 and make sure that all calibration files found in:
                            % C:\Documents and Settings\suarezjl\My Documents\School\Research\AIST\Results\ForceControl\SideApproach\gradClassFolder
                            % are deleted. 
                            % After one run, turn the switch off. The routine will used the saved values to file. 
                            
%------------------------------------------------------------------------------------------
    %% START/END/TIMING FLAGS
    global runRCBHT;        % Changes to false when the robot reaches the end of the task
    runRCBHT     = true;  
    
%------------------------------------------------------------------------------------------    
    % WRITE/PRINT FLAGS
    global DB_PRINT;        % Includes debugging commands and plots printing
    global DB_WRITE;
    global DB_DEBUG;
    
    DB_PRINT=0;             % For online run turn this to zero
    DB_WRITE=1;             % To save data to file
    DB_DEBUG=0;             % To enable debugging capabilities
    
%------------------------------------------------------------------------------------------    

    % RCBHT FILTERING CYCLES
    global MC_COMPS_CLEANUP_CYCLES;
    global LLB_REFINEMENT_CYCLES;  
    
    MC_COMPS_CLEANUP_CYCLES         = 2;    % Originally 3
    LLB_REFINEMENT_CYCLES           = 4;    % Originally 4
    
%------------------------------------------------------------------------------------------

    % pRCBHT LAYER ON/OFF SWITCHES. Values assigned in snapVerification.m
    global PRIM_LAYER;  PRIM_LAYER  =1;
    global MC_LAYER;    MC_LAYER    =1;
    global LLB_LAYER;   LLB_LAYER   =1;
    global LLB_BELIEF;  LLB_BELIEF  =0;
%------------------------------------------------------------------------------------------

    % TIME
%     global startTime;     % The starting time for the experiment
     global curTime;       % The current time for the experiment
     global prevTime;      % The previous measured time in the experiment
%     global accumTime;     % accumulated time for experiment
     global simStep;       % Simulation/Experimental time     
%     global startIndex;    % Used to load force data
%     global endIndex; 
    
%     accumTime   = 0;
%     startIndex  = 1; 
%     endIndex    = 1;
    curTime = 0.0;
    prevTime = 0.0;
    
    % Set the timeStep
    simStep = 0.005;
%     if(strcmp(StrategyType,'HSA'));     simStep = 0.005;
%     else                                simStep = 0.005;
%     end
%------------------------------------------------------------------------------------------
    global dataPipeFlag;    % Indicates when new data has come in from the Robot
    dataPipeFlag = true;    % Adjust to in case we do TCP/IP. This flag will tell when new data comes in.
%------------------------------------------------------------------------------------------

    % Force Data and stateVec data as globals??
    %global forceData;    %global stateData;
    
%% SIMULATED LOAD DATA FLAGS

    global localRangeStart;
    localRangeStart = 0.0;
    
    %localRangeStartA         = 0;
    %localRangeStartB         = 0;
    
    global prev_globalRangeStart;   
    prev_globalRangeStart   =  1;
    
    global prev_globalRangeEnd;     
    prev_globalRangeEnd     = 10;
%------------------------------------------------------------------------------------------
%% PRIMITIVE LAYER FLAGS

%     global statData;
%     statData         = zeros(150,7);                % Growing array that will hold segmented block statistical data (int types).    

     global regressionInitializeFlag;                % GOOD CORRELATION BUT TERMINATED REGRESSION B/C DATA LENGTH IS STILL GROWING
     regressionInitializeFlag = 1;
    
%%    
    global segmentDirectoryFlag;                    % Init flag to initialize the directory path in WritePrimitivesToFile.m
    segmentDirectoryFlag = true;                    % Starts as true. 
    
    global statDataInitFlag;                        % Init flag to allocate the statistical data structure in primitivesLayer.m
    statDataInitFlag = true;

%%    
    global indexStart;                              % fitRegressionCurves.m - indicates where algorithm starts analyzing
    indexStart=1;
    
    global windowStart;                             % fitRegressionCurves.m - indicates where window for linear fit starts 
    windowStart = 1;
    
    global segmentIndex;                            % fitRegressionCurves.m - counter to indicates how many elements of statistical data we have
    segmentIndex=1;
    
    global previousSegmentIndex;                    % Same as above - keep history
    previousSegmentIndex = 1;
    
    global gradLabels;                              %  Gradient Classification Structure
    gradLabels = [ 'bpos';   ... % big   pos grads
                   'mpos';   ... % med   pos grads
                   'spos';   ... % small pos grads
                   'bneg';   ... % big   neg grads
                   'mneg';   ... % med   neg grads
                   'sneg';   ... % small neg grads
                   'cons';   ... % constant  grads
                   'pimp';   ... % large pos grads
                   'nimp';   ... % large neg grads
                   'none'];    
    global Type;
    Type = ['Fx';'Fy';'Fz';'Mx';'My';'Mz'];        

%% Debug Enable Commands
%     if(DB_DEBUG);        dbstop if error
%     end

%% 1a) Initialize
    %NumStateEntries     = 5;            % Number of automata states = n+1 states: (StartApproach,StartRotate,StartInsertion,StartMating,EndMating)
      
    %experimentTime      = 10.0;         % Seconds
    %Steps               = experimentTime/simStep;

%% 1b) PreAllocate    
    %forceData=zeros(Steps,7);
    %stateData=zeros(NumStateEntries,1);
    
%% 2) TCP/IP Connection
% Connect
    

%% 3) Preload the ForceData 
% Done as long as running separate from the simulatoin
    
    [fPath,StratTypeFolder,forceData,stateData] = loadData(StrategyType,FolderName);
%% 4) Run the pRCBHT Framework

    % Run as long as the runRCBHT is true. Changes to false when robot
    % indicates end of task
    %% EncoderNonCompliant: tic;
    startTime   = 0;
    experimentCtr = 1;
    
    while(runRCBHT)
        
        % Run only if new data has come from the robot
        if(dataPipeFlag == true)           

%%          5) Load appropriate data -- may need to do this outside first
            % Incrementally load force data with every step, update automata state
            % times when appropriate
            
            % Get time at which this function is called
            %% EncoderNonCompliant: toc;
            %% EncoderNonCompliant: curTime     = toc;
            if(experimentCtr==1)
                prevTime    = curTime;
            end
            %[singleFD,nextIndex]=simulatedLoadData(forceData,startIndex,forceIndex); % All time elements passed in as globals
            [forceDataBuffer,globalRange]=simulatedLoadData(forceData,forceIndex);
            experimentCtr=experimentCtr+1;
            %% EncoderNonCompliant: if(DB_PRINT); fprintf('\nLoaded Data\n');end
            
%%          5) Call the pRCBHT with threads that run the six axis at the same time    
            % Include a parfor here later
            parfor fIndex = 1:6    
                %forceDataBuffer = [forceData(1:100,1) forceData(1:100,fIndex+1)];
                %forceDataBuffer = [forceData(:,1) forceData(:,fIndex+1)];
                [posteriorBelief,EndRot,EndSnap,EndMat,time,stateTimes] = snapVerification(fPath,StratTypeFolder,StrategyType,FolderName,...
                                                                                           fIndex,forceDataBuffer,...
                                                                                           globalRange,...
                                                                                           stateData); % The sixth argument <<JointSnapData>> has been removed from here for now since we don't use the PA10 config for online version so far. Aug 2012
            end

%% Do this in a separate file            
%%          6) After the llbBeliefs for the six axes have been computed we can run the hlbLayer
%             if(fIndex==6)
%                 [hlbBelief llbBelief] = hlbBayesianFiltering(StrategyType,FolderName,stateTimes,posteriorBelief,time,EndRot,EndSnap,EndMat);
%             end
        end
    end  
end