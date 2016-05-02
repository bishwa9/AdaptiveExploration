global valuemap;
FitnessFunction = @plan; % Function handle to the fitness function
numberOfVariables = 1; % Number of decision variables
lb = 0.01; % Lower bound
ub = 1000; % Upper bound
A = []; % No linear inequality constraints
b = []; % No linear inequality constraints
Aeq = []; % No linear equality constraints
beq = []; % No linear equality constraints
options = gaoptimset('PopulationSize',20,'PlotFcns',{@gaplotpareto,@gaplotspread});
%[classmap, valuemap, truevalue] = simulator(6, 4, 100, 0.12, 0.05, 8, 3, 0.02);

[X,FVAL,EXITFLAG,OUTPUT,POPULATION] = gamultiobj(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub,options);


%     0.0659
%   596.8317
%   532.1141
%   596.8317
%   545.4867
%    38.8556
%   406.7250
