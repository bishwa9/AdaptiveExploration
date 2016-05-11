% NOTE: I changed sensorvar to miscvar because there 
%                       was no miscvar by two sensorvar

clear;
addpath(genpath('../../matlab_sim'));
addpath(genpath('./helperFunctions'));

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

domeanShift = 0;
visualize = 0;
redoClustering = 0;
numSamples = 100;
elapsed_times = ones(1,numSamples);
entropies = ones(siz,siz,numSamples);
sampled_entropy = ones(numSamples, 1);
points_sampled_k = zeros(numSamples,2);

disp 'Time to initialize'
tic
% struct_ = entropy_feature_space_init(visualize, domeanShift, ndomclasses,...
%     nrareclasses, siz, miscvar, ...
%     sensorvar, nchannels, nvisiblechans, probrare);
struct_ = entropy_feature_space_init(visualize, domeanShift, 'testData_1.mat');
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
    points_sampled_k(i,:) = pointToSample;
    tic
    struct_ = Entropy_feature_space(struct_, pointToSample, visualize, redoClustering, domeanShift, points_sampled_k(1:i, :));
    elapsed_times(1,i) = toc;
    entropies(:,:,i) = struct_.entropy_map;
end

figure;
plot(elapsed_times);
title('Elapsed times');
figure;
for r = 1:siz
    for c = 1:siz
        if rand() < 0.3
        ent = [struct_.initial_entropy_map(r,c), reshape(entropies(r,c,:),[1,numSamples])];
        plot(ent);
        hold on;
        end
    end
end
title('Entropy of each point');
figure;
% subplot(1,2,1);
% surf(struct_.entropy_map);
% title('After sampling entropy map');
% subplot(1,2,2);
surf(struct_.entropy_map - struct_.initial_entropy_map);
% title('initial entropy map');   

figure;
x_ = struct_.valuemap(:,:,1);
x_ = x_(:);
y_ = struct_.valuemap(:,:,2);
y_ = y_(:);
z_ = struct_.valuemap(:,:,3);
z_ = z_(:);
final_featureVector = [x_.';y_.';z_.'].';
scatter3(final_featureVector(:,1), final_featureVector(:,2), ...
        final_featureVector(:,3), 'r'); 
hold on;

scatter3(inital_featureVector(:,1), inital_featureVector(:,2), ...
        inital_featureVector(:,3), 'b'); 
legend('final feature vector', 'initial feature vector');
title('feature movement');