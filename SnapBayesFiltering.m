%% SnapBayesFiltering
%
%  Central program to execute bayes filtering at both the
%  low-level-behavior (llb) level and the high-level-behavior (hlb) level specific 
%  to the Side Approach (Pivot Approach with 4 snaps).
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
function [hlbBelief llbBelief stateTimes]= SnapBayesFiltering(StrategyType,FolderName,Status)

%% Compute the llbBayesFilter
    [postTime,EndRot,EndSnap,EndMat,time,stateTimes] = llbBayesianFiltering(StrategyType,FolderName,Status);

%% Compute the hlbBayesFilter
    [hlbBelief llbBelief] = hlbBayesianFiltering(StrategyType,FolderName,stateTimes,postTime,time,EndRot,EndSnap,EndMat);
end