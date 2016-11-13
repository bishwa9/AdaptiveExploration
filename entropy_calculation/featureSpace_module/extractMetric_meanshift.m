function extractMetric_meanshift( numPoints_to_Sample, redo )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
addpath(genpath('../../matlab_sim'));
addpath(genpath('./helperFunctions'));
name = 'testData';
ext1 = '.mat';
for j = 1:10
    j
    % NOTE: I changed sensorvar to miscvar because there 
    %                       was no miscvar by two sensorvar
    file_name = sprintf('%s_%d%s',name, j, ext1);
    %%%%%%%%%%%%%%%%%%%%
    %   classmap -> true classification of each pixel
    %   valuemap -> channels accessible to the robot without sampling
    %               Basically the satellite map
    %   truevalue -> channels accesible to the robot after sampling
    %               Basically the data that is given to the rover once it
    %               samples
    %%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%
    % Example parameters. Comment this out if you want to use this as a function!
    ndomclasses = 6;
    nrareclasses = 4;
    nclasses = ndomclasses + nrareclasses;
    siz = 100;
    miscvar = .12; 
    sensorvar = .05;
    nchannels = 8;
    nvisiblechans = 3;
    probrare = 0.02;
    % End of example parameters
    %%%%%%%%%%%%%%%%%%%%%

    domeanShift = 1;
    visualize = 0;
    redoClustering = redo;
    numSamples = numPoints_to_Sample;
    elapsed_times = ones(1,numSamples);
    entropies = ones(siz,siz,numSamples);
    sampled_entropy = ones(numSamples, 1);

    disp 'Time to initialize'
    tic
    % struct_ = entropy_feature_space_init(visualize, domeanShift, ndomclasses,...
    %     nrareclasses, siz, miscvar, ...
    %     sensorvar, nchannels, nvisiblechans, probrare);
    struct_ = entropy_feature_space_init(visualize, domeanShift, file_name);
    toc
    x_ = struct_.valuemap(:,:,1);
    x_ = x_(:);
    y_ = struct_.valuemap(:,:,2);
    y_ = y_(:);
    z_ = struct_.valuemap(:,:,3);
    z_ = z_(:);
    inital_featureVector = [x_.';y_.';z_.'].';
    for i = 1:numSamples
    %     if mod(i,5) == 0
    %         redoClustering = 1;
    %     else
    %         redoClustering = 0;
    %     end
        pointToSample = struct_.max_entropy_point;
        tic
        struct_ = Entropy_feature_space(struct_, pointToSample, visualize, redoClustering, domeanShift);
        elapsed_times(1,i) = toc;
        entropies(:,:,i) = struct_.entropy_map;
    end

%     figure;
%     plot(elapsed_times);
%     title(strcat('Elapsed times', file_name));
%     figure;
%     for r = 1:siz
%         for c = 1:siz
%             if rand() < 0.3
%             ent = [struct_.initial_entropy_map(r,c), reshape(entropies(r,c,:),[1,numSamples])];
%             plot(ent);
%             hold on;
%             end
%         end
% %     end
%     title(strcat('Difference in Entropy of each point', file_name));
    figure;
    % subplot(1,2,1);
    % surf(struct_.entropy_map);
    % title('After sampling entropy map');
    % subplot(1,2,2);
    surf(struct_.entropy_map - struct_.initial_entropy_map);
    % title('initial entropy map');   

%     figure;
%     x_ = struct_.valuemap(:,:,1);
%     x_ = x_(:);
%     y_ = struct_.valuemap(:,:,2);
%     y_ = y_(:);
%     z_ = struct_.valuemap(:,:,3);
%     z_ = z_(:);
%     final_featureVector = [x_.';y_.';z_.'].';
%     scatter3(final_featureVector(:,1), final_featureVector(:,2), ...
%             final_featureVector(:,3), 'r'); 
%     hold on;
% 
%     scatter3(inital_featureVector(:,1), inital_featureVector(:,2), ...
%             inital_featureVector(:,3), 'b'); 
%     legend('final feature vector', 'initial feature vector');
%     title(strcat('feature movement', file_name));
end

end



