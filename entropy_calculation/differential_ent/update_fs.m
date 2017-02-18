% function [feature_vector_updated] = ...
%     update_fs(feature_vector, pointToSample, noisy_sample, true_sample, mutual_info)
% %UPDATE_FS Summary of this function goes here
% %   Detailed explanation goes here
% 
% global mapSize
% 
% indSamp = sub2ind(mapSize, pointToSample(1,1), pointToSample(2,1));
% feature_vector(indSamp,:) = true_sample; 
% feature_vector_updated = feature_vector;
% end
% 
function [feature_vector_updated] = ...
    update_fs(feature_vector, pointToSample, noisy_sample, true_sample, mutual_info)
sigma_fs = 0.01;
sigma_es = 1;

nvisiblechans = size(feature_vector, 2);
siz = sqrt(size(feature_vector,1));

% reconfigure feature space
move_vector_orig = true_sample - noisy_sample;
move_vector = repmat(move_vector_orig, size(feature_vector, 1), 1);

switch mutual_info
    case 0 %gaussian kernel in feature space
        cov_mat = sigma_fs*eye(nvisiblechans);
        cov_mat_posDef = cov_mat'*cov_mat; %%%%% -> What does this do (look into later)
        positivedefinite = all(eig(cov_mat_posDef) > 0);
        if positivedefinite ~= 1
            error('Covariance matrix incorrect')
        end
        gaussian_filter = mvnpdf(feature_vector,noisy_sample,cov_mat_posDef);
        gaussian_filter = repmat(gaussian_filter, 1, nvisiblechans);
        gaussian_filter = gaussian_filter./max(max(gaussian_filter));
        move_vector_scaled = gaussian_filter.*move_vector;
        
    case 1 %gaussian kernal in euclidean space
        [x,y] = meshgrid(1:siz, 1:siz);
        twoD_space = zeros(siz, siz, 2);
        twoD_space(:,:,2) = x;
        twoD_space(:,:,1) = y;
        twoD_space = reshape(twoD_space, [siz*siz, 2]);
        cov_mat = sigma_es*eye(2);

        gaussian_filter = mvnpdf(twoD_space,pointToSample,cov_mat);
        gaussian_filter = repmat(gaussian_filter, 1, 3);
        gaussian_filter = gaussian_filter./max(max(gaussian_filter));
        move_vector_scaled = gaussian_filter.*move_vector;
    otherwise %independent
end
feature_vector_updated = feature_vector + move_vector_scaled;
end