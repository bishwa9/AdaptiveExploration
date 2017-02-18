function [ fitness] = pareto_plan( alpha )
%PARETO_PLAN Summary of this function goes here
%   Detailed explanation goes here
global valuemap
global start_config
global goal_config
plotPath=0
[fitness,~,~]= plan(alpha, valuemap, start_config, goal_config, plotPath);

end

