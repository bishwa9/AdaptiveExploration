FitnessFunction = @plan; % Function handle to the fitness function
numberOfVariables = 1; % Number of decision variables
lb = 100; % Lower bound
ub = 105; % Upper bound
A = []; % No linear inequality constraints
b = []; % No linear inequality constraints
Aeq = []; % No linear equality constraints
beq = []; % No linear equality constraints
options = gaoptimset('PopulationSize',60,'PlotFcns',@gaplotpareto);
gamultiobj(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub,options);