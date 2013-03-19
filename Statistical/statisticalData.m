% Return a variety of statistical data from the plot
%
% Inputs:
% wStart        - what force element do we want to start off with, Fx=1, Mz=6.
% wFinish       - what force element do we want to finish with.
% Data          - is the y-values of the segmented linear fit curve
% domain        - is the difference between the maximum and minimum y-value for the whole
%                 force data for that axis 
% polyCoeffs    - coefficients that describe the fitted line
% StrategyType  - tells whether using PA10-PivotApproach or HIRO-SideApproach
% forceAxisIndex- what force axes am i on.
%
% Outputs:
% dAvg          - average int value of a primitive. ie. (maxval-minval)/2.
% dMax          - max int value in a primitive.
% dMin          - min int value in a primitive.
% dStart        - time at which primitive starts
% dEnd          - time at which primitive endds
% dGradient     - gradient value of primitive
% dLabel        - gradient integer label
function [dAvg dMax dMin dStart dFinish dGradient dLabel]=statisticalData(wStart,    wFinish,...
                                                                          Data,      polyCoeffs,... % domain not used anymore
                                                                          FolderName,StrategyType,forceAxisIndex)
    
%% Compute Statistical Parameters of the poly fitted Data
    dAvg        = mean(Data);                           % 1)
    dMax        = max(Data);                            % 2)
    dMin        = min(Data);                            % 3)
    dStart      = wStart;                               % 4)
    dFinish     = wFinish;                              % 5)
    dGradient   = polyCoeffs(1);                        % 6)
    
%% Label Data   
    % Label each segment based on gradient magnitude:
    % [pimp,bpos,mpos,spos,const,sneg,mneg,bneg,nimp]
    dLabel = GradientClassification(dGradient, FolderName,StrategyType,forceAxisIndex);  % 7) && Aug 2012 - domain removed
    
%% Convert dLabel from string to int
    dLabel = gradLbl2gradInt(dLabel);
end