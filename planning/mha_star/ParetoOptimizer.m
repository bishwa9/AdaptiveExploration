global valuemap
global start_config
global goal_config
FitnessFunction = @pareto_plan; % Function handle to the fitness function
numberOfVariables = 1; % Number of decision variables
lb = 0; % Lower bound
ub = 1000; % Upper bound
A = []; % No linear inequality constraints
b = []; % No linear inequality constraints
Aeq = []; % No linear equality constraints
beq = []; % No linear equality constraints
options = gaoptimset('PopulationSize',50,'PlotFcns',{@gaplotpareto,@gaplotspread});
%[classmap, valuemap, truevalue] = simulator(6, 4, 100, 0.12, 0.05, 8, 3, 0.02);


addpath('../testConfigs/');
%addpath('../../entropy_calculation/featureSpace_module/real_code/');
addpath('../../entropy_calculation/differential_ent/');
addpath('../../planning/mha_star');
addpath('../../testData/realData');
addpath('../../testData/simData');

%% Get the data into the system
global path;
global mapSize;

%% Define variables
percRed = [];
redPerDist = [];
times = [];
pathLengths = [];
mapSizes = [];

%% Get Test configurations
fileID = fopen('prelimReal.txt','r');

line = fgetl(fileID)

while (line ~= -1)
    newCase = ~isempty( strfind(line, 'Test') );
    
    if newCase
        %% read test configuration
        path = [];
        fileName_line = strsplit(fgetl(fileID));
        fileName = fileName_line(1, 2);
        
        bounds_s_line = strsplit(fgetl(fileID));
        mapBounds = [str2double(bounds_s_line(2)), ...
                     str2double(bounds_s_line(3)), ...
                     str2double(bounds_s_line(4)), ...
                     str2double(bounds_s_line(5)), ...
                     str2double(bounds_s_line(6)), ...
                     str2double(bounds_s_line(7))];
        
        st_s_line = strsplit(fgetl(fileID));
        start_config = [str2double( st_s_line(2) ), ...
                        str2double( st_s_line(3) )];
        
        g_s_line = strsplit(fgetl(fileID));
        goal_config = [str2double( g_s_line(2) ), ...
                       str2double( g_s_line(3) )];
        
        %% start the planner
        load(fileName{1});
        valuemap = valuemap(mapBounds(1):mapBounds(2), ...
                            mapBounds(3):mapBounds(4), ...
                            mapBounds(5):mapBounds(6));
        plotPath = 1;
        tic;
        [X,FVAL,EXITFLAG,OUTPUT,POPULATION] = gamultiobj(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub,options);

        time_taken = toc;
        times = [times, time_taken];
        
    else
        disp 'PROBLEM IN FILE CONFIGURATION!';
        break;
    end
    
end


%% End
fclose(fileID);