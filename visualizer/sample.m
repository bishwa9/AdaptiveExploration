function [ valuemap,mat_z] = sample( path,truevalue,valuemap,x_max,y_max,mat_z)
%SAMPLE Summary of this function goes here
%   Detailed explanation goes here

    
x_idx = 2; y_idx = 1;
roboLen = 3; roboWid = 3; %make the rover a rectangle

%x_max = Size_ClassMap(1,2); y_max = Size_ClassMap(1,1);
Size_truevalue = size(truevalue);
sampled_depth = Size_truevalue(1,3); % nchannels


    robo_state=path(end,:);
    x_ = robo_state(x_idx); 
    y_ = robo_state(y_idx);
    valuemap(y_, x_, :) = truevalue(y_, x_, :); %Sampling at the point
    mat_z(y_, x_) = sampled_depth;
    
    
    
    figure (2)
    hold on;
    subplot(1,2,2);
    title('plot path');
    

    
    plot(path(:, y_idx), path(:, x_idx), 'r'); 
    xlim([0,x_max ]); ylim([0, y_max]);
    drawnow;   
    
    
    
    r = rectangle('Position',[robo_state(y_idx), robo_state(x_idx), ...
                                                  roboWid, roboLen]);
     
    
    figure (2)
    
    subplot(1,2,1);
    hold on;
    title('Spectral Data');
    xlim([0,x_max ]); ylim([0, y_max]);
    zlim([-10, 0]);
    surf(-1.*mat_z);
    colormap([1  1  0; 0  1  1])
    view([285.7700   12.6577  -88.2477]);
    
    delete(r);
    hold off;
    
end

