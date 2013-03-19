%%-------------------------------------------------------------------------
% actionLbl2actionInt
% a i d k pc nc c u
% 1 2 3 4 5  6  7 8
%%-------------------------------------------------------------------------
function actionInt=actionLbl2actionInt(actionLbl)

    % Convert labels to ints
    if(strcmp(actionLbl,'a'))           % alignment
        actionInt = 1;
    elseif(strcmp(actionLbl,'i'))       % increase
        actionInt = 2;
    elseif(strcmp(actionLbl,'d'))       % decrease
        actionInt = 3;
    elseif(strcmp(actionLbl,'k'))       % constant
        actionInt = 4;
    elseif(strcmp(actionLbl,'p'))       % positive contact, pc
        actionInt = 5;
    elseif(strcmp(actionLbl,'n'))       % negative contact, nc
        actionInt = 6;
    elseif(strcmp(actionLbl,'c'))       % contact, c
        actionInt = 7;
    elseif(strcmp(actionLbl,'u'))       % unstable, u
        actionInt = 8;
    else
        actionInt = -1;
        % error('motcomps:primeval:cleanup','actionLbl2actionInt:Error');        
    end    
end