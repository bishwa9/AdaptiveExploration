clear;

addpath('../testConfigs/');
%addpath('../../entropy_calculation/featureSpace_module/real_code/');
addpath('../../entropy_calculation/differential_ent/');
%addpath('../../planning/mha_star');
addpath('../../planning/greedy');
addpath('../../testData/realData');
addpath('../../testData/simData');
addpath('../');

%% Get the data into the system
global path;
global mapSize;

%% Define variables
percRed = [];
redPerDist = [];
times = [];
pathLengths = [];
mapSizes = [];
errs = [];
errs_dec = [];

%% Get Test configurations
fileID = fopen('realData_smartTest100.txt','r');

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
        truevalue = valuemap;
        valuemap = valuemap(mapBounds(1):mapBounds(2), ...
                            mapBounds(3):mapBounds(4), ...
                            mapBounds(5):mapBounds(6));
        nclasses = 3;
        plotPath = 0;
        tic;
        %plan(472.0649, valuemap, start_config, goal_config, plotPath);
        dist_budget = pdist2(start_config, goal_config) * 1.5;
        window_size = [15,15];
        plan( start_config, goal_config, valuemap, window_size, dist_budget );
        time_taken = toc;
        times = [times, time_taken];
        
        %% sample at every point
        sampled = zeros(2,size(path,2));
        %define a filter around old_sample mean
        x_ = valuemap(:,:,1);
        x_ = x_(:);
        y_ = valuemap(:,:,2);
        y_ = y_(:);
        z_ = valuemap(:,:,3);
        z_ = z_(:);
        feature_vector = [x_.';y_.';z_.'].';
        
%         hmap = getHmap(start_config',valuemap);
%         Ent_begin = sum(sum(sum(hmap)));
        path_length = 0;
        for i=1:size(path,2)
            [x, y]= ind2sub(mapSize,path(i));
            config= [x y]';
            sampled(:, i) = config;
            feature_vector = update_fs(feature_vector, config, ...
                                        feature_vector(path(i),:), ...
                                        reshape(truevalue(x,y,1:size(feature_vector,2)), ...
                                        [1,size(feature_vector,2)]), 0);
            if i >= 2
                path_length = path_length + pdist2(sampled(:,i-1)', config');
            end
        end
        err_before = reconError(truevalue(:,:,1:size(valuemap,3)), valuemap, nclasses);
        valuemap = reshape(feature_vector, mapSize);
        %calculate reconstruction error
        err = reconError(truevalue(:,:,1:size(valuemap,3)), valuemap, nclasses);
        errs = [errs, err];
        errs_dec = [errs_dec, err_before-err];
        pathLengths = [pathLengths, path_length];
%         hmap = getHmap(sampled,valuemap);
%         Ent_end = sum(sum(sum(hmap)));
%         entropyRed = abs( Ent_end - Ent_begin );
% 
%         percentReduction = abs(entropyRed*100/Ent_begin);
%         percRed = [percRed, percentReduction];
% 
%         reductionPerdist = entropyRed/path_length;
%         redPerDist = [redPerDist, reductionPerdist];
%         
%         pathLengths = [pathLengths, path_length];
        
        line = fgetl(fileID); %skip a line
        line = fgetl(fileID)
    else
        disp 'PROBLEM IN FILE CONFIGURATION!';
        break;
    end
    
end

%% Plot Statistics
figure;
scatter(pathLengths, errs); title('Reconstruction Errors');
save('output_gkfs.mat', 'pathLengths', 'errs', 'errs_dec');
% figure;
% scatter([1:size(redPerDist,2)], redPerDist); title('Reduction per distance');
% figure;
% scatter([1:size(times,2)], times); title('Time of execution');

%% End
fclose(fileID);