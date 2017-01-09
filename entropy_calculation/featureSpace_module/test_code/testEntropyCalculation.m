clear;
addpath(genpath('../../../util'))
addpath(genpath('../../../testData/simData/'))

%% Package Data
%%%%%%%%%%%%%%%%%%%%%
%Parameters for test 1
ndomclasses = 2;
nrareclasses = 0;
nclasses = ndomclasses + nrareclasses;
siz = 100;
miscvar = 0; 
sensorvar = 0.01;
nchannels = 8;
nvisiblechans = 3;
probrare = 0;

[classmap, valuemap, truevalue] = simulator...
            (ndomclasses, nrareclasses, siz, miscvar, ...
            sensorvar, nchannels, nvisiblechans, probrare);


%load('testData_1.mat');
x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
feature_vector = [x_.';y_.';z_.'].';


%% Maximum entropy sampling
for i = 1:10
    %% Entropy Calculation
[memberships,centers,~,dists] = kmeans(feature_vector,nclasses);
kmeans_memeberships = reshape(memberships, siz, siz);

[prob, entropy] = calc_entropy(centers, kmeans_memeberships, feature_vector, siz);

%% Entropy Update

max_entropy_point_val = max(max(entropy));
max_entropy_point_ind = find(entropy == max_entropy_point_val);
[I1, I2] = ind2sub(size(entropy),max_entropy_point_ind);
pointToSample = [I1, I2];

rov_sample = truevalue(I1, I2, :);
true_sample = reshape(rov_sample(:,:,1:3), [1, nvisiblechans]);
noisy_sample = reshape(valuemap(I1,I2,:), [1, nvisiblechans]);

[feature_vector_new] = update_fs(feature_vector, pointToSample, noisy_sample, true_sample, 1);
[prob, entropy] = calc_entropy(centers, kmeans_memeberships, feature_vector_new, siz);

%update satellite map with rover's sample
figure;
scatter3(feature_vector_new(:,1), feature_vector_new(:,2), ...
        feature_vector_new(:,3), 'r'); hold on;
scatter3(feature_vector(:,1), feature_vector(:,2), ...
        feature_vector(:,3), 'g');
legend('New', 'Old');
quiver3(feature_vector(:,1),feature_vector(:,2),feature_vector(:,3), ...
        feature_vector_new(:,1)-feature_vector(:,1),...
        feature_vector_new(:,2)-feature_vector(:,2),...
        feature_vector_new(:,3)-feature_vector(:,3),0, 'LineWidth',2);
move_vector_scaled = feature_vector_new - feature_vector;
move_vector_scaled = reshape(move_vector_scaled, [10000, 1, 3]);
move_vector_scaled = reshape(move_vector_scaled, [100, 100, 3]);
move_vector_scaled = 100 * move_vector_scaled;
figure; subplot(1,2,1); imagesc(move_vector_scaled); subplot(1,2,2); imagesc(valuemap);

end

% Gaussian kernel in feature space
% sample pointToSample
% max_entropy_point_val = max(max(entropy));
% max_entropy_point_ind = find(entropy == max_entropy_point_val);
% [I1, I2] = ind2sub(size(entropy),max_entropy_point_ind);
% 
% rov_sample = truevalue(I1, I2, :);
% overlap_sample = reshape(rov_sample(:,:,1:3), [1, nvisiblechans]);
% old_sample = reshape(valuemap(I1,I2,:), [1, nvisiblechans]);
% 
% % reconfigure feature space
% move_vector_orig = overlap_sample - old_sample;
% move_vector = repmat(move_vector_orig, siz*siz, 1);
% pointToSample_ind = sub2ind([siz, siz], I1, I2);
% sigma = 0.01;
% cov_mat = sigma*eye(nvisiblechans);
% cov_mat_posDef = cov_mat'*cov_mat; %%%%% -> What does this do (look into later)
% %define a filter around old_sample mean
% x_ = valuemap(:,:,1);
% x_ = x_(:);
% y_ = valuemap(:,:,2);
% y_ = y_(:);
% z_ = valuemap(:,:,3);
% z_ = z_(:);
% feature_vector = [x_.';y_.';z_.'].';
% positivedefinite = all(eig(cov_mat_posDef) > 0);
% if positivedefinite ~= 1
%     error('Covariance matrix incorrect')
% end
% %gaussian_filter = fspecial('Gaussian',[1 10000],sigma);
% gaussian_filter = mvnpdf(feature_vector,old_sample,cov_mat_posDef);
% gaussian_filter = repmat(gaussian_filter, 1, nvisiblechans);
% gaussian_filter = gaussian_filter./max(max(gaussian_filter));
% move_vector_scaled = gaussian_filter.*move_vector;
% %move_vector_scaled = move_vector_scaled/norm(move_vector_scaled,Inf);
% 
% %update satellite map with rover's sample
% feature_vector_new = feature_vector + move_vector_scaled;
% figure;
% scatter3(feature_vector_new(:,1), feature_vector_new(:,2), ...
%         feature_vector_new(:,3), 'r'); hold on;
% scatter3(feature_vector(:,1), feature_vector(:,2), ...
%         feature_vector(:,3), 'g');
% legend('New', 'Old');
% quiver3(feature_vector(:,1),feature_vector(:,2),feature_vector(:,3), ...
%         move_vector_scaled(:,1),move_vector_scaled(:,2),move_vector_scaled(:,3),0, 'LineWidth',2)
    

% Gaussian kernel in physical space
% sample pointToSample
% max_entropy_point_val = max(max(entropy));
% max_entropy_point_ind = find(entropy == max_entropy_point_val);
% [I1, I2] = ind2sub(size(entropy),max_entropy_point_ind);
% pointToSample = [I1, I2];
% 
% rov_sample = truevalue(I1, I2, :);
% overlap_sample = reshape(rov_sample(:,:,1:3), [1, nvisiblechans]);
% old_sample = reshape(valuemap(I1,I2,:), [1, nvisiblechans]);
% 
% % reconfigure feature space
% move_vector_orig = overlap_sample - old_sample;
% move_vector = repmat(move_vector_orig, siz*siz, 1);
% 
% [x,y] = meshgrid(1:siz, 1:siz);
% twoD_space = zeros(siz, siz, 2);
% twoD_space(:,:,2) = x;
% twoD_space(:,:,1) = y;
% twoD_space = reshape(twoD_space, [siz*siz, 2]);
% sigma = 1;
% cov_mat = sigma*eye(2);
% 
% gaussian_filter = mvnpdf(twoD_space,pointToSample,cov_mat);
% gaussian_filter = repmat(gaussian_filter, 1, 3);
% gaussian_filter = gaussian_filter./max(max(gaussian_filter));
% move_vector_scaled = gaussian_filter.*move_vector;
% %move_vector_scaled = move_vector_scaled/norm(move_vector_scaled,Inf);
% 
% %update satellite map with rover's sample
% feature_vector_new = feature_vector + move_vector_scaled;
% figure;
% scatter3(feature_vector_new(:,1), feature_vector_new(:,2), ...
%         feature_vector_new(:,3), 'r'); hold on;
% scatter3(feature_vector(:,1), feature_vector(:,2), ...
%         feature_vector(:,3), 'g');
% legend('New', 'Old');
% quiver3(feature_vector(:,1),feature_vector(:,2),feature_vector(:,3), ...
%         move_vector_scaled(:,1),move_vector_scaled(:,2),move_vector_scaled(:,3),0, 'LineWidth',2);
%     
% move_vector_scaled = reshape(move_vector_scaled, [10000, 1, 3]);
% move_vector_scaled = reshape(move_vector_scaled, [100, 100, 3]);
% move_vector_scaled = 100 * move_vector_scaled;
% figure; subplot(1,2,1); imagesc(move_vector_scaled); subplot(1,2,2); imagesc(valuemap);

% independent points


%% Previous code!
%entropy calculation
%[prob, entropy] = calc_entropy(mahal_dist); 

%info = log2(1./prob);

% figure;
% subplot(3,2,1); plot(mahal_dist(:,1)); title('Distance with respect to c1');
% subplot(3,2,2); plot(mahal_dist(:,2)); title('Distance with respect to c2');
% subplot(1,2,1); plot(prob(:,1)); title('Probability With respect to c1 kMEANS');
% subplot(1,2,2); plot(prob(:,2)); title('Probability With respect to c2 kMEANS');
% subplot(3,2,5); plot(info(:,1)); title('Information With respect to c1');
% subplot(3,2,6); plot(info(:,2)); title('Information With respect to c2');
% entropy = reshape(entropy,siz,siz); 
% figure; surf(entropy); title('Entropies of every point kMEANS');

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

% options = statset('Display','final');
% obj = gmdistribution.fit(feature_vector,nclasses,'Options',options);
% 
% prob = zeros( size(feature_vector,1), nclasses );
% 
% for k = 1:nclasses
%     prob(:, k) = mvnpdf(feature_vector, obj.mu(k, :), obj.Sigma(:, :, k));
% end
% 
% sum_ = sum(prob, 2);
% sum_ = repmat(sum_, [1, nclasses]);
% prob = prob ./ sum_;
% info_scaled = zeros(size(prob));
% for i = 1:size(prob,1)
%     % Information of the feature 
%     %(multiplied by prob - to get expected info for entropy calculation)
%     info_scaled(i,:) = -1.0*prob(i,:).*log2(prob(i,:));    
% end
% 
% figure;
% subplot(1,2,1); plot(prob(:,1)); title('Probability GMM w.r.t. c1'); xlabel('Point'); ylabel('Prob in c1');
% subplot(1,2,2); plot(prob(:,2)); title('Probability GMM w.r.t. c2'); xlabel('Point'); ylabel('Prob in c2');
% 
% % Average information (aka. Entropy)
% entropies = sum(info_scaled,2); 
% 
% entropy = reshape(entropies,siz,siz); 
% figure;
% surf(entropy); title('Entropy GMM');
% 
% figure;
% scatter3(feature_vector(:,1), feature_vector(:,2), ...
%      feature_vector(:,3), 'g');
% title('feature space');
% xlabel('Channel 1'); ylabel('Channel 2'); zlabel('Channel 3');
