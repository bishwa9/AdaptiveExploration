clear;
addpath(genpath('../../matlab_sim'))

%% Package Data
%%%%%%%%%%%%%%%%%%%%%
% Parameters for test 1
ndomclasses = 2;
nrareclasses = 0;
nclasses = ndomclasses + nrareclasses;
siz = 100;
miscvar = 0; 
sensorvar = 0;
nchannels = 8;
nvisiblechans = 3;
probrare = 0;

[classmap, valuemap, truevalue] = simulator...
            (ndomclasses, nrareclasses, siz, miscvar, ...
            sensorvar, nchannels, nvisiblechans, probrare);
        
x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
feature_vector = [x_.';y_.';z_.'].';

%% kmeans
[memberships,centers,~,dists] = kmeans(feature_vector,nclasses);
kmeans_memeberships = reshape(memberships, siz, siz);

%mahalanobis distance
Cov_mats = zeros(size(centers,2), size(centers,2), size(centers,1)); %each cluster has a covariance
mahal_dist = zeros(size(feature_vector,1), size(centers,1));
prob = zeros( size(feature_vector,1), nclasses );
for i = 1:size(centers,1)
    indices = find( memberships == i );
    cluster_members = feature_vector(indices(:,1),:);
    Cov_mats(:,:,i) = cov(cluster_members);
    
    prob(:, i) = mvnpdf(feature_vector, centers(i,:), Cov_mats(:, :, i));
    
    %mahal_dist(:,i) = pdist2(feature_vector, centers(i,:), 'mahalanobis', Cov_mats(:,:,i));
end

sum_ = sum(prob, 2);
sum_ = repmat(sum_, [1, nclasses]);
prob = prob ./ sum_;
info_scaled = zeros(size(prob));
for i = 1:size(prob,1)
    % Information of the feature 
    %(multiplied by prob - to get expected info for entropy calculation)
    info_scaled(i,:) = -1.0*prob(i,:).*log2(prob(i,:));    
end

% Average information (aka. Entropy)
entropies = sum(info_scaled,2); 

entropy = reshape(entropies,siz,siz); 

%entropy calculation
%[prob, entropy] = calc_entropy(mahal_dist); 

%info = log2(1./prob);

 figure;
% subplot(3,2,1); plot(mahal_dist(:,1)); title('Distance with respect to c1');
% subplot(3,2,2); plot(mahal_dist(:,2)); title('Distance with respect to c2');
 subplot(1,2,1); plot(prob(:,1)); title('Probability With respect to c1 kMEANS');
 subplot(1,2,2); plot(prob(:,2)); title('Probability With respect to c2 kMEANS');
% subplot(3,2,5); plot(info(:,1)); title('Information With respect to c1');
% subplot(3,2,6); plot(info(:,2)); title('Information With respect to c2');
entropy = reshape(entropy,siz,siz); 
figure; surf(entropy); title('Entropies of every point kMEANS');

%[x, y, z] = ellipsoid(centers(1,1),centers(1,2),centers(1,3),Cov_mats(1,1,1), Cov_mats(2,2,1), Cov_mats(3,3,1), 30);
%figure; hold on;
%surf(x, y, z); title('Covariance cluster 1');

%[x1, y1, z1] = ellipsoid(centers(2,1),centers(2,2),centers(2,3),Cov_mats(1,1,2), Cov_mats(2,2,2), Cov_mats(3,3,2), 30);

%surf(x1, y1, z1); title('Covariance cluster 2');
%entropy = reshape(entropy,siz,siz); 
        
%plots
%figure; 
%subplot(1,2,1); surf(classmap); title('True classification');
%subplot(1,2,2); surf(kmeans_memeberships); title('kmeans');

%figure
%subplot(1,2,1); surf(classmap); title('True classification');
%subplot(1,2,2); surf(entropy); title('Entropy');

% scatter3(feature_vector(:,1), feature_vector(:,2), ...
%     feature_vector(:,3), 'g');
% title('feature space');
% xlabel('Channel 1'); ylabel('Channel 2'); zlabel('Channel 3');
% Test 1 end
%%%%%%%%%%%%%%%%%%%%%

%% GMM

options = statset('Display','final');
obj = gmdistribution.fit(feature_vector,nclasses,'Options',options);

prob = zeros( size(feature_vector,1), nclasses );

for k = 1:nclasses
    prob(:, k) = mvnpdf(feature_vector, obj.mu(k, :), obj.Sigma(:, :, k));
end

sum_ = sum(prob, 2);
sum_ = repmat(sum_, [1, nclasses]);
prob = prob ./ sum_;
info_scaled = zeros(size(prob));
for i = 1:size(prob,1)
    % Information of the feature 
    %(multiplied by prob - to get expected info for entropy calculation)
    info_scaled(i,:) = -1.0*prob(i,:).*log2(prob(i,:));    
end

figure;
subplot(1,2,1); plot(prob(:,1)); title('Probability GMM w.r.t. c1'); xlabel('Point'); ylabel('Prob in c1');
subplot(1,2,2); plot(prob(:,2)); title('Probability GMM w.r.t. c2'); xlabel('Point'); ylabel('Prob in c2');

% Average information (aka. Entropy)
entropies = sum(info_scaled,2); 

entropy = reshape(entropies,siz,siz); 
figure;
surf(entropy); title('Entropy GMM');

figure;
scatter3(feature_vector(:,1), feature_vector(:,2), ...
     feature_vector(:,3), 'g');
title('feature space');
xlabel('Channel 1'); ylabel('Channel 2'); zlabel('Channel 3');
