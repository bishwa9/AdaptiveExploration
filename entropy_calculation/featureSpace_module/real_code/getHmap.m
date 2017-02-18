function [ entropyMap ] = getHmap( sampled_pts, valuemap, nclasses )

persistent kmeans_memeberships centers

%extract feature vector
x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
feature_vector = [x_.';y_.';z_.'].';

siz = size(valuemap,1);

%calculate entropy
if mod( size(sampled_pts,2), 5 ) == 0 || size(sampled_pts,2) == 1
    [memberships,centers,~,dists] = kmeans(feature_vector,nclasses);
    kmeans_memeberships = reshape(memberships, siz, siz);
end

[~, entropyMap] = calc_entropy(centers, kmeans_memeberships, feature_vector, siz);
end

