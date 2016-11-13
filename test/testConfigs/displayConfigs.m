clear;

addpath('../testConfigs/');

%% Get Test configurations
fileID = fopen('realData_randomTest1000.txt','r');

dists = []

line = fgetl(fileID)

%lines_fig = figure();
%hold on;
%axis([1, 400, 1, 400]);
dist_fig = figure();
while (line ~= -1)
    newCase = ~isempty( strfind(line, 'Test') );
    
    if newCase
        %% read test configuration
        fileName_line = strsplit(fgetl(fileID));
        fileName = fileName_line(1, 2);
        
        bounds_s_line = strsplit(fgetl(fileID));
        mapBounds = [str2double(bounds_s_line(2)), ...
                     str2double(bounds_s_line(3)), ...
                     str2double(bounds_s_line(4)), ...
                     str2double(bounds_s_line(5)), ...
                     str2double(bounds_s_line(6)), ...
                     str2double(bounds_s_line(7))];
        
        st_s_line = strsplit(fgetl(fileID));
        start_config = [str2double( st_s_line(2) ), ...
                        str2double( st_s_line(3) )];
        
        g_s_line = strsplit(fgetl(fileID));
        goal_config = [str2double( g_s_line(2) ), ...
                       str2double( g_s_line(3) )];
                 
        eucliDist = pdist2(start_config, goal_config);           
        dists = [dists, eucliDist];
        
        %figure(lines_fig);
        %plot([start_config(1), goal_config(1)], ...
        %     [start_config(2), goal_config(2)], 'r');
        %drawnow;
        
        line = fgetl(fileID); %skip a line
        line = fgetl(fileID)
    else
        disp 'PROBLEM IN FILE CONFIGURATION!';
        break;
    end
    
end

%% Plot Statistics
figure(dist_fig);
scatter([1:size(dists,2)], dists); title('Distances'); xlabel('t'); ylabel('Distance');
avgDist = mean(dists)

%% End
fclose(fileID);