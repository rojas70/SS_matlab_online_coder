%% **************************** Documentation *****************************
% Merges data between two continguous elements in a data composition data
% structure. 
% 
% The data structure is a row numeric vector array composed of 11 elements: 
% data:{nameLabel,avgVal,rmsVal,amplitudeVal,p1lbl,p2lbl,t1Start,t1End,t2Start,t2End,tAvgIndex}
% 
% Input Parameters:
% index:            - first element of contiguous pair.
% data:             - an mx11 cell array data structure containing action compositions
% gradientLbl       - cell array structure that holds strings for primitives
% gradientLblIndex  - value of 0 or 1 used to select the first primitive or the second
%                     primitive. 
%**************************************************************************
function data = MergePrimitives(index,data,gradientLbl,gradientLblIndex)

%%  Initialization

    % Define next contiguous element
    match = index+1;

%%  GRADIENT PRIMITIVES
    % primitives Structure Indeces
     AVG_MAG_VAL      = 1;   % average value of primitive
     MAX_VAL          = 2;   % maximum value of a primitive
     MIN_VAL          = 3;   % minimum value of a primitive   

     % Time Indeces
     %T1S = 4; 
     T1E = 5;
    
    % Gradient Indeces
    GRAD_VAL    = 6;
    GRAD_LBL    = 7;
    
%%  Name Label 
    data(index,GRAD_LBL) = data(index+gradientLblIndex,GRAD_LBL); % Keep the label of the gradient that is longer
    
%%  Values                                                        
    % Average average magnitude value: (index+match)/2
    data(index,AVG_MAG_VAL)   = ( data(index,AVG_MAG_VAL)   + data(match,AVG_MAG_VAL) )/2; 
    
    % MAX_VAL value: (index+match)/2
    data(index,MAX_VAL)       = ( data(index,MAX_VAL)       + data(match,MAX_VAL) )/2; 
    
    % MIN_VAL value: (index+match)/2
    data(index,MIN_VAL)       = ( data(index,MIN_VAL)       + data(match,MIN_VAL) )/2;     

%%  Time
    % T1_END,index = T2_END,index
    data(index,T1E) = data(index+1,T1E);
       
%% Gradient
    % Average gradient values
    data(index,GRAD_VAL)   = ( data(index,GRAD_VAL)   + data(match,GRAD_VAL) )/2; 
    
%%  Delete 2nd element data                    
    data(match,:)=0; 
end