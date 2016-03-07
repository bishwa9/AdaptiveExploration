function [ path ] = motion(path, units, direction )

%move the rover forward, back or left or right by a specified units

for i= 1:units
    
    path=vertcat(path, path(end,:)+ direction) 


end

