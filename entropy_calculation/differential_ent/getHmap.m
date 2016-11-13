function [Hmap] = getHmap(sampled_points, valuemap)
% This function takes in sampled points and outputs the entropy of those
% points which each of the remaining points in the map
% sampled points: size - Nx2, N is the number of points, 2 correspond to
% the number of dimension, in this case 2D 
pi=22/7;
%finding the indices of sampled points so that they can be removed from the
%list when the whole map is vectorized
%sampled_points=[1 1] % remove this. it should be passed into the function
nvisiblechans=size(valuemap,3);
vect_channel = zeros(size(valuemap,1)*size(valuemap,2),3);
sampled_vals = zeros(size(sampled_points,2),1);
for i=1:nvisiblechans
    vect=valuemap(:,:,i);
    vect_channel(:,i)=vect(:);
    sampled_vals(:,i)=diag(valuemap(sampled_points(1,:),sampled_points(2,:),i));
end
V = zeros(size(vect_channel,1),3);
for i=1:nvisiblechans
    sampled_channel=sampled_vals(:,i)';
    sampled_channel_vals=repmat(sampled_channel,size(vect_channel,1),1);
    var_vect=horzcat(sampled_channel_vals,vect_channel(:,i));
    V(:,i)=var(var_vect,0,2);
end
% entropy of sampled points with each un-sampled point
HS=0.5*sum(log(2*pi*V),2);
HS(HS==-Inf)=min(setdiff(HS(:),min(HS(:))));
Hmap=reshape(HS,size(valuemap,1),size(valuemap,2));


