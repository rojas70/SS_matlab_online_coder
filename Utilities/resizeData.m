%*************************** Documentation ********************************
% Resizes a cell array to eleminate emtpy cells.
%
% Input Parameters:
% data:     - a vector array matrix
%**************************************************************************
function data = resizeData(data)

%% Get size of data
    elements = size(data);

%% Resize statData in case not all of its rows were occupied
    for i=1:elements(1)

        % If the row is all zeros
        if(all(data(i,:)==0))
            
            % Record the index for that row
            empty = i;
            
            % Resize data from 1 to empty-1
            data = data(1:empty-1,:);
            break;
        end
    end   
end