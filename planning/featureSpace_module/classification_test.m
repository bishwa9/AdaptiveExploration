function classification_test( numOfMaps )
addpath(genpath('./testData'))
addpath(genpath('./helperFunctions'))
name = 'testData';
ext1 = '.mat';
tot_ms = 0;
for i = 1:numOfMaps
    file_name = sprintf('%s_%d%s',name, i, ext1);
    load(file_name);
    x_ = valuemap(:,:,1);
    x_ = x_(:);
    y_ = valuemap(:,:,2);
    y_ = y_(:);
    z_ = valuemap(:,:,3);
    z_ = z_(:);
    feature_vector = [x_.';y_.';z_.'].';
    [~,centers,~,dists] = kmeans(feature_vector,nclasses);
    [~,memberships] = min(dists.');
    memberships = memberships.';
    kmeans_classification = reshape(memberships, [siz,siz]);
    plot_meanshiftResult(feature_vector, centers, memberships); title(strcat('kmeans_featurespace', file_name));
    
    weight_ = ones(size(feature_vector,1), 1);
    data = [feature_vector, weight_];
    bandwidth = 0.2;
    stopThresh = 0.00001;
    [centers,memberships,dists] = MeanShift(data,bandwidth,stopThresh);
    meanshift_classification = reshape(memberships, [siz,siz]);
    tot_ms = tot_ms + size(centers,1);
    plot_meanshiftResult(feature_vector, centers, memberships); title(strcat('ms_featurespace', file_name));
    figure; surf(kmeans_classification); title(strcat('kmeans', file_name));
    figure; surf(meanshift_classification); title(strcat('mean shift', file_name));
    figure; surf(classmap); title(strcat('true classes', file_name));
end
tot_ms
end

