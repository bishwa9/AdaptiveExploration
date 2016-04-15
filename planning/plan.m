w1=5; %weight for anchor heuristic
w2=2.5; %weight for information heuristic


hmap=getHmap();

open=[];
closed=[];

start_id=10
goal_id=2

g_values=[]
f_anchor=[]
f_information=[]
open=[open start]

g_values(start)=0;
f_anchor(start)=0;
f_information(start)=hmap(start)

found=false;
while(size(open,2)~=0 && found==false)
    
        fmin=999;
        idx=0;
        
        for (i=1:size(open,2))
            
            f=f_anchor(i)
            if f<fmin
                idx=i
                fmin=f
            end
        end
        
        closed=[closed idx];
        open(open==idx)=[];
        
        if (idx==goal_id)
            found=True;
            break;
        end
        
        successors=Successors(idx,closed);
        
        for (i =1:size(successors,2))
        
           g_values(i)=distance(idx,i);
           f_anchor(i)=distance(i,goal_id);
           open=[open i]
        end
           
end
        
        
    
    
    




