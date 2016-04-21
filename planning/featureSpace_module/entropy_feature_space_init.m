function [ post_ ] = entropy_feature_space_init( ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare, visualize)
                                             
%% run simulator
[classmap, valuemap, truevalue] = simulator...
    (ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare);

%% initialization
field15_name = 'ndomclasses';
field15_val = ndomclasses;

field16_name = 'nrareclasses';
field16_val = nrareclasses;

field17_name = 'siz';
field17_val = siz;

field18_name = 'miscvar';
field18_val = miscvar;

field19_name = 'sensorvar';
field19_val = sensorvar;

field20_name = 'nchannels';
field20_val = nchannels;

field21_name = 'nvisiblechans';
field21_val = nvisiblechans;

field22_name = 'probrare';
field22_val = probrare;

field1_name = 'classmap';
field1_val = classmap;
                                             
field2_name = 'valuemap';
field2_val = valuemap;

field3_name = 'truevalue';
field3_val  = truevalue;

field4_name = 'nclasses';
nclasses = ndomclasses + nrareclasses;
field4_val  = nclasses;

if visualize == 1 && nvisiblechans == 3
field5_name = 'figure_featureSpace';
field5_val  = figure;

field6_name = 'figure_Entropy';
field6_val  = figure;

field7_name = 'figure_dist';
field7_val  = figure;
end

field8_name = 'sample_set';
field8_val  = [];

%% compute initial clustering and entropy map
% k-means
x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
feature_vector = [x_.';y_.';z_.'].';

[~,centers,~,dists] = kmeans(feature_vector,nclasses);
% Probability and Entropy
sums = sum(dists,2);
info = dists;
info2 = dists;
prob = dists.^-1;
prob2 = dists; 
for i = 1:size(feature_vector,1)
    prob(i,:) = dists(i,:) / sums(i,1);
    
    prob2(i,:) = 1 - ( dists(i,:) / sums(i,1) );
    prob2(i,:) = prob2(i,:) / ( nclasses-1 );
    
    info(i,:) = -1.0*prob(i,:).*log2(prob(i,:));
    info2(i,:) = -1.0*prob2(i,:).*log2(prob2(i,:));
end

entropy_dinv = sum(info,2); 
% entropy_dminus = sum(info2,2);
entropy_dinv = reshape(entropy_dinv,siz,siz); 
% entropy_dminus = reshape(entropy_dminus,100,100);

field9_name = 'entropy_map';
field9_val  = entropy_dinv;

field10_name = 'initial_entropy_map';
field10_val  = entropy_dinv;

field11_name = 'centers';
field11_val  = centers;

field12_name = 'dists';
field12_val  = dists;

[max_entropy_point_val, max_entropy_point_ind] = max(entropy_dinv);
max_entropy_point_ind = datasample(max_entropy_point_ind,1);
[I1, I2] = ind2sub(size(entropy_dinv),max_entropy_point_ind);
max_entropy_point = [I1, I2];

field13_name = 'max_entropy_point';
field13_val  = max_entropy_point;

field14_name = 'max_entropy_point_val';
field14_val  = max_entropy_point_val;

%% visualize if needed
if visualize == 1 && nvisiblechans == 3
    figure(field5_val);
    scatter3(feature_vector(:,1), feature_vector(:,2), ...
        feature_vector(:,3), 'g');
    legend('after sample', 'before sample');
    title('Rover sample in feature space');
    xlabel('Channel 1'); ylabel('Channel 2'); zlabel('Channel 3');
    
    figure(field6_val);
    title('recomputed entropy');
    surf(entropy_dinv);
    xlabel('X'); ylabel('Y'); zlabel('Entropy');
end

%% create the struct
if visualize == 1
    temp = struct(field1_name, field1_val, ...
                field2_name, field2_val, ...
                field3_name, field3_val, ...
                field4_name, field4_val, ...
                field5_name, field5_val, ...
                field6_name, field6_val, ...
                field7_name, field7_val, ...
                field8_name, field8_val, ...
                field9_name, field9_val, ...
                field10_name, field10_val, ...
                field11_name, field11_val, ...
                field12_name, field12_val, ...
                field13_name, field13_val, ...
                field14_name, field14_val, ...
                field15_name, field15_val, ...
                field16_name, field16_val, ...
                field17_name, field17_val, ...
                field18_name, field18_val, ...
                field19_name, field19_val, ...
                field20_name, field20_val, ...
                field21_name, field21_val, ...
                field22_name, field22_val);
else
    temp = struct(field1_name, field1_val, ...
                field2_name, field2_val, ...
                field3_name, field3_val, ...
                field4_name, field4_val, ...
                field8_name, field8_val, ...
                field9_name, field9_val, ...
                field10_name, field10_val, ...
                field11_name, field11_val, ...
                field12_name, field12_val, ...
                field13_name, field13_val, ...
                field14_name, field14_val, ...
                field15_name, field15_val, ...
                field16_name, field16_val, ...
                field17_name, field17_val, ...
                field18_name, field18_val, ...
                field19_name, field19_val, ...
                field20_name, field20_val, ...
                field21_name, field21_val, ...
                field22_name, field22_val);
end


%% return the struct
post_ = temp;
end
