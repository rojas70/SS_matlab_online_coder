%%-------------------------------------------------------------------------
% gradLbl2gradInt
% -Imp -Big -Med -Small Const Small Med Big Imp
%   -4   -3   -2     -1   0       1   2   3   4
%%-------------------------------------------------------------------------
function dLabel = gradInt2gradLbl(intLbl)

    % Convert labels to ints
    if(intLbl==1.0)
        dLabel = 'bpos';
    elseif(intLbl==2.0)
        dLabel = 'mpos';
    elseif(intLbl==3.0)
        dLabel = 'spos';
    elseif(intLbl==4.0)
        dLabel = 'bneg';
    elseif(intLbl==5.0)
        dLabel = 'mneg';
    elseif(intLbl==6.0)
        dLabel = 'sneg';
    elseif(intLbl==7.0)
        dLabel = 'cons';
    elseif(intLbl==8.0)
        dLabel = 'pimp';
    elseif(intLbl==9.0)
        dLabel = 'nimp';
    elseif(intLbl==10)
        dLabel = 'none';
    else
        dLabel = 'none';
    end    
end