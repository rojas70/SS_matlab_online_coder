%********************* Documentation **************************************
% This function LABELS the plot of primitives with composition labels. 
% The set of compositions include: {alignment, increase, decrease, constant}
% and represendted by the strings: {'a','i','d','c'}.
% 
% Positioning of Labels:
% The dependent axis is time. The average time between two primitives that
% have been compounded together is used to set the x-position of the label.
%
% The y-position is set 
% 
% Text Labeling:
% The text labeling is performed by extracting the first category or
% element of the CELL ARRAY motComps of type string. 
%
% Input Parameters:
% data:         - refers to the llbehStruc[llBehClass,avgVal,rmsVal,AmplitudeVal,mc1,mc2,t1Start,t1End,t2Start,t2End,tavgIndex]
% pType:        - the force element Fx,Fy,...,Mz.
%
% Output Parameters:
% htext         - handle to the text objects in case user wants to modify
%**************************************************************************
function htext = plotHighLevelBehCompositions(aHandle,TL,BL,data,stateData,fPath,StratTypeFolder,FolderName)

%%  Preprocessing
    k       = 1;                        % counter
    len     = length(aHandle);          % Check how many hanlde entries we have
    sLen    = length(stateData);
    r       = length(data);             % Get the # entries of compositions
    htext   = zeros(r,1);               % This is a text handle and can be used if we want to modify/delete the text

    % Indeces
    %LblIndex  = 1;                % type of composition: alignment, increase, decrease, constant
    hlBehLbl = {'Approach' 'Rotation' 'Alignment' 'Snap' 'Mating'};
        
%%  Labeling
    
%%  HANDLES
    % For each of the axis handles
    for i=1:len-2                           % Expect 6                
        
        % Activate the appropriate handle
        axes(aHandle(i));
        
%%      STATES        
        % For each of the states
        for index=1:sLen-1                 % Expect 6-1=5
            
%%          COLOR            
            % Depending on whether or not we have a successful high-level behavior change the color.
            if(data(index))
                clrVec = [0,0.25,0]; %green for success
            else
                clrVec = [0.25,0,0]; %red for failure
            end
            
%%          X-LOCATION            
            % Compute the middle location of each state
            if(index<length(stateData))
                textPos = (stateData(index) + stateData(index+1)) /2;
%             % For the last two states put at one third and two thirds
%             elseif(index==5)
%                 if(k==1)
%                     sLen=stateData(index+1)-stateData(index);
%                     textPos = stateData(4)+sLen*k*1/3;
%                     k=k+1;
%                 end
%             elseif(index==5)
%                     textPos = stateData(4)+sLen*k*1/3;
%                     k = 1;  % Reset for next cycle
            else
                break;
            end              
                
            % Plot the labels
            htext(i)=text(textPos,...                           % x-position. Average time of composition.
                          (0.90*BL(i)),...                      % y-position. No randomness here since there is no overcrowding... //Set it at 75% of the top boundary of the axis +/- randn w/ sigma = BL*0.04
                          hlBehLbl(index),...                   % Composition string: alignment, increase, decrease, constant.
                          'Color',clrVec,...                    % Green or red font color
                          'FontSize',7,...                      % Size of font
                          'FontWeight','normal',...             % Font weight can be light, normal, demi, bold
                          'HorizontalAlignment','center');      % Alignment of font: left, center, right. 
        end
    end
    
%%	G) Evaluate High-Level Behaviors
       
    % Change the color of the string based on whether it was successful or
    % not
    if(data(1:5))
        clrVec = [0,0.50,0]; % green for success            
        result = 'SUCCESS';
    else
        clrVec = [0.5,0,0]; % red for failure            
        result = 'FAILURE';
    end  

%%  Print the label
    for i=1:len 
        
        % Activate the handels
        axes(aHandle(i));
        
        text(4.15,...                           % x-position. Position at the center
             0.90*TL(i),...                     % y-position. Position almost at the top
             result,...                         % 'Success' string
             'Color',clrVec,...                 % Color
             'FontSize',8,...                   % Size of font
             'FontWeight','bold',...            % Font weight can be light, normal, demi, bold
             'HorizontalAlignment','center');   % Alignment of font: left, center, right.);
    end
    
%%  Save plot
    savePlot(fPath,StratTypeFolder,FolderName,aHandle,'hlbehPlot');
end