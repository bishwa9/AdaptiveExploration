function [ s_ ] = getSuccessors( s,mapSize )
%find the successors of the given node in the given map
[x y]=ind2sub(mapSize,s);
s_=[];
for i=-1:1
    for j=-1:1
        if i==0 && j==0
            continue;
        end
        x_new=x+i
        y_new=y+j
        if (x_new)>0 && (x_new)<=mapSize(2) && (y_new)>0 && (y_new)<=mapSize(1)
            
            s_=[s_ sub2ind(mapSize,x_new,y_new)];
        end
    end
    
end


