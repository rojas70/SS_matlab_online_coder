%%-------------------------------------------------------------------------
% actionInt2actionLbl
% a i d k pc nc c u
% 1 2 3 4 5  6  7 8
%%-------------------------------------------------------------------------
function actionLbl = actionInt2actionLbl(actionInt)

    % Convert labels to ints
    if(actionInt==1)
        actionLbl = 'a';    % alignment
    elseif(actionInt==2)
        actionLbl = 'i';    % increase
    elseif(actionInt==3)
        actionLbl = 'd';    % decrease
    elseif(actionInt==4)
        actionLbl = 'k';    % constant
    elseif(actionInt==5)
        actionLbl = 'pc';    % positive contact
    elseif(actionInt==6)
        actionLbl = 'nc';    % negative contact
    elseif(actionInt==7)
        actionLbl = 'c';    % contact
    elseif(actionInt==8)
        actionLbl = 'u';    % unstable
    else
        actionLbl = 'n';
    end    
end