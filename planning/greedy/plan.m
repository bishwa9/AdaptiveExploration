function plan( start_config, goal_config, prior_map, window_size, dist_budget )


global path
global mapSize
global nclasses
mapSize=size(prior_map);

cur_config = start_config;
sampled = cur_config;
distTravelled = 0;

while 1==1
    %reached goal planning done.
    if sum(cur_config == goal_config) == 2
        break;
    end
    
    %create window around cur_config
    horizDim = floor( window_size(1,2)/2 );
    vertDim = floor( window_size(1,1)/2 );
    topLeft = [0,0];
    bottomRight = [0,0];
    %check limits
    %top left row
    if(cur_config(1,1)-vertDim) < 1
        topLeft(1,1) = 1;
    else
        topLeft(1,1) = cur_config(1,1) - vertDim;
    end
    %top left col
    if(cur_config(1,2)-horizDim) < 1
        topLeft(1,2) = 1;
    else
        topLeft(1,2) = cur_config(1,2)-horizDim;
    end
    %bottom left row
    if(cur_config(1,1)+vertDim)>size(prior_map,1)
        bottomRight(1,1) = size(prior_map,1);
    else
        bottomRight(1,1) = cur_config(1,1)+vertDim;
    end
    %bottom left row
    if(cur_config(1,2)+horizDim)>size(prior_map,2)
        bottomRight(1,2) = size(prior_map,2);
    else
        bottomRight(1,2) = cur_config(1,2)+horizDim;
    end
    
    %get full entropy map
    hmap = getHmap(sampled', prior_map);
    %hmap = getHmap(sampled', prior_map, nclasses); %fs
    
    %get max within window
    max_ = hmap(topLeft(1,1), topLeft(1,2));
    toSample = topLeft;
    for r = topLeft(1,1):bottomRight(1,1)
        for c = topLeft(1,2):bottomRight(1,2)
            if hmap(r,c) > max_ && sum(ismember(sampled, [r,c], 'rows')) == 0
                max_ = hmap(r,c);
                toSample = [r,c];
            end
        end
    end
    
    %check if exploring after this feasible
    distToSample = pdist2(cur_config, toSample);
    distToGoal = pdist2(toSample, goal_config);
    distToGoalThruSample = distToSample + distToGoal;
    if distToGoal + distTravelled >= dist_budget
        sampled = [sampled; goal_config];
        cur_config = goal_config;
        distTravelled = distTravelled + distToGoal;
    else
        sampled = [sampled; toSample];
        cur_config = toSample;
        distTravelled = distTravelled + distToSample;
    end
    
end

path = [];
for i = 1:length(sampled)
    config = sampled(i, :);
    path = [path sub2ind(mapSize, config)];
end
end

