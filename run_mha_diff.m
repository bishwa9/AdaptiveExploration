function [path_followed, sampled_points, map_final] = ...
                    run_mha_diff(map_init, start_config, goal_config,...
                                budget_sample, budget_distance)

%% initialize run environment

eplsilon_ = 472.0649;

%% global variables for planning
global path;
global mapSize;

%% while wrapper around mha*
valuemap = map_init;
robot_cur_config = start_config;
plotPath = 0;
sample_set = zeros(budget_sample, 2); 
sample_num = 0;
dist_travelled = 0;
while (1==1)
    %% get initial plan
    plan(eplsilon_, valuemap, robot_cur_config, goal_config, plotPath);
    
    %% decide where to sample on the path (how?)
    sample_config = [1,1];
    sample_num = sample_num + 1;
    
    %% sample
    sample_set(sample_num, :) = sample_config;
    
    %% check budgets
    if( sample_num == budget_sample || ...
            dist_travelled + pdist2(sample_config, goal_config) >= budget_distance )
        % done
    end
    
    %% exit if done or replan
    if robot_cur_config == goal_config
        break;
    end
end

end