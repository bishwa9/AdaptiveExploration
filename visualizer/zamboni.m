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
figure;

path=[robo_state(y_idx),robo_state(x_idx)];

%f=[0,1];b=[0,-1];l=[-1,0];r=[1,0];

xdiff= roboEnd(x_idx)-robotStart(x_idx);
ydiff= roboEnd(y_idx)-robotStart(y_idx);
direction_x= [0, sign(xdiff)];
direction_y= [sign(ydiff),0];

widthOfZamboni_x=2;
widthOfZamboni_y=2;

zamboniStep=5

discreteMotionBlocks_x= 2.*round(xdiff/widthOfZamboni_x)-2
discreteMotionBlocks_y= 2.*round(ydiff/widthOfZamboni_y)-2

distanceToGoal=[ydiff, xdiff];

while ~isequal(robo_state,robo_state_final)
    
    if distanceToGoal(1)>distanceToGoal(2)
        
        path=motion(path,widthOfZamboni_x,direction_x);
        path=motion(path,zamboniStep*widthOfZamboni_y,direction_y);
        path=motion(path,widthOfZamboni_x,-direction_x);
        path=motion(path,zamboniStep*0.5*widthOfZamboni_y,-direction_y);
        robo_state=path(end,:);
       
    else
        path=motion(path,widthOfZamboni_y,-direction_y);
        path=motion(path,zamboniStep*widthOfZamboni_x,direction_x);
        path=motion(path,widthOfZamboni_y,direction_y);
        path=motion(path,zamboniStep*0.5*widthOfZamboni_x,-direction_x);
        robo_state=path(end,:);
    end
    
    pause(0.4);
    xdiff= roboEnd(x_idx)-robo_state(x_idx);
    ydiff= roboEnd(y_idx)-robo_state(y_idx);
    direction_x= [0, sign(xdiff)];
    direction_y= [sign(ydiff),0];
    distanceToGoal=[ydiff, xdiff]
    
    
    h0 = subplot(1,2,2);
    xlim([0, x_max]); ylim([0, y_max]);
    r = rectangle('Position',[robo_state(y_idx), robo_state(x_idx), ...
                                                    roboWid, roboLen]);
    drawnow; 
    
    x_ = robo_state(x_idx); 
    y_ = robo_state(y_idx);
    valuemap(y_, x_, :) = truevalue(y_, x_, :); %Sampling at the point
    mat_z(y_, x_) = sampled_depth;
    hold on; 
    plot(path(:, y_idx), path(:, x_idx), 'r'); drawnow; hold off;
    h1 = subplot(1,2,1);
    surf(-1.*mat_z);
    zlim([-10, 0]);
    drawnow;
    delete(r);
    
    if xdiff<zamboniStep | ydiff <zamboniStep
        break;
    end
end    
    
subplot(1,2,2); plot(path(:, y_idx), path(:, x_idx));
xlim([0, x_max]); ylim([0, y_max]);
