function [ error ] = reconError( gtMap, curMap, nclasses )
%RECONERROR Summary of this function goes here
%   Detailed explanation goes here

%fit k-means to curMap
x_ = gtMap(:,:,1);
x_ = x_(:);
y_ = gtMap(:,:,2);
y_ = y_(:);
z_ = gtMap(:,:,3);
z_ = z_(:);
feature_vector_gt = [x_.';y_.';z_.'].';
[~,gt_model,~,~] = kmeans(feature_vector_gt, nclasses);

%fit k-means to curMap
x_ = curMap(:,:,1);
x_ = x_(:);
y_ = curMap(:,:,2);
y_ = y_(:);
z_ = curMap(:,:,3);
z_ = z_(:);
feature_vector_cur = [x_.';y_.';z_.'].';
[~,cur_model,~,~] = kmeans(feature_vector_cur, nclasses);

errors = pdist2(gt_model, cur_model);
error = mean(mean(errors));
end

