function expand(s)

%EXPAND- implement the expand function in MHA*



global open_a;
global open_h;
global bp;
global closed_a;
global closed_h;
global mapSize;
global w1;
global w2;
global visited;
global h;
global hmap;
global g;
global f_a;
global f_h;


inf=99999;



s_=[];
s_= getSuccessors(s); %s_ is a 2D array of all the successors' indices

[cx cy] = ind2sub(mapSize,s)
cur_sub = [cx cy]

for i=1:size(s_,2)
    if ~any(visited==s_(i))
        g(s_(i))=inf;
        bp(s_(i))=-1;
        visited=[visited s_(i)];
    end
    [sx sy] = ind2sub(mapSize,s_(i))
    suc_sub = [sx sy]
    if (g(s_(i)) > g(s) + pdist2(cur_sub,suc_sub))
        g(s_(i))=g(s)+pdist2(cur_sub,suc_sub);
        bp(s_(i))=s;
        
        if (~any(closed_a==s_(i)))
            %%if not expanded in the anchor search
            if ~any(closed_a==s_(i))
                open_a=[open_a s_(i)];
                f_a(s_(i))= g(s_(i))+w1*h(s_(i));
            else
                f_a(s_(i))= g(s_(i))+w1*h(s_(i));
            end
        
        
        
            if (~any(closed_h==s_(i)))

                key_h=g(s_(i))+w1*hmap(s_(i));
                key_a=g(s_(i))+w1*h(s);
                if (key_h<= w2*key_a)
                    f_h(s_(i))= g(s_(i))+w1*h(s_(i));
                    if ~any(closed_h==s_(i))
                        open_h=[open_h s_(i)];
                    end
                end
            end
        end
    end
    
end