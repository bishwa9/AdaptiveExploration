% NOTE: I changed sensorvar to miscvar because there 
%                       was no miscvar by two sensorvar

clear;
addpath(genpath('../matlab_sim'));

%%%%%%%%%%%%%%%%%%%%
%   classmap -> true classification of each pixel
%   valuemap -> channels accessible to the robot without sampling
%               Basically the satellite map
%   truevalue -> channels accesible to the robot after sampling
%               Basically the data that is given to the rover once it
%               samples
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%
% Example parameters. Comment this out if you want to use this as a function!
ndomclasses = 6;
nrareclasses = 4;
siz = 100;
miscvar = .12; 
sensorvar = .05;
nchannels = 8;
nvisiblechans = 3;
probrare = 0.02;
% End of example parameters
%%%%%%%%%%%%%%%%%%%%%

[classmap, valuemap, truevalue] = simulator...
    (ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare);

x_ = valuemap(:,:,1);
x_ = x_(:);
y_ = valuemap(:,:,2);
y_ = y_(:);
z_ = valuemap(:,:,3);
z_ = z_(:);
Data = [x_.';y_.';z_.'].';

[~,centers,~,dists] = kmeans(Data,ndomclasses+nrareclasses);

sums = sum(dists,2);
info = dists;
prob = dists;
for i = 1:siz*siz
    prob(i,:) = 1 - ( dists(i,:) / sums(i,1) );
    prob(i,:) = prob(i,:) / ( ndomclasses+nrareclasses-1 );
    info(i,:) = -1.0*prob(i,:).*log2(prob(i,:));
end

entropy = sum(info,2);
entropy = reshape(entropy,100,100);
figure;
title('1-dist for probability');
subplot(2,2,1);
surf(entropy);
title('Entropy');
subplot(2,2,2);
surf(classmap);
title('Classmap');
subplot(2,2,3);
imshow(valuemap);
title('Valuemap');