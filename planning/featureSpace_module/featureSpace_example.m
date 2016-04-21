% NOTE: I changed sensorvar to miscvar because there 
%                       was no miscvar by two sensorvar

clear;
addpath(genpath('../../matlab_sim'));

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
radius = siz/10;
% End of example parameters
%%%%%%%%%%%%%%%%%%%%%

visualize = 0;
redoClustering = 0;
numSamples = 100;
elapsed_times = ones(1,numSamples);
entropies = ones(siz,siz,numSamples);
sampled_entropy = ones(numSamples, 1);

disp 'Time to initialize' 
tic
struct_ = entropy_feature_space_init(ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare, visualize);
toc
for i = 1:numSamples
    pointToSample = struct_.max_entropy_point;
    tic
    struct_ = Entropy_feature_space(struct_, pointToSample, visualize, redoClustering);
    elapsed_times(1,i) = toc;
    entropies(:,:,i) = struct_.entropy_map;
end

figure;
plot(elapsed_times);
title('Elapsed times');
figure;
for r = 1:siz
    for c = 1:siz
        if rand() < 0.05
        ent = reshape(entropies(r,c,:),[1,numSamples]);
        plot(ent);
        hold on;
        end
    end
end
title('Entropy of each point');
figure;
subplot(1,2,1);
surf(struct_.entropy_map);
title('After sampling entropy map');
subplot(1,2,2);
surf(struct_.initial_entropy_map);
title('initial entropy map');                                     