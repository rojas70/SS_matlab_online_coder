%%************************ Documentation **********************************
% Inserts a colored transparent window in the graph plot for each of the
% states. The stateVector is updated over time and as such many states may
% not yet exist. We only color states if they exist. 
%
% Input Parameters:
% stateVector: an mx1 vector including the time in which new states start
% max        : maximum y-value found in the plot
% min        : minimum y-value found in the plot.
% FillFlag   : determins whether the states should be filled with color.
function insertStates(stateVector,max,min,FillFlag)

%% Initialization
   
    % Analyze the stateVector: [EndApproach,EndRot,EndSnap,EndMating] to find if the elements are zero (empty)
    % except the first index by using inverse logic on the find function
    emptyElems = min(find(~stateVector(2:end))); % Min function returns 'the first index' where there is zero after the first position
    if(isempty(emptyElems))
        [r c] = size(stateVector);
    else
        r = emptyElems-1;
    end
    
%%  Define colors and transparency
%   red     = [0.8 0.25 0.9];
    orange  = [1.0, 0.6, 0.0];
    green   = [0 1 0.1];
    yellow  = [1 1 0];
    cyan    = [0.05 0.9 1];
    blue    = [0 0.25 1]; 
%   white   = [1 1 1];
    
    Transparency = 0.75;
%     if(FillFlag)
%         Transparency = 0.25;    
%     else
%         Transparency = 0.75;    
%     end
    
%% Create [initial_point, final_point] vectors for x and y coordinates
    % Get the x,y coords to generate a line segment for each state. 
    x_coords = zeros(r,2);      % [xmin xmax] for each state. 
    y_coords = zeros(r,2);      % [ymin ymax] for each state. 
    
    % Write x-coords and y-coords for all states. 
    for i=1:r                               % Go through each of the states
        for j=1:2                           % min and max coords
            x_coords(i,j) = stateVector(i); % The time at which an event starts
            
            % Copy the min value for y
            if(j==1)
                y_coords(i,j)=min;          
            
            % Copy the max value for y
            else
                y_coords(i,j)=max;          
            end
        end
    end
    
%% Draw a line for each of the existing states
%     for i=1:r
%         for j=1:c
%             line(x_coords(i,:),y_coords(i,:),'Color','b','linestyle','--','linewidth',2,'marker','.','MarkerEdgeColor','b','MarkerFaceColor','b')
%         end
%     end

%% Perform Patching: 
    % Assign a colored window to each state in the graph.
    % Includes some transparency. 

    % Left Vertex
    leftVert = 0;

%%  % Iterate through each of the states, coloring one-by-one. 
    for i=1:r
        for j = 1:c
            
            % Set the 4 vertices for each state in [x y z] coordinates. 
            v  = [leftVert       min 0;     % Bottom-left vertex  
                  stateVector(i) min 0;     % Bottom-right vertex
                  stateVector(i) max 0;     % Top-right vertex
                  leftVert       max 0];    % Top-left vertex
              
            % Set the order of vertices
            f = [1 2 3 4];
            
%% Color Definition            
            % Set vertex and face color. Face color follows first vertex. 
            % For simplicity, we set all vertices of a segment to the same
            % color.         
            %if(r==5)
                if(i==1)        % cyan
                    fvc = [blue; blue; blue; blue]; 
                elseif(i==2)    % organge
                    fvc = [orange; orange; orange; orange];                                 
                elseif(i==3)    % yellow
                    fvc = [yellow; yellow; yellow; yellow];                                 
                elseif(i==4)    % green                
                    fvc = [green; green; green; green];    
                elseif(i==5)    % blue            
                    fvc = [cyan; cyan; cyan; cyan];                                
                end    
            % First state was skipped. Rearrange colors for consistency
%             elseif(r==4)
%                 if(i==1)        % orange
%                     fvc = [orange; orange; orange; orange];  
%                 elseif(i==2)    % yellow
%                     fvc = [yellow; yellow; yellow; yellow];                                 
%                 elseif(i==3)    % green
%                     fvc = [green; green; green; green];                                
%                 elseif(i==4)    % cyan                
%                     fvc = [cyan; cyan; cyan; cyan];                               
%                 end                    
%             end

%%          Create a patch for each state
            patch('Vertices',        v    ,...
                  'Faces',           f    ,...
                  'FaceVertexCData', fvc  ,...
                  'FaceColor',      'flat',...
                  'EdgeColor',      'flat',...
                  'MarkerFaceColor','flat',...
                  'FaceAlpha',       Transparency)       % Transparency
              
            % Update leftVert to set the left vertex as the previous right-most
            % vertex coordinate. 
            leftVert = stateVector(i); 
            
        end % End j
    end     % End i
end         % End function