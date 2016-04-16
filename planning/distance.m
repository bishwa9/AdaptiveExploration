function [ d ] = distance( id1,id2)
%find distance between two indices on a map

global mapSize;
[x1 y1]= ind2sub(mapSize,id1);
[x2 y2]=ind2sub(mapSize,id2);

d= norm( [x2 y2] - [x1 y1]);

end

