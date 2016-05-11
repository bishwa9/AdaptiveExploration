function createTestData( numOfMaps )
set(0,'DefaultFigureVisible','off')
addpath(genpath('../../../matlab_sim'))
    for i = 11:numOfMaps+10
        %%%%%%%%%%%%%%%%%%%%%
        % Random parameters
        max_class = 10;
        ndomclasses = randi([6,max_class-1]);
        nrareclasses = max_class - ndomclasses
        nclasses = ndomclasses + nrareclasses;
        
        siz = 200; %fixed size
        miscvar = .12; 
        sensorvar = .05;
        
        %fixed channels
        nchannels = 8;
        nvisiblechans = 3;
        
        a = 0;
        b = 0.1;
        probrare = (b-a).*rand(1,1) + a; %random number between 0 and 0.1
        clear('a','b','max_class')
        % End of Random parameters
        %%%%%%%%%%%%%%%%%%%%%
        
        name = 'testData';
        ext1 = '.mat'; ext2 = '.txt';
        file_name = sprintf('%s_%d%s',name, i, ext1);
        profile_name = sprintf('%s_%d%s',name, i, ext2);
        fileID = fopen(profile_name,'w');
        fprintf(fileID,'%s: %d\n','ndomclasses',ndomclasses);
        fprintf(fileID,'%s: %d\n','nrareclasses',nrareclasses);
        fprintf(fileID,'%s: %.06f\n','Probability of Rare Class',probrare);
        fprintf(fileID,'%s: %d\n','map size',siz);
        fprintf(fileID,'%s: %.06f\n','Inherent noise variance',miscvar);
        fprintf(fileID,'%s: %.06f\n','Sensor noise variance',sensorvar);
        fprintf(fileID,'%s: %d\n','Total Channels',nchannels);
        fprintf(fileID,'%s: %d\n','Satellite Channels',nvisiblechans);
        fclose(fileID);
        
        [classmap, valuemap, truevalue] = simulator...
            (ndomclasses, nrareclasses, siz, miscvar, ...
            sensorvar, nchannels, nvisiblechans, probrare);

        clear('i');
        save(file_name);
    end
set(0,'DefaultFigureVisible','on');
end
