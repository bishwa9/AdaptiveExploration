clear;
addpath(genpath('../../matlab_sim'))
%%%%%%%%%%%%%%%%%%%%%
% Parameters for test 1
ndomclasses = 2;
nrareclasses = 0;
nclasses = ndomclasses + nrareclasses;
siz = 100;
miscvar = 0.01; 
sensorvar = 0.01;
nchannels = 8;
nvisiblechans = 3;
probrare = 0;

[classmap, valuemap, truevalue] = simulator...
            (ndomclasses, nrareclasses, siz, miscvar, ...
            sensorvar, nchannels, nvisiblechans, probrare);
        
x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
feature_vector = [x_.';y_.';z_.'].';
        
options = statset('Display','final');
obj = gmdistribution.fit(feature_vector,nclasses,'Options',options);

prob = zeros( size(feature_vector,1), nclasses );

for k = 1:nclasses
    prob(:, k) = mvnpdf(feature_vector, obj.mu(k, :), obj.Sigma(:, :, k));
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

entropy = reshape(entropies,siz,siz); 
figure;
surf(entropy); title('Entropy');

figure;
scatter3(feature_vector(:,1), feature_vector(:,2), ...
     feature_vector(:,3), 'g');
