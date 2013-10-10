% AIFbixexpfithelper is a wrapper function to fit the AIF to a biexponential model

%{

AIFbiexpcon.m is the file defining the function. You can of course alter
this as you wish

out is the fitted timecurve over the desired time interval
x is the parameters of the fit
xdata stores the input parameters of the fit

%}

function [out x xdata] = AIFbiexpfithelp(xdata, voxel)

warning off

Cp = xdata{1}.Cp;
Cp = Cp(:);

t  = xdata{1}.timer;
oldt= t;
oldt = oldt(:);

xdata{1}.timer = t;
t  = t(:);

%configure the optimset for use with lsqcurvefit
options = optimset('lsqcurvefit');

%increase the number of function evaluations for more accuracy
options.MaxFunEvals = 1000;
options.MaxIter     = 1000;
options.TolFun      = 10^(-20);
options.TolX        = 10^(-20);
options.Diagnostics = 'off';
options.Display     = 'off';
options.Algorithm   = 'levenberg-marquardt';

% Choose upper and lower bounds only for trust-region methods.
lb = [0 0 0 0];
ub = [5 5 5 5];

%% Split the fitting between the biexponential phase and the linear phase
t = oldt;
figure, plot(t, Cp, 'b.'), title('choose the max');

%[x y] = ginput(1);
x = 1;
temp = abs(x-t);

ind  = find(temp == min(temp));

timer = t;
start = xdata{1}.step;
ended = start(2);
start = start(1);

starter1 = find(abs(timer - start) == min(abs(timer - start)));
ender   = find(abs(timer - ended) == min(abs(timer - ended)));

step = zeros(size(timer));
step(starter1:ender) = 1;

xdata{1}.step = step;


hold on, 

% W is the weighting matrix, should you want to emphasise certain
% datapoints
W = ones(size(Cp));
WW= sort(Cp.*step, 'descend');
size(WW)
size(Cp)
ind(1) = find(Cp == WW(1));
ind(2) = find(Cp == WW(2));
ind(3) = find(Cp == WW(3));

step(ind(1)+1:end) = 0;

xdata{1}.step = step;
plot(t,step, 'r'),

plot(t(ind(1)), Cp(ind(1)), 'kx', 'MarkerSize', 30);

% Alter the weightings here.
W(ind(1)) =1;
W(ind(1)+1)= 1;
W(ind(1)-1)= 1;

plot(t, W, 'gx');

maxer = Cp(ind(1));

xdata{1}.maxer = maxer;
Cp = Cp.*W;

% Currently, we use AIF
[x,resnorm,residual,exitflag,output,lambda,jacobian] = lsqcurvefit(@AIFbiexpcon, ...
    [1 1 1 1], xdata, ...
    Cp','','',options);

x
xdata{1}.timer = oldt;

rsquare = 1 - resnorm / norm(Cp-mean(Cp))^2

out = AIFbiexpcon(x, xdata);



