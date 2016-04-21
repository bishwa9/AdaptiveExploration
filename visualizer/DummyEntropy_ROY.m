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
radius = siz/10;
% End of example parameters
%%%%%%%%%%%%%%%%%%%%%

% Run Simulation
[classmap, valuemap, truevalue] = simulator...
    (ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare);

sample_set = [];

runs = 2;

figure_featureSpace = figure;
figure_Entropy = figure;
figure_dist = figure;

% k-means
x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
feature_vector_new = [x_.';y_.';z_.'].';

for iter = 1:runs
[~,centers,~,dists] = kmeans(feature_vector_new,nclasses);
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

%rover samples
rov_sample = truevalue(I1, I2, :);
sample_set = vertcat(sample_set, ...
                reshape(rov_sample, [1 size(rov_sample,3)]));
overlap_sample = reshape(rov_sample(:,:,1:3), [1, nvisiblechans]);
old_sample = reshape(valuemap(I1,I2,:), [1, nvisiblechans]);

%move close by points in feature space
move_vector = overlap_sample - old_sample;
move_vector = repmat(move_vector, siz*siz, 1);
[~,cluster_ind] = min(dists(max_entropy_point_ind,:));
d = dists(max_entropy_point_ind, cluster_ind);
sigma = 0.06*(max(dists(max_entropy_point_ind,:)) - d);
cov_mat = sigma*eye(nvisiblechans);
cov_mat_posDef = cov_mat'*cov_mat; %%%%% -> What does this do (look into later)
%define a filter around old_sample mean
x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
feature_vector = [x_.';y_.';z_.'].';
positivedefinite = all(eig(cov_mat_posDef) > 0);
gausian_filter = mvnpdf(feature_vector,old_sample,cov_mat_posDef);
gausian_filter = repmat(gausian_filter, 1, nvisiblechans);
gausian_filter = gausian_filter./max(max(gausian_filter));
move_vector_scaled = gausian_filter.*move_vector;
%move_vector_scaled = move_vector_scaled/norm(move_vector_scaled,Inf);

%update satellite map with rover's sample
feature_vector_new = feature_vector + move_vector_scaled;

if iter == 1
figure(figure_featureSpace);
% scatter3(centers(:,1), centers(:,2), centers(:,3)); hold on;
scatter3(feature_vector_new(:,1), feature_vector_new(:,2), feature_vector_new(:,3), 'r'); hold on;
scatter3(feature_vector(:,1), feature_vector(:,2), feature_vector(:,3), 'g');
legend('after sample', 'before sample');
title('Rover sample in feature space');
xlabel('Channel 1'); ylabel('Channel 2'); zlabel('Channel 3');
figure(figure_dist);
quiver3(feature_vector(:,1),feature_vector(:,2),feature_vector(:,3),move_vector_scaled(:,1),move_vector_scaled(:,2),move_vector_scaled(:,3))
title('Movement of each point in three features');
xlabel('Channel 1'); ylabel('Channel 2'); zlabel('Channel 3');
end

figure(figure_Entropy);
subplot(runs,1,iter);
title('recomputed entropy');
surf(entropy_dinv);
xlabel('X'); ylabel('Y'); zlabel('Entropy');

%recompute distances to centers
% overlap_sample_reshape = sample_set(iter, 1:3);
% 
% for i = 1:nclasses
% %     disp('Before:');
% %     dists(max_entropy_point_ind, i)
%     dists(max_entropy_point_ind, i) = ...
%                         pdist2(overlap_sample_reshape, centers(i,:));
% %     disp('After:');
% %     dists(max_entropy_point_ind, i)
% end

% entropy_diff = entropy_dinv - entropy_dminus;
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

