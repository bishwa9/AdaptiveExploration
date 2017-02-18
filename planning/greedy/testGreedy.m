addpath('../../testData/simData');


load testData_1.mat
start_config = [1,1];
goal_config = [100,1];
prior_map = valuemap;
window_size = [15,15];
dist_budget = pdist2(start_config, goal_config) * 1.5;

path = greedy_plan( start_config, goal_config, prior_map, window_size, dist_budget );
figure; hold on;
imagesc(valuemap);
scatter(path(:,2), path(:,1), 'r');