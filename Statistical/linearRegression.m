function [corrMat rsq]=linearRegression(x,y)

% You can derive R2 from the coefficients of a polynomial regression to
% determine how much variance in y a linear model explains, as the following example describes: 
% Create two variables, x and y from the first two columns of the count
% variable in the demo data file count.dat:

% Use polyfit to compute a linear regression that predicts y from x:
p = polyfit(x,y,1); % p(1) is the slope and p(2) is the intercept of the linear predictor. You can also obtain regression coefficients using the Basic Fitting GUI.

% Call polyval to use p to predict y, calling the result yfit:
yfit = polyval(p,x);    % Using polyval saves you from typing the fit equation yourself, which in this case looks like:
                        % yfit =  p(1) * x + p(2);

% Compute the residual values as a vector signed numbers:
yresid = y - yfit;  % Square the residuals and total them obtain the residual sum of squares:

%% Correlation Data
% Square residual
SSresid = sum(yresid.^2);           % Compute the total sum of squares of y by multiplying the variance of y by the number of observations minus 1:
SStotal = (length(y)-1) * var(y);   % Compute R2 using the formula given in the introduction of this topic:
rsq = 1 - SSresid/SStotal;          % This demonstrates that the linear equation 1.5229 * x -2.1911 predicts 87% of the variance in the variable y.

% Correlation Coefficient
corrMat=corrcoef(y,yfit);          % How much does that normal data and the fitted data correlate
%% Compare data plots
hold on, scatter(x,y,'linewidth',1.75);
plot(x,yfit,'r','linewidth',1.75);
xlabel('Independent Variable'); ylabel('Dependent Variable'); title('Comparison between regular data and fit data')
grid on