w1=5; %weight for heurstic expansion
w2=2.5; %weight for additional heuristic expansion


hmap=getHmap();

inf =9999

h=computeAnchorHeuristics(size(hmap));

start_id=10
goal_id=2

open_a=[]%open list for anchor search
open_h=[] %open list for heuristic

g_values=[]
f_a=[]
f_h=[]
open_a=[open_a start]
open_h=[]

closed_h=[];
closed_a=[];

g_values(start_id)=0;
f_a(start_id)=0;
f_h(start)=hmap(start)

open_h=[open_h start_id]

g_values(goal_id)=inf;

found=false;
mapSize=size(hmap);
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
    idx_h=0
    for (i=1:size(open_h,2)
        
        f=f_h(i);
        if f<fmin
            fmin=f
            idx_h=i
        end
    end
    
    minkey_h=fmin
    
    if minkey_h<=w2*minkey_a
        
        if g(goal_id) <= minkey_h
            break;
        end
        
        s=idx_h
        
        expand(s) %%exapnsion in heuristic search
        closed_h=[closed_h s]
        
    else
        
        if g(goal_id) <= minkey_a
            break;
        end
        s=idx_a
        expand(s)
        closed_a=[closed_a s]
    end
end












