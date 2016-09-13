%%

function [ post_ ] = Entropy_feature_space(prev_,           ...
                                           pointToSample,   ...
                                           visualize,       ...
                                           redoClustering,  ...
                                           do_meanShift,    ...
                                           sampled_points)

%% Initialization
sample_set = prev_.sample_set;
n_classes = prev_.nclasses;
entropy_dinv = prev_.entropy_map;
centers = prev_.centers;
dists = prev_.dists;
valuemap = prev_.valuemap;
truevalue = prev_.truevalue;
ndomclasses = prev_.ndomclasses;
nrareclasses = prev_.nrareclasses;
nclasses = prev_.nclasses;
siz = prev_.siz;
miscvar = prev_.miscvar; 
sensorvar = prev_.sensorvar;
nchannels = prev_.nchannels;
nvisiblechans = prev_.nvisiblechans;
probrare = prev_.probrare;
if visualize == 1
    figure_featureSpace = prev_.figure_featureSpace;
    figure_Entropy = prev_.figure_Entropy;
    figure_dist = prev_.figure_dist;
end

%% sample pointToSample
I1 = pointToSample(1,1);
I2 = pointToSample(1,2);
rov_sample = truevalue(I1, I2, :);
sample_set = vertcat(sample_set, ...
                reshape(rov_sample, [1 size(rov_sample,3)]));
overlap_sample = reshape(rov_sample(:,:,1:3), [1, nvisiblechans]);
old_sample = reshape(valuemap(I1,I2,:), [1, nvisiblechans]);

%% reconfigure feature space
move_vector = overlap_sample - old_sample;
move_vector = repmat(move_vector, siz*siz, 1);
pointToSample_ind = sub2ind(size(entropy_dinv), pointToSample(1,1), pointToSample(1,2));
[~,cluster_ind] = min(dists(pointToSample_ind,:));
d = dists(pointToSample_ind, cluster_ind);
sigma = 0.1*(max(dists(pointToSample_ind,:)) - d);
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
if positivedefinite ~= 1
    error('Covariance matrix incorrect')
end
gausian_filter = mvnpdf(feature_vector,old_sample,cov_mat_posDef);
gausian_filter = repmat(gausian_filter, 1, nvisiblechans);
gausian_filter = gausian_filter./max(max(gausian_filter));
move_vector_scaled = gausian_filter.*move_vector;
%move_vector_scaled = move_vector_scaled/norm(move_vector_scaled,Inf);

%update satellite map with rover's sample
feature_vector_new = feature_vector + move_vector_scaled;

%% re-compute entropy
if redoClustering == 1
    if do_meanShift == 1
    else
        [~,centers,~,dists] = kmeans(feature_vector_new,nclasses);
    end
else
    % recompute the distances  
    dists = pdist2(feature_vector_new, centers);
end
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

entropy_dinv = sum(info,2); 
% entropy_dminus = sum(info2,2);
entropy_dinv = reshape(entropy_dinv,siz,siz); % being used
act_val = zeros(size(sampled_points,1),1);
for idx = 1:size(sampled_points,1)
    act_val(idx,1) = entropy_dinv(sampled_points(idx, 1), sampled_points(idx, 2));
    entropy_dinv(sampled_points(idx, 1), sampled_points(idx, 2)) = -Inf;
end

% entropy_dminus = reshape(entropy_dminus,100,100);

max_entropy_point_val = max(max(entropy_dinv));
max_entropy_point_ind = find(entropy_dinv == max_entropy_point_val);
[I1, I2] = ind2sub(size(entropy_dinv),max_entropy_point_ind);
max_entropy_point = [I1, I2];

for idx = 1:size(sampled_points,1)
    entropy_dinv(sampled_points(idx, 1), sampled_points(idx, 2)) = act_val(idx,1);
end

%% reshape feature vector into valuemap -> update the map used to explore
for i = 1:3
    valuemap(:,:,i) = reshape(feature_vector_new(:,i), siz, siz);
end

%% visualize if needed
if visualize == 1 && nvisiblechans == 3
    figure(figure_featureSpace);
    % scatter3(centers(:,1), centers(:,2), centers(:,3)); hold on;
    scatter3(feature_vector_new(:,1), feature_vector_new(:,2), ...
        feature_vector_new(:,3), 'r'); hold on;
    scatter3(feature_vector(:,1), feature_vector(:,2), ...
        feature_vector(:,3), 'g');
    legend('after sample', 'before sample');
    title('Rover sample in feature space');
    xlabel('Channel 1'); ylabel('Channel 2'); zlabel('Channel 3');
    figure(figure_dist);
    quiver3(feature_vector(:,1),feature_vector(:,2),feature_vector(:,3), ...
        move_vector_scaled(:,1),move_vector_scaled(:,2),move_vector_scaled(:,3))
    title('Movement of each point in three features');
    xlabel('Channel 1'); ylabel('Channel 2'); zlabel('Channel 3');
    
    figure(figure_Entropy);
    surf(entropy_dinv);
    title('recomputed entropy');
    xlabel('X'); ylabel('Y'); zlabel('Entropy');
end


%% format into a struct
prev_.entropy_map = entropy_dinv;
prev_.centers = centers;
prev_.dists = dists;
prev_.valuemap = valuemap;
prev_.truevalue = truevalue;
prev_.max_entropy_point_val = max_entropy_point_val;
prev_.max_entropy_point = max_entropy_point;
post_ = prev_;
end