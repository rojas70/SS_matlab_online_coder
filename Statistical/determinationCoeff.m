% The coefficient of determination of a linear regression model is the quotient 
% of the variances of the fitted values and observed values of the dependent variable.

function rsq = determinationCoeff(yfit,y)
    % Compute the residual values as a vector signed numbers:
    yresid = y - yfit;

    % Square the RESIDUALS "yfit"and total them obtain the residual sum of squares:
    SSresid = sum(yresid.^2);

    % Compute the total sum of squares of "y" by multiplying the variance of "y" by the number of observations minus 1:
    SStotal = (length(y)-1) * var(y);

    % Compute R2 using the formula given in the introduction of this topic:
    rsq = 1 - SSresid/SStotal;
end