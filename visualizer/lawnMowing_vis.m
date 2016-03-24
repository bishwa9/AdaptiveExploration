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
ndomclasses = 6;
nrareclasses = 4;
siz = 100;
miscvar = .12; 
sensorvar = .05;
nchannels = 8;
nvisiblechans = 3;
probrare = 0.02;

robotStart = [10, 50];
roboEnd = [50, 80];
% End of example parameters
%%%%%%%%%%%%%%%%%%%%%

[classmap, valuemap, truevalue] = simulator...
    (ndomclasses, nrareclasses, siz, miscvar, ...
    sensorvar, nchannels, nvisiblechans, probrare);

Size_ClassMap = size(classmap);
Size_valuemap = size(valuemap);
Size_truevalue = size(truevalue);

x_max = Size_ClassMap(1,1); y_max = Size_ClassMap(1,2);
nominal_depth = Size_valuemap(1,3);
sampled_depth = Size_truevalue(1,3);

valuemap_ = zeros(size(truevalue));
valuemap_(1:x_max, 1:y_max, 1:size(valuemap,3)) = valuemap;
valuemap = valuemap_;

x_pos = 1; y_pos = 2;% velx_pos = 3; vely_pos = 4;

robo_state_init = [robotStart(1,1), robotStart(1,2)];
robo_state_final = [roboEnd(1,1), roboEnd(1,2)];

roboLen = 3; roboWid = 3;

robo_state = robo_state_init;

mat_z = ones(x_max, y_max).*nominal_depth;
figure;

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
    xlim([0, x_max]); ylim([0, y_max]);
    r = rectangle('Position',[robo_state(x_pos), robo_state(y_pos), ...
                                                    roboLen, roboWid]);
    xy = vertcat(xy, [x_, y_]);
    hold on; plot(xy(:, x_pos), xy(:, y_pos), 'r'); drawnow; hold off;
    drawnow; 
    robo_state = robo_state + [0, y_inc];
    
    %sample at the point and store data in valuemap
    valuemap(x_, y_, :) = truevalue(x_, y_, :); %Sampling at the point
    
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
subplot(1,2,2); plot(xy(:, x_pos), xy(:, y_pos));
xlim([0, x_max]); ylim([0, y_max]);