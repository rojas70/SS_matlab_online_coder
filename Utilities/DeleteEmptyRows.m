%% ***************************** Documentation ****************************
% This function looks for empty rows in a matrix, deletes the rows, and
% rearranges that information appropriately, also deleting any emptry rows left
% behind at the end. 
%
% When an empty row is found, the next cell is copied to its place
% iteratively. 
%
% Input parameters:
% data:     - mxn row vector array
%**************************************************************************
function data = DeleteEmptyRows(data)

%% Initialization

    % Get number of rows and columns
    r = size(data);
    
    % If empty element
    if(r(1)==1)
        return;
    end
    
    % Counter for the number of empty cells
    emptyCellNo = 0;
    
%% Delete and Copy rows
    
    % Go through all rows
    i = 1;
    while(i<=r(1))                    

        % Find the empty row.
        if( all(data(i,:)==0) ) % make sure all elements are zero

            % Copy, starting from that index, all subsequent k-cells to j-cells
            for j=i:r(1)-1

                % Let k be the j+1 index
                k=j+1;
                data(j,:) = data(k,:);
            end 

            % Increase emtpy cell counter and don't change the index
            emptyCellNo = emptyCellNo+1;  

        else
            i = i+1;
        end

%%      Check for terminal condition and if the last cell is empty
        % Given that the matrix will shrink and that empty cell arrays are left behind,
        % We need to exit when the original # rows - # deleted rows is
        % reached 
        if(i==(r(1)-emptyCellNo))
            if( all(data(i,:)==0) )
                emptyCellNo = emptyCellNo+1;
            end
            break;
        end
    end
    
    % Delete the last "emtpyCellNo" rows
    if(emptyCellNo)
        data = data(1:r(1)-emptyCellNo,:);
    end
end