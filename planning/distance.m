function [ d ] = distance( id1,id2)
%DISTANCE Summary of this function goes here
%   Detailed explanation goes here

[x1 y1]= ind2sub(id1);
[x2 y2]=ind2sub(id2);

d= norm( [x2 y2] - [x1 y1]);

end
