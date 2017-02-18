function [ error ] = reconError( gtMap, sampled )
feature_vector_gt = zeros(size(gtMap,1)*size(gtMap,2), size(gtMap,3));

for i = 1:size(gtMap, 3)
    x_ = gtMap(:,:,1);
    x_ = x_(:);
    feature_vector_gt(:,i) = x_';
end

allInd = 1:size(feature_vector_gt,1);
unsampled_ind = setdiff(allInd, sampled); %unsampled indices
unsampled_ind = datasample(unsampled_ind, 200, 'Replace', false);

sampled_X = double(feature_vector_gt(sampled,:));
unsampled_Y = double(feature_vector_gt(unsampled_ind,:));

reconW = zeros(1, size(sampled_X,1)*size(unsampled_Y,1));
c = 1;

for i = 1:size(sampled_X,1)
    for j = 1:size(unsampled_Y,1)
        matX = diag(sampled_X(i,:));
        matY = unsampled_Y(j,:)';
        err = lsqnonneg(matX, matY); 
        err = mean(err);
        reconW(:,c) = err;
        c = c+1;
        if mod(c,1000) == 0
            disp( sprintf( 'Calc Recon Err: %d out of %d', c, length(reconW) ) );
        end
    end
end

error = mean(reconW);
end

