function [CCenters,CMemberships,dists] = MeanShift(data,bandwidth,stopThresh)
%% 
%Input
% data: NxF+1
% bandwidth:
% stopThres: 
%Output
% CCenters:
% CMemberships:

%% Implementation
N = size(data, 1);
F = size(data, 2) - 1;
data_p = data(1:N, 1:F);
data_w = data(:, F+1);

means = zeros(N, F);

for i = 1:N
    pt = data_p(i,:);
    mean_bef = pt;
    while true
        dists = pdist2(data_p, pt);
        withinBand = find(dists < bandwidth);
        pt_clust = data_p(withinBand, :);
        pt_w = data_w(withinBand, 1);
        mean = findMean(pt_clust, pt_w);
        shift = pdist2(mean, mean_bef);
        if( shift < stopThresh )
            means(i,:) = mean;
            break;
        else
            pt = mean;
            mean_bef = mean;
        end
    end
end

CCenters = [];
CMemberships = zeros(N,1);
Indtracker = 1:N;
theshold = stopThresh;
while size(means, 1) ~= 0
    mn = means(1,:);
    meansDists = pdist2(means, mn);
    closeOnes = find(meansDists < theshold);
    
    means_close = means(closeOnes, :);
    weight = ones(size(means_close, 1), 1);
    mean_final = findMean(means_close, weight);    
    CCenters = vertcat(CCenters, mean_final);
    
    %update the memberships with the appropriate cluster center
    indsofmeans_close = Indtracker(closeOnes);
    CMemberships(indsofmeans_close, 1) = size(CCenters, 1);
    
    %update means and Indtracker
    means(closeOnes,:) = [];
    Indtracker(closeOnes) = [];
end

dists = pdist2(data_p, CCenters);
end

function mean = findMean(clust, weight)
    weight_rep = repmat(weight, [1 size(clust, 2)]); 
    nume = sum(clust .* weight_rep, 1);
    denom = sum(weight_rep, 1);
    mean = nume ./ denom;
end