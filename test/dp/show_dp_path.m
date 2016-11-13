figure;
imagesc(valuemap);
hold on;
plot(dp_path_y, dp_path_x, 'r', 'LineWidth',2);

path = sub2ind([100,100],dp_path_x,dp_path_y);
