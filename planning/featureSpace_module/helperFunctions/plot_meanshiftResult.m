function plot_meanshiftResult(feature_vector, clusterCenters, clusterMemberships)
clusterNum  = size(clusterCenters,1);
figure; hold on; %axis equal
set(gcf,'color','w');
cc=hsv(clusterNum);
for cIdx = 1:clusterNum
    tempMembership = find(clusterMemberships == cIdx);
    %hold on;
    plot3(feature_vector(tempMembership,1), feature_vector(tempMembership,2), ...
    feature_vector(tempMembership,3), '.','color',cc(cIdx,:));

    tempCenter = clusterCenters(cIdx,:);
    %hold on;
    plot3(clusterCenters(cIdx,1), clusterCenters(cIdx,2), clusterCenters(cIdx,3), '+', 'LineWidth', 2,'color',cc(cIdx,:));
end
end

