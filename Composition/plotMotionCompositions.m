%********************* Documentation **************************************
% This function LABELS the plot of primitives with composition labels. 
% The set of compositions include: (alignment, increase, decrease, constant)
% and represendted by the strings: ('a','i','d','c').
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
% motComps:     - [actionClass,avgVal,rmsVal,AmplitudeVal,p1label,p2label,t1Start,t1End,t2Start,t2End,tavgIndex]
%
% Output Parameters:
% htext         - handle to the text objects in case user wants to modify
%
% Modifications:
% July 2012 - to facilitate the conversion from Matlab to C++ all cells
% have been eliminated. All {} were converted to ()
%**************************************************************************
function htext = plotMotionCompositions(StrategyType,rHandle,TL,BL,motComps)

%%  Preprocessing
    len     = length(rHandle);          % Check how many hanlde entries we have
    r       = size(motComps);           % Get the # entries of motion compositions
    htext   = zeros(r,1);               % This is a text handle and can be used if we want to modify/delete the text

    % Indeces
    compString  = 1;                    % type of composition: alignment, increase, decrease, constant
    AvgTime     = 11;               	% Used as an index. Always verify to make sure the index is not obsolete.
    
%%  Labeling
    
    % For each of the handles
    for i=1:len                                 % getting 7 handles instead of six...
        
        % For each of the compositions
        for index=1:r(1)                                             % rows            
            if(~strcmp(StrategyType,'HSA'))
                htext(i)=text(motComps(index,AvgTime),...                 % x-position. Average time of composition.
                             (0.75*TL(i)+((randn*TL(i))/10)),...          % y-position. Set it at 75% of the top boundary of the axis +/- randn w/ sigma = TL*0.04
                              actionInt2actionLbl(...
                                motComps(index,compString)),...            % Composition string: alignment, increase, decrease, constant.
                              'FontSize',7.5,...                          % Size of font
                              'FontWeight','light',...                    % Font weight can be light, normal, demi, bold
                              'HorizontalAlignment','center');            % Alignment of font: left, center, right. 
            % Side Approach: no rand variability
            else
                htext(i)=text(motComps(index,AvgTime),...                 % x-position. Average time of composition.
                         (0.90*TL(i)),...%+((randn*TL(i))/10)),...        % y-position. Set it at 75% of the top boundary of the axis +/- randn w/ sigma = TL*0.04
                          actionInt2actionLbl(...
                            motComps(index,compString)),...               % Composition string: alignment, increase, decrease, constant.
                          'FontSize',7.5,...                              % Size of font
                          'FontWeight','light',...                        % Font weight can be light, normal, demi, bold
                          'HorizontalAlignment','center'); 
            end
        end
    end
end