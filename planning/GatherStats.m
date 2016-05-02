global path;
global mapSize;


plan(472.0649);
sampled=[];
start_id=1;
[x y]= ind2sub(mapSize,start_id);
start_config=[x y];

entropyRed=0;
hmap = getHmap(start_config',valuemap);
Ent= sum(sum(sum(hmap)));
for i=1:size(path,2)
    [x y]= ind2sub(mapSize,path(i));
    config= [x y]'
    sampled=[sampled config];
    hmap = getHmap(sampled,valuemap);
    entropyRed= entropyRed + sum(sum(Ent)) - sum(sum(sum(hmap)));
    Ent= hmap;
    
    
end