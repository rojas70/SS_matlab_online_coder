%% loadData
%
% Function modified last: Nov. 26, 2012
%
% To prepare for codegen and as if running from HIRO Robot
%
% Arguments removed. Codegen does not support strcat, ispc, 
% Solution: 
%   Assign a hardcoded folder for results to come in.
%       If simulation select your folder of choice.
%       If Hiro robot select: /home/grxuser/src/OpenHRP3-0/Controller/IOserver/HRP2STEP1/bin)
%       Use fwd slashes in this version of matlab
%
% CodeGen does not recognize:
% strcat commands
% if(ispc) remove
%
% This function loads 4 different sets of data from file. All data sets
% are generated during the Pivot Approach.
% The data collected is: angle, force, Snap-Joint, and automata state times
% data.
%--------------------------------------------------------------------------
function [fPath,StratTypeFolder,forceData,stateData] = loadData(StrategyType,FolderName)

%#codegen
coder.inline('never');


%% Init
    %tempforceCharBuffer = char(zeros(1,20000));
    forceData=zeros(2000,7);
    stateData=zeros(5,1);
%     forceData = repmat(coder.opaque('int32','0.0'),2000,7); %opaque has two args: type, val. repmat has 3:type, rows,cols.
%     stateData = repmat(coder.opaque('int32','0.0'),5,1);
%% Data Loading Flags
    
    % What data should we load?
    % For HIRO
    if(strcmp(StrategyType,'HSA') || strcmp(StrategyType,'HIRO')) % Currently we are not using joint angle data and cartesian data. May use later. 
        %angleFlag = 0;
        forceFlag = 1;
        stateFlag = 1;
        %cartFlag  = 0;
    else
        %angleFlag = 0;
        forceFlag = 1;
        stateFlag = 1;     
        %cartFlag  = 0;        
    end
      
%% Select Appropriate Path based on Ctrl Strategy to read data files

    StratTypeFolder = AssignDir(StrategyType);
    
    % Running in Simulation
    %fPath = '/home/vmrguser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin';
    fPath = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/'; 
    
    % Running REAL HIRO robot
    %fPath = '/home/grxuser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin';
    
    
    % Not supported for code generation
    %if(ispc)
    %    fPath = 'C:/Documents and Settings/suarezjl/My Documents/School/Research/AIST/Results';
    %else
    %fPath = '/home/vmrguser/School/Research/AIST/Results';
       % QNX
       % '/home/hrpuser\forceSensorPlugin_Pivot\Results'; 
    %end    

%% Complete Path to Files and Load Data
    
%% Force-Torque Data    
    if(forceFlag)      
        % Compute the path name
        %ForceData = '/home/vmrguser/src/OpenHRP-3.0/Controller/IOserver/robot/HRP2STEP1/bin/Torques.dat';
        ForceData = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/Torques_x-2y2z.dat';

        
        %forceData =load(ForceData); 
        % readfile returns a char with all the elements of force data. will
        % need a for loop to parse and place inside forceData.
         tempforceCharBuffer = readfile(ForceData);  %% codegen function. See http://www.mathworks.cn/products/matlab-coder/examples.html?file=/products/demos/shipping/coder/coderdemo_readfile.html
                                                    % Not sure of the format that this will assume.
        len = length(tempforceCharBuffer);
        for i=1:len
           forceData(ceil(i/7),(i\7))=coder.ceval('atoi',coder.ref(tempforceCharBuffer(i))); 
        end
    end          
    
%% Automata State Times    
    if(stateFlag)
        %StateData = '/home/vmrguser/src/OpenHRP-3.0/Controller/IOserver/robot/HRP2STEP1/bin/State.dat';   
        StateData = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/State_x-2y2z.dat';

        % stateData =load(StateData);
        tempforceCharBuffer = readfile(StateData);
        
        len = length(tempforceCharBuffer);
        for i=1:len
           stateData(ceil(i/7),(i\7))=coder.ceval('atoi',coder.ref(tempforceCharBuffer(i))); 
        end        
    end     
%     
% %% Cartesian Position Data    
%     if(cartFlag)
%         CartPos = '/home/vmrguser/src/OpenHRP-3.0/Controller/IOserver/robot/HRP2STEP1/bin/CartPos.dat'; 
%         CartPos = load(CartPos);
%         CartPos = CartPos(1:Ctr,:);
%     end
%     
% %%  Joint Angle Data
%     if(angleFlag)
%         AngleData = '/home/vmrguser/src/OpenHRP-3.0/Controller/IOserver/robot/HRP2STEP1/bin/Angles.dat';
%         EncoderIncompatibility: angleData = load(AngleData);
%         angleData = angleData(1:Ctr,:);
%     end      
end