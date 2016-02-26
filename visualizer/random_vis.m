% NOTE: I changed sensorvar to miscvar because there 
%                       was no miscvar by two sensorvar

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

Size_ClassMap = size(classmap);
Size_valuemap = size(valuemap);
Size_truevalue = size(truevalue);

x_max = Size_ClassMap(1,1);
y_max = Size_ClassMap(1,2);
nominal_depth = Size_valuemap(1,3);
sampled_depth = Size_truevalue(1,3);

valuemap_ = zeros(size(truevalue));
valuemap_(1:x_max, 1:y_max, 1:size(valuemap,3)) = valuemap;
valuemap = valuemap_;

mat_z = ones(x_max, y_max).*nominal_depth;
t = 1:100;

for i = 1:size(t,2)
    
    x_ = randi(x_max); y_ = randi(y_max);
    valuemap(x_, y_, :) = truevalue(x_, y_, :);
    mat_z(x_, y_) = sampled_depth;
    
end
figure;
surf(-1.*mat_z);
zlim([-10, 0]);
