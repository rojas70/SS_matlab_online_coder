%% ****************** Documentation ***************************************
% Iterate through the string cell array to look for string 1. If found,
% look for the second string in the remaining space. If found return true,
% otherwise return false.
%
% Could have 1 or 2 strings
%
% Input Parameters:
% data:         - stringed cell array
% varargin:     - list of strings
%   string1:      - string1 to match
%   string2:      - string2 to match
%**************************************************************************
function bool = findStrings(data,varargin)

%%  Initialization
    varlen  = length(varargin);
	len     = length(data);
    bool    = false;
    
%% Find strings
    if(varlen==2)
        % Find first string
        for i = 1:len
            if(strcmp(data{i},varargin(1,1)))

                % Find second string
                for ii=i:len
                    if(strcmp(data{ii},varargin(1,2)))

                        % Set the output variable to true
                        bool = true;
                    end
                end
            end
        end

    % Only one string
    else
        % Find first string
        for i = 1:len
            if(strcmp(data{i},varargin(1,1)))
                % Set the output variable to true
                bool = true;           
            end
        end
    end
end