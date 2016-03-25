ndomclasses = 6;  %classes that appear frequently in the data
nrareclasses = 4; %classes that appear rarely
siz = 100;         % size of the map- 100x100
miscvar = .12;      %The noise inherent in the scene
%                        (true value of pixel ~ N(mu_c, miscvar))
sensorvar = .05;        %   sensorvar:       The noise added to the true value 
nchannels = 8;      %The number of channels (bands) of information at every pixel
nvisiblechans = 3;  %Number of channels accessible wihtout rover sampling (from Rover)
probrare = 0.02;    % probability of a rare class

robotStart = [10, 50];  %start location for rover
roboEnd = [50, 90];     %end point for rover
% End of example parameters
%%%%%%%%%%%%%%%%%%%%%


[classmap, ... %ground truth of classification
    valuemap, ... %satellite map (the low res map)
    truevalue]...   %channel accesible after sensor sampling (info you get after sampling)
    = simulator...  %thing that gives you that information
    (ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare);

Size_ClassMap = size(classmap);
Size_valuemap = size(valuemap);
Size_truevalue = size(truevalue);

x_max = Size_ClassMap(1,2); y_max = Size_ClassMap(1,1);
nominal_depth = Size_valuemap(1,3); % nvisiblechans
sampled_depth = Size_truevalue(1,3); % nchannels


x_idx = 2; y_idx = 1;

%create nchannel big empty map, to be filled accordingly
valuemap_ = zeros(size(truevalue));
valuemap_(1:y_max, 1:x_max, 1:size(valuemap,3)) = valuemap;
valuemap = valuemap_;

robo_state_init = [robotStart(1,1), robotStart(1,2)];
robo_state_final = [roboEnd(1,1), robotStart(1,2)];

roboLen = 3; roboWid = 3; %make the rover a rectangle

robo_state = robo_state_init; %rover is at the start

mat_z = ones(y_max, x_max).*nominal_depth;  %matrix that stores number of channels currently accessed at each pixel location


path=[robo_state(y_idx),robo_state(x_idx)];

clear x;
clear y;
s = 0;
step_s = 0.2;
num_sine_waves = 10;
amplitude = 10;
init_pt = robotStart;
final_pt = roboEnd;
theta = atan2((final_pt(2) - init_pt(2)),(final_pt(1) - init_pt(1)));
r = pdist2(init_pt, final_pt);
a = (num_sine_waves * pi)/r;
i = 1;
x = zeros([1,floor(r/step_s)]);
y = zeros([1,floor(r/step_s)]);
while s < r
    x(i) = init_pt(1) + s*cos(theta) - amplitude*sin(a*s)*sin(theta);
    y(i) = init_pt(2) + s*sin(theta) + amplitude*sin(a*s)*cos(theta);
    path(i,1) = round(x(i));
    path(i,2) = round(y(i));
    [valuemap, mat_z] = sample(path, truevalue, valuemap, x_max, y_max, mat_z);
    s = s + step_s;
    i = i + 1;
end
% figure(4); plot(x, y);
