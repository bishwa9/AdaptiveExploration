% NOTE: I changed sensorvar to miscvar because there 
%                       was no miscvar by two sensorvar

clear;
addpath(genpath('../../matlab_sim'));
addpath(genpath('./helperFunctions'));
numFiles = 10;

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
nclasses = 10;
siz = 200;
miscvar = .12; 
sensorvar = .05;
nchannels = 8;
nvisiblechans = 3;
numSamples = 1;
visualize = 1;
redoClustering = 0;
% End of example parameters
%%%%%%%%%%%%%%%%%%%%%
name = 'testData';
ext1 = '.mat';
sampled_k = zeros(numSamples, 2, 10);
avg_ent_k = zeros(1,numSamples,10);
sampled_ms = zeros(numSamples, 2, 10);
avg_ent_ms = zeros(1,numSamples,10);
for j = 1:numFiles
file_name = sprintf('%s_%d%s',name, j, ext1);
domeanShift = 0;
elapsed_times = ones(1,numSamples);
ent_k = zeros(1,numSamples);
sampled_entropy = ones(numSamples, 1);
points_sampled_k = zeros(numSamples,2);

disp 'Time to initialize'
tic
% struct_ = entropy_feature_space_init(visualize, domeanShift, ndomclasses,...
%     nrareclasses, siz, miscvar, ...
%     sensorvar, nchannels, nvisiblechans, probrare);
struct_k = entropy_feature_space_init(visualize, domeanShift, file_name);
toc
for i = 1:numSamples
%     if mod(i,5) == 0
%         redoClustering = 1;
%     else
%         redoClustering = 0;
%     end
if i >= 2
    if struct_k.max_entropy_point == points_sampled_k(i-1,:)
        disp('hi');
    end
end

    pointToSample = struct_k.max_entropy_point;
    points_sampled_k(i,:) = pointToSample;
    tic
    struct_k = Entropy_feature_space(struct_k, pointToSample, visualize, redoClustering, domeanShift, points_sampled_k(1:i, :));
    elapsed_times(1,i) = toc;
    ent_k(1,i) = sum(sum(struct_k.entropy_map)) / siz*siz;
end
%%
domeanShift = 1;
ent_ms = zeros(1,numSamples);
points_sampled_ms = zeros(numSamples, 2);
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
    points_sampled_ms(i,:) = pointToSample;
    tic
    struct_ = Entropy_feature_space(struct_, pointToSample, visualize, redoClustering, domeanShift, points_sampled_ms(1:i, :));
    elapsed_times(1,i) = toc;
    ent_ms(1,i) = sum(sum(struct_.entropy_map)) / siz*siz;
end

figure;
hold on;
imagesc(struct_k.classmap);
plot(points_sampled_k(:,1), points_sampled_k(:,2), 'k', 'LineWidth', 3);

figure;
hold on;
imagesc(struct_.classmap);
plot(points_sampled_ms(:,1), points_sampled_ms(:,2), 'k', 'LineWidth', 3);

sampled_k(:,:, j) = points_sampled_k;
sampled_ms(:,:, j) = points_sampled_ms;
avg_ent_k(:,:, j) = ent_k;
avg_ent_ms(:,:, j) = ent_ms;
end

%%
dec_k = [];
dec_ms = [];
figure_kmeans = figure;
hold on;
figure_ms = figure;
hold on;
for i =1:numFiles
figure(figure_kmeans);
plot(avg_ent_k(:,:,i), 'k');
dec = avg_ent_k(1,end,i) - avg_ent_k(1,1,i);
dec = (dec /  avg_ent_k(1,1,i)) * 100;
dec_k = [dec_k, dec];
figure(figure_ms);
plot(avg_ent_ms(:,:,i), 'r');
dec = avg_ent_ms(1,end,i) - avg_ent_ms(1,1,i);
dec = (dec /  avg_ent_ms(1,1,i)) * 100;
dec_ms = [dec_ms, dec];
end
figure(figure_kmeans);
xlabel('sample number');
ylabel('average entropy');
title('Kmeans');
figure(figure_ms);
xlabel('sample number')
ylabel('average entropy');
title('Meanshift');

fprintf('Average percent change kmeans: %.02f\n', mean(dec_k));
fprintf('Average percent change meanshift: %.02f\n', mean(dec_ms));