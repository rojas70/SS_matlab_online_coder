%   llbehLbl   = {'FX' 'CT' 'PS' 'PL' 'AL' 'SH' 'U' 'N');   % {'fix' 'cont' 'push' 'pull' 'align' 'shift' 'unstable' 'noise');
%   llbehLbl    = [ 1,   2,   3,   4,   5,   6,   7,  8];
%%-------------------------------------------------------------------------
function llbLabel=llbInt2llbLbl(llbLabel)

    % Convert labels to ints
    if(llbLabel==1)
        llbLabel = 'FX';    % alignment
    elseif(llbLabel==2)
        llbLabel = 'CT';    % increase
    elseif(llbLabel==3)
        llbLabel = 'PS';    % decrease
    elseif(llbLabel==4)
        llbLabel = 'PL';    % constant
    elseif(llbLabel==5)
        llbLabel = 'AL';    % positive contact
    elseif(llbLabel==6)
        llbLabel = 'SH';    % negative contact
    elseif(llbLabel==7)
        llbLabel = 'U';    % contact
    elseif(llbLabel==8)
        llbLabel = 'N';    % unstable
    end    
end