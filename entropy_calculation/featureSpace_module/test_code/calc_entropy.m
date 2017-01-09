function [prob, entropies] = calc_entropy(centers, memberships, feature_vector, siz)
    % Probability and Entropy
    nclasses = size(centers, 1);
    Cov_mats = zeros(size(centers,2), size(centers,2), size(centers,1)); %each cluster has a covariance
    prob = zeros( size(feature_vector,1), nclasses );
    for i = 1:size(centers,1)
        indices = find( memberships == i );
        cluster_members = feature_vector(indices(:,1),:);
        Cov_mats(:,:,i) = cov(cluster_members);

        prob(:, i) = mvnpdf(feature_vector, centers(i,:), Cov_mats(:, :, i));
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

    entropies = reshape(entropies,siz,siz);
end