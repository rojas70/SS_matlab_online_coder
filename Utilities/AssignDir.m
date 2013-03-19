%%*************************** Documentation *******************************
% Function used for Snap Assembly strategies. 
% Assigns appropriate strategy path based on the kind of approach used.
% Use forward slashes for Matlab r2012b
%**************************************************************************
function StratTypeFolder = AssignDir(StrategyType)

% Assign a directory path based on the StrategyType used. 
    if strcmp(StrategyType,'S')
        StratTypeFolder = '/PositionControl/StraightLineApproach-NewIKinParams/';            % Straight Line with new IKin params
    elseif strcmp(StrategyType,'SN')
        StratTypeFolder = '/PositionControl/StraightLineApproach-NewIkinParams-Noise/';		% Straight Line with new IKin params with noise
    elseif strcmp(StrategyType,'P')
        StratTypeFolder = '/PositionControl/PivotApproach-NewIkinParams/';                   % Pivot approach with new IKin Params
    elseif strcmp(StrategyType,'PN')
        StratTypeFolder = '/PositionControl/PivotApproach-NewIKin-Noise/';                   % Pivot approach with new IKin Params with noise
    elseif strcmp(StrategyType,'FS')
        StratTypeFolder = '/ForceControl/StraightLineApproach/';
    elseif strcmp(StrategyType,'FP')
        StratTypeFolder = '/ForceControl/PivotApproach/';    
    elseif strcmp(StrategyType,'HSA')
        StratTypeFolder = '/ForceControl/SideApproach/';  
    elseif strcmp(StrategyType,'HIRO')
        StratTypeFolder = '/ForceControl/HIRO/';
    else
        StratTypeFolder = '';
%        FolderName='';
    end
end