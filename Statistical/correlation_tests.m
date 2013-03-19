% Generates several line plots from gradient (almost) 0 to 1000 with
% normal gaussian noise. Fit's line to each gradient. Examines correlation
% of coefficient. 
function correlation_tests

    % Create your indepdendent variable
    x=-10:0.2:10;

    % Differeng gradients for y. 
    y0 = x*0.001;   % Baseline

    % Generate increasing gradients
    y025=0.25*x+0.25*randn(length(x),1)';
    y050=0.50*x+0.50*randn(length(x),1)';
    y075=0.75*x+0.75*randn(length(x),1)';
    y100=1.00*x+1.00*randn(length(x),1)';
    y125=1.25*x+1.25*randn(length(x),1)';
    y150=1.50*x+1.50*randn(length(x),1)';
    y175=1.75*x+1.75*randn(length(x),1)';
    y200=2.00*x+2.00*randn(length(x),1)';
    y1M =1000*x+1000*randn(length(x),1)';   % Extreme

%% Compute polyval
    p0   = polyfit(x,y0,  1);
    p025 = polyfit(x,y025,1);
    p050 = polyfit(x,y050,1);
    p075 = polyfit(x,y075,1);
    p100 = polyfit(x,y100,1);
    p125 = polyfit(x,y125,1);
    p150 = polyfit(x,y150,1);    
    p175 = polyfit(x,y175,1);
    p200 = polyfit(x,y200,1);
    p1M = polyfit(x,y1M,1);

%% Compute polyval
    p0fit   = polyval(p0,x);
    p025fit = polyval(p025,x);
    p050fit = polyval(p050,x);
    p075fit = polyval(p075,x);
    p100fit = polyval(p100,x);
    p125fit = polyval(p125,x);
    p150fit = polyval(p150,x);
    p175fit = polyval(p175,x);
    p200fit = polyval(p200,x);
    p1Mfit = polyval(p1M,x);

%% Plot
    figure, grid on, axis([-10 10 -10 10]);
    hold on, scatter(x,y0,  'r'); plot(x,  p0fit,'r');
    hold on, scatter(x,y025,'g'); plot(x,p025fit,'g');
    hold on, scatter(x,y050,'b'); plot(x,p050fit,'b');
    hold on, scatter(x,y075,'r'); plot(x,p075fit,'r');
    hold on, scatter(x,y100,'m'); plot(x,p100fit,'m');
    hold on, scatter(x,y125,'k'); plot(x,p125fit,'k');
    hold on, scatter(x,y150,'y'); plot(x,p150fit,'y');
    hold on, scatter(x,y175,'r'); plot(x,p175fit,'r');
    hold on, scatter(x,y200,'g'); plot(x,p200fit,'g');
    hold on, scatter(x,y1M, 'b'); plot(x,p1Mfit, 'b');

%% Compute correlation coefficients
    c025 = corrcoef(p0fit,   y025)
    c050 = corrcoef(p025fit, y050)
    c075 = corrcoef(p050fit, y075)
    c100 = corrcoef(p075fit, y100)
    c125 = corrcoef(p100fit, y125)
    c150 = corrcoef(p125fit, y150)
    c175 = corrcoef(p150fit, y175)
    c200 = corrcoef(p200fit, y200)
    c1M  = corrcoef(p1Mfit,  y1M)
    
    % With the level of noise found above, all correlations are about 98%
    % or above. 
    
%% Compute determination coefficients R^2
% The coefficient of determination is the ratio of the explained
% variation to the total variation (sum of variances). The coefficient of
% determination is such that 0 < r^ 2 < 1, and denotes
% the strength of the linear association between x and y. 

% r, called the linear correlation coefficient, measures the strength
% and the direction of a linear relationship between two variables.

% Hence, the coefficient of determination, r^2, is useful
% because it gives the proportion of the variance (fluctuation) of
% one variable that is predictable from the other variable.
 
% The coefficient of determination represents the percent of
% the data that is the closest to the line of best fit. For
% example, if r = 0.7, then r^ 2 = 0.49, which means that
% 49% of the total variation in y can be explained by the linear
% relationship between x and y (as described by the regression
% equation). The other 51% of the total variation in y
% remains unexplained. 

% Hence, coefficient of determination help in interepretationa and
% comparision of corelation
% www.jalt.org/test/bro_16.htm

    R025 = determinationCoeff(p025fit, y025)
    R050 = determinationCoeff(p050fit, y050)
    R075 = determinationCoeff(p075fit, y075)
    R100 = determinationCoeff(p100fit, y100)
    R125 = determinationCoeff(p125fit, y125)
    R150 = determinationCoeff(p150fit, y150)
    R175 = determinationCoeff(p175fit, y175)
    R200 = determinationCoeff(p200fit, y200)
    R1M  = determinationCoeff(p1Mfit,  y1M)
        
end
