function [prob, entropies] = calc_entropy(dists)
    % Probability and Infomation
    dist_inv = 1./dists;
    sums = sum(dist_inv,2);
    info_scaled = zeros(size(dists));
    prob = zeros(size(dists));
    for i = 1:size(dists,1)
        % Probability of the feature
        prob(i,:) = dist_inv(i,:) / sums(i);   
        
        % Information of the feature 
        %(multiplied by prob - to get expected info for entropy calculation)
        info_scaled(i,:) = -1.0*prob(i,:).*log2(prob(i,:));    
    end
    % Average information (aka. Entropy)
    entropies = sum(info_scaled,2);  
end