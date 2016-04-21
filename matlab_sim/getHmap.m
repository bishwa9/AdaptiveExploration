function [HS] = getHmap(siz, sampled_points)
% This function takes in sampled points and outputs the entropy of those
% points which each of the remaining points in the map
% sampled points: size - Nx2, N is the number of points, 2 correspond to
% the number of dimension, in this case 2D 
ndomclasses = 6;
nrareclasses = 4;
%siz = 100;
miscvar = .12;
sensorvar = .05;
nchannels = 8;
nvisiblechans = 3;
probrare = 0.02;
pi=22/7;
% End of example parameters
%%%%%%%%%%%%%%%%%%%%%

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
% finding variance across all channels for the whole map with the sampled
% points

%finding the indices of sampled points so that they can be removed from the
%list when the whole map is vectorized
%sampled_points=[1 1] % remove this. it should be passed into the function
sampled_points_indices=sub2ind(size(valuemap),sampled_points(1,:), sampled_points(2,:));
vect_channel = zeros(size(valuemap,1)*size(valuemap,2),3);
sampled_vals = zeros(size(sampled_points,1),1);
for i=1:nvisiblechans
    vect=valuemap(:,:,i);
    vect_channel(:,i)=vect(:);
    sampled_vals(:,i)=diag(valuemap(sampled_points(1,:),sampled_points(2,:),i));
end
vect_channel(sampled_points_indices,:)=[];
V = zeros(size(vect_channel,1),3);
for i=1:nvisiblechans
    sampled_channel=sampled_vals(:,i)';
    sampled_channel_vals=repmat(sampled_channel,size(vect_channel,1),1);
    var_vect=horzcat(sampled_channel_vals,vect_channel(:,i));
    V(:,i)=var(var_vect,0,2);
end
% entropy of sampled points with each un-sampled point
HS=0.5*sum(log(2*pi*V),2);
