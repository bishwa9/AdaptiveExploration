% NOTE: I changed sensorvar to miscvar because there 
%                       was no miscvar by two sensorvar

clear;
addpath(genpath('../matlab_sim'));

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

% Run Simulation
[classmap, valuemap, truevalue] = simulator...
    (ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare);

sample_set = [];

runs = 2;

% k-means
x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
Data = [x_.';y_.';z_.'].';

[~,centers,~,dists] = kmeans(Data,nclasses);

for iter = 1:runs
% Probability and Entropy
sums = sum(dists,2);
info = dists;
info2 = dists;
prob = dists.^-1;
prob2 = dists; 
for i = 1:siz*siz
    prob(i,:) = dists(i,:) / sums(i,1);
    
    prob2(i,:) = 1 - ( dists(i,:) / sums(i,1) );
    prob2(i,:) = prob2(i,:) / ( nclasses-1 );
    
    info(i,:) = -1.0*prob(i,:).*log2(prob(i,:));
    info2(i,:) = -1.0*prob2(i,:).*log2(prob2(i,:));
end

entropy_dinv = sum(info,2); entropy_dminus = sum(info2,2);
entropy_dinv = reshape(entropy_dinv,100,100); entropy_dminus = reshape(entropy_dminus,100,100);

[max_entropy_point_val, max_entropy_point_ind] = max(entropy_dinv);
max_entropy_point_ind = datasample(max_entropy_point_ind,1);
[I1, I2] = ind2sub(size(entropy_dinv),max_entropy_point_ind);

rov_sample = truevalue(I1, I2, :);
sample_set = vertcat(sample_set, ...
                reshape(rov_sample, [1 size(rov_sample,3)]));
overlap_sample = rov_sample(:,:,1:3);
valuemap(I1,I2,:) = overlap_sample;

if iter == 1
    figure;
end
title('recomputed entropy');
subplot(runs,1,iter);
surf(entropy_dinv);

% entropy_diff = entropy2 - entropy;
% figure;
% title('1-dist for probability');
% subplot(2,2,1);
% surf(entropy);
% title('Entropy_1/d');
% subplot(2,2,2);
% surf(entropy2);
% title('Entropy_1-d');
% subplot(2,2,3);
% surf(entropy_diff);
% title('entropy_diff');
% subplot(2,2,4);
% surf(classmap);
% title('Classmap');

end
