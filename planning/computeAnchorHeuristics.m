function [ h ] = computeAnchorHeuristics( mapSize,goalID )
%COMPUTEANCHORHEURISTICS Summary of this function goes here
%   Detailed explanation goes here

h=zeros(mapSize);
[x y]=ind2sub(mapSize,goalID);

    for i=1:mapSize(1)
        for j=1:mapSize(2)
            h(i,j) = sqrt( (x-i)^2 + (y-j)^2);
        end
    end


end

