function [output] = plan(alpha)


alpha 
global open_a;
global open_h;
global bp;
global closed_a;
global closed_h;
global mapSize;
global visited;
global h;
global hmap;
global g;
global f_a;
global f_h;
global valuemap;

plotPath=1;

tic;
bp=[];

start_id=110;
goal_id=4580;
hmap=zeros(100,100);
mapSize=size(hmap);


%alpha= 200 % factor for weighing information against

[x y]= ind2sub(mapSize,start_id);
start_config=[x y];

global w1; %weight for heurstic expansion
global w2; %weight for additional heuristic expansion

w1=5;
w2=2;

inf =9999;

%%compute heuristics
toc;

% %hmap=getHmap();
h=computeAnchorHeuristics(size(hmap),goal_id);
toc;

%%rescaling information map based on heuristics
hmap = getHmap(start_config',valuemap);

toc;


minh=min(min(hmap)); maxh= max(max(hmap));

information= ((hmap - minh )./ (maxh-minh));
 

% for i=1:size(hmap,1)
%      for j=1:size(hmap,2)
%          hmap(i,j)=1 -((hmap(i,j)- minh)/ (maxh-minh));
%      end
%  end
hmap=1 - information;

hmap = alpha.*hmap;
% hmap=[hmap ; 50]
% hmap=ones(100,100);
% h=ones(100,100);

toc;


open_a=[];%open list for anchor search
open_h=[]; %open list for heuristic

g=[];
f_a=[];
f_h=[];
open_a=[open_a start_id];
open_h=[];

closed_h=[];
closed_a=[];

g(start_id)=0;
f_a(start_id)=0;
f_h(start_id)=hmap(start_id);
bp(start_id)=-1;

open_h=[open_h start_id];

g(goal_id)=inf;

found=false;

visited=[];

toc;
while(size(open_a,2)~=0 && found==false)
    
    fmin=9999;
    idx_a=0;
    
    %%%Anchor%%
    for (i=1:size(open_a,2)) %%Evaluating Open0.Minkey()
        
        f=f_a(open_a(i));
        if f<fmin
            idx_a=open_a(i);
            fmin=f;
        end
    end
    minkey_a=fmin;
    %%%%Heuristic%%%
    
    fmin=9999;
    idx_h=0;
    for (i=1:size(open_h,2))
        
        f=f_h(open_h(i));
        if f<fmin
            fmin=f;
            idx_h=open_h(i);
        end
    end
    
    minkey_h=fmin;
    
    if minkey_h<=w2*minkey_a
        
        if g(goal_id) <= minkey_h
            break;
        end
        
        s=idx_h;
        
        expand(s);   
        
        %%exapnsion in heuristic search
        closed_h=[closed_h s];
        open_h(open_h==s)=[];
        open_a(open_a==s)=[];
        
    else
        
        if g(goal_id) <= minkey_a
            break;
        end
        s=idx_a;
        expand(s);
        
        closed_a=[closed_a s];
        open_a(open_a==s)=[];
        open_h(open_h==s)=[];
    end
end

path=[];

state=goal_id;

while (state~=start_id)
    
    path=[path state];
    state=bp(state);


end

path = [path state];

path=fliplr(path);

if plotPath
figure();
imagesc(valuemap(:,:,1:3));
hold on;
[x y] =ind2sub(mapSize,path(:));

plot(x, y, 'lineWidth',2,'color','black');
xlim([0 100]);
ylim([0 100]);
hold on;


end

pathlength = size(path,2);
informationGained = 0;



for i=1:size(path,2)
    informationGained= informationGained + (information(path(i)));
end

output(1) =-pathlength
output(2) =informationGained




toc;








