 % NOTE: I changed sensorvar to miscvar because there 
%                       was no miscvar by two sensorvar

addpath(genpath('../matlab_sim/'));


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
roboEnd = [50, 80];     %end point for rover
% End of example parameters
%%%%%%%%%%%%%%%%%%%%%

[classmap, ... %ground truth of classification
    valuemap, ... %satellite map (the low res map)
    truevalue]...   %channel accesible after sensor sampling (info you get after sampling)
    = simulator...  %thing that gives you that information
    (ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare);

%%%%Setup%%%%%
Size_ClassMap = size(classmap);
Size_valuemap = size(valuemap);
Size_truevalue = size(truevalue);

x_max = Size_ClassMap(1,1); y_max = Size_ClassMap(1,2);
nominal_depth = Size_valuemap(1,3); % nvisiblechans
sampled_depth = Size_truevalue(1,3); % nchannels

%create nchannel big empty map, to be filled accordingly
valuemap_ = zeros(size(truevalue));
valuemap_(1:x_max, 1:y_max, 1:size(valuemap,3)) = valuemap;
valuemap = valuemap_;

x_idx = 1; y_idx = 2;% velx_pos = 3; vely_pos = 4;

%robots movement resolution is 1 (integer increments in movement)
y_inc_ = 1;
x_inc_ = 2;


robo_state_init = [robotStart(1,1), robotStart(1,2)];
robo_state_final = [roboEnd(1,1), roboEnd(1,2)];

roboLen = 3; roboWid = 3; %make the rover a rectangle

robo_state = robo_state_init; %rover is at the start

mat_z = ones(x_max, y_max).*nominal_depth;  %matrix that stores number of channels currently accessed at each pixel location
figure;

<<<<<<< HEAD


path = []; 

for i = robo_state_init(x_idx):robo_state_final(x_idx)
    y_inc = (-1)^(mod(i,2)) * y_inc_;
    
for j = robo_state_init(y_idx):robo_state_final(y_idx)
    h0 = subplot(1,2,2);
=======
y_inc_ = 1;
x_inc_ = 2;
xy = [];
ent = [];
samples = [];
for i = robo_state_init(x_pos):robo_state_final(x_pos)
    y_inc = (-1)^(mod(i,2)) * y_inc_;
for j = robo_state_init(y_pos):robo_state_final(y_pos)
    
    %plot the robot's rectangle
    x_ = robo_state(x_pos); 
    y_ = robo_state(y_pos);
    h0 = subplot(2,2,2);
>>>>>>> 88929eb24861d472b61aa5f576f260f39d46063e
    xlim([0, x_max]); ylim([0, y_max]);
    r = rectangle('Position',[robo_state(x_idx), robo_state(y_idx), ...
                                                    roboLen, roboWid]);
    xy = vertcat(xy, [x_, y_]);
    hold on; plot(xy(:, x_pos), xy(:, y_pos), 'r'); drawnow; hold off;
    drawnow; 
    robo_state = robo_state + [0, y_inc];
    
<<<<<<< HEAD
    x_ = robo_state(x_idx); 
    y_ = robo_state(y_idx);
    valuemap(x_, y_, :) = truevalue(x_, y_, :); %Sampling at the point
    mat_z(x_, y_) = sampled_depth;
    path = vertcat(path, [x_, y_]);
    hold on; plot(path(:, x_idx), path(:, y_idx), 'r'); drawnow; hold off;
=======
    %sample at the point and store data in valuemap
    valuemap(x_, y_, :) = truevalue(x_, y_, :); %Sampling at the point
>>>>>>> 88929eb24861d472b61aa5f576f260f39d46063e
    
    %update the visualizing matrix (3d map shown in plot)
    mat_z(x_, y_) = sampled_depth;
    h1 = subplot(2,2,1);
    surf(-1.*mat_z);
    zlim([-10, 0]);
    drawnow;
    
    %pull the sampled vectors from valuemap
    samples = valuemap(xy(:,1), xy(:,2), :);
    
    
    %pause(0.3)
    delete(r);
end
    robo_state = robo_state + [x_inc_, -y_inc];
end
subplot(1,2,2); plot(path(:, x_idx), path(:, y_idx));
xlim([0, x_max]); ylim([0, y_max]);