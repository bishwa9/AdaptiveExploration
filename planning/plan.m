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


%%%TODO : ADD BP to trace path

global w1; %weight for heurstic expansion
global w2; %weight for additional heuristic expansion

w1=5;
w2=2.5;

inf =9999;

%%compute heuristics

%hmap=getHmap();
%h=computeAnchorHeuristics(size(hmap));

hmap=ones(100,100);
h=ones(100,100);


start_id=10;
goal_id=2;

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
bp(goal_id)=-1;

open_h=[open_h start_id]

g(goal_id)=inf;

found=false;
mapSize=size(hmap);

visited=[];

while(size(open_a,2)~=0 && found==false)
    
    fmin=9999;
    idx_a=0;
    
    %%%Anchor%%
    for (i=1:size(open_a,2)) %%Evaluating Open0.Minkey()
        
        f=f_a(i);
        if f<fmin
            idx_a=i;
            fmin=f;
        end
    end
    minkey_a=fmin;
    %%%%Heuristic%%%
    
    fmin=9999;
    idx_h=0;
    for (i=1:size(open_h,2))
        
        f=f_h(i);
        if f<fmin
            fmin=f;
            idx_h=i;
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












