function [ d ] = distance( id1,id2,M)
%find distance between two indices on a map

[x1 y1]= ind2sub(id1);
[x2 y2]=ind2sub(id2);

d= norm( [x2 y2] - [x1 y1]);

end

