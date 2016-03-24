function [classmap, valuemap, truevalue] = simulator(ndomclasses, nrareclasses, siz, miscvar, sensorvar, nchannels, nvisiblechans, probrare)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates a simulated terrain that contains a number of 'common' and 'rare' classes.
%  Common classes are the dominant classes in the scene, and rare classes are periodically
%  sprinkled in.
% One important point is that there are two types of variance here: 
%  variance within the values of each class, and variance that is added on to each class
%  to make the noisy, observed image. To see an example of the first, look at the top left
%  subplot after running this script. This variance determines the variations within each
%  class (so they aren't all a uniform color). The difference between the top left and top
%  right subplots is determined by the second variance. This is to model the fact that we
%  often have imperfect contextual information of a site, such as low-resolution satellite
%  photos. 
% Additionally, the colors section below is somewhat important. Ideally you want the colors
%  determining each class to be similar enough that it's not trivial for the system to sample
%  all of the classes, but not similar enough that it's impossible to distinguish one from 
%  another. Currently we're just using a few of the entries of matlab's colormap() as the 
%  base colors for each class, then adding noise to each one. Depending on the number of 
%  classes you have, this might be work for you or you might have to edit this. 
%
% The function takes the following parameters:
%   ndomclasses:     The number of dominant classes in the scene
%   nrareclasses:    The number of rare classes in the scene
%   siz:             The width and height of the generates images (currently these are equal)
%   miscvar:         The noise inherent in the scene
%                        (true value of pixel ~ N(mu_c, miscvar))
%   sensorvar:       The noise added to the true value 
%                        (observed value = N(mu_c, miscvar) + N(0, sensorvar))
%   nchannels:       The number of channels (bands) of information at every pixel
%   nvisiblechans:   The number of visible channels in your observed/contextual image
%   probrare:        The probability of any pixel being a 'rare' class
% 
% The function returns three images:
%   classmap:        The underlying class of each pixel
%   observedvalue:   The observed/known image used for planning
%   truevalue:       The true values obtained when sampling that pixel
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

width = siz;
height = siz;

maxvar = sensorvar;
% have a minimum amount of variance
minvar = .02;
varspread = (maxvar - minvar);

ncentroids = ndomclasses * 4;

% Select how many centroids each class will have
chosen = 0;
centroidsleft = ncentroids;

means = {};
spread = {};
stds = {};

% This describes the distribution of the classes. Each class has a certain # of centroids
% and each centroid has a mean (location) and variance (spread). Class membership is
% calcualted below using Mahalanobis distance
for i = 1:ndomclasses
	% Determine how many centroids belong to this class
	if i == ndomclasses
		centroids(i) = centroidsleft;
	else
		% Make sure the final classes always have at least one centroid
		centroids(i) = ceil(rand(1) * (centroidsleft-(ndomclasses-i)));
	end

	% Spread is the variance in the position of the given centroid (spatial spread)
	% Stds is the std dev within the class ~ N(mu, stds{i,j})
	for j = 1:centroids(i)
		% The position of this class centroid within the image
		means{i,j} = rand(2,1) .* [height; width];

		% The spatial variance of this centroid
		spread{i,j} = rand(1) * varspread + minvar;
	end

	% The variance within pixel values of this class
	stds{i} = rand(1) * varspread + minvar;

	chosen = chosen + centroids(i);
	centroidsleft = ncentroids - chosen;
end

% Calculate the sensor noise variance for the rare classes
for i = 1:nrareclasses
	stds{i+ndomclasses} = rand(1) * varspread + minvar;
end

% Generate the colors we'll assign to each class. See notes in the header about how best to 
%  use colors.
colors = colormap('jet'); % 64 total colors

% Add extra bands if we've asked for them
if nchannels < 3
	colors = colors(:,[1:nchannels]);
elseif nchannels > 3
	colors = [colors rand([size(colors,1) nchannels-3])];
end

% Make sure the colors aren't too close to 1 or 0. Some might still be because of variance, but this way 
%  that's much less common.
colors = colors*0.8 + 0.1;

ncolors = floor(size(colors,1)/(ndomclasses + nrareclasses));

% For a full spread across the color spectrum
% colorinds = 1:nclasses:size(colors,1);

% for a smaller spread:
colorinds = 13:3:size(colors,1);

% make sure we only keep the same # of colors as we have classes
colorinds = colorinds(1:(ndomclasses + nrareclasses));

% For an even spread across the spectrum
%colorinds = floor([1:(ndomclasses+nrareclasses)] * size(colors,1)/(ndomclasses + nrareclasses));

% randperm them so lighter colors aren't always rare
colorinds = colorinds(randperm(size(colorinds,2)));

% for every pixel in the w x h image, find the closest dominant class or label it
% as a rare class
classmap = zeros(height, width);
for y = 1:height
	for x = 1:width
		% add a rare class with some low probability
		rareclass = rand(1);
		if rareclass < probrare
			class = randi(nrareclasses) + ndomclasses;
			classmap(y,x) = class;
			for c = 1:nchannels
				% cmean = colors(1+(class-1)*ncolors,c);
				cmean = colors(colorinds(class), c);
				
				% We have both additive Gaussian noise (within-class error, first line) and
				%  sensor noise
				truevalue(y,x,c) = min(1, max(0, normrnd(cmean, stds{class})));
				valuemap(y,x,c) =  min(1, max(0, truevalue(y,x,c) + normrnd(0,sensorvar)));
			end

		% otherwise add a normal class
		else
			mindist = width*height;
			minclass = 0;

			% find the nearest point in mahal distance between the current point and each centroid
			for i = 1:ndomclasses
				for j = 1:centroids(i)
					% dist = mahal(means{i, j}, 1, [y; x]);
					dist = mahal(means{i, j}, spread{i,j}, [y; x]);

					if dist < mindist
						mindist = dist;
						minclass = i;
					end
				end
			end

			classmap(y,x) = minclass;
			for c = 1:nchannels				
				cmean = colors(colorinds(minclass), c);
				
				% We have both additive Gaussian noise (within-class error, 2nd term) and
				%  sensor noise (1st term)
				truevalue(y,x,c) = min(1, max(0, normrnd(cmean, stds{minclass})));
				valuemap(y,x,c) =  min(1, max(0, truevalue(y,x,c) + normrnd(0,sensorvar)));
            end  
		end
	end
end

valuemap = valuemap(:,:,1:nvisiblechans);

subplot(2,2,1)
imagesc(truevalue(:,:,1:3))
title('True values (first 3 channels)')
subplot(2,2,2)
imagesc(valuemap(:,:,1:3))
valuemap
title('Observed values')
subplot(2,2,3)
imagesc(classmap)
title('True underlying classes')
