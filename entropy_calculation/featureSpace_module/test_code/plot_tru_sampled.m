true_vals = ones(1000,3);
sampled_vals = ones(1000,3);

diff_val = ones(1000, 3);
for i = 1:1000
    sampled_point = points_sampled_k(i, :);
    actual = struct_.truevalue(sampled_point(1,1), sampled_point(1,2), 1:3);
    sample = struct_.valuemap(sampled_point(1,1), sampled_point(1,2), 1:3);
    diff = actual - sample;
    diff_val(i, :) = reshape(diff, [1 size(diff,3)]);
    true_vals(i, :) = reshape(actual, [1 size(actual,3)]);
    sampled_vals(i, :) = reshape(sample, [1 size(sample,3)]);
end
figure;
plot(1:1000, diff_val(:,1), 1:1000, diff_val(:,2), 1:1000, diff_val(:,3));

figure;

scatter3(sampled_vals(:,1), sampled_vals(:,2), ...
            sampled_vals(:,3), '+r'); 
hold on;
scatter3(true_vals(:,1), true_vals(:,2), ...
            true_vals(:,3), 'ob');

        
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