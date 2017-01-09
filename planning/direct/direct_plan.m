function [ path ] = direct_plan( start_config, goal_config )
    x0 = start_config(1,1);
    x1 = goal_config(1,1);
    y0 = start_config(1,2);
    y1 = goal_config(1,2);

	dx = abs(x1 - x0);
    dy = abs(y1 - y0);
    x = x0;
    y = y0;
    n_init = 1 + dx + dy;
    x_inc = 0; y_inc = 0;
    if(x1 > x0)
        x_inc = 1; 
    else
        x_inc = -1; 
    end
    if(y1 > y0)
        y_inc = 1; 
    else
        y_inc = -1; 
    end
    error = dx - dy;
    dx = dx * 2;
    dy = dy * 2;
    path = [];
    for n = n_init:-1:1
        path = vertcat(path, [x,y]);

        if (error > 0)
            x = x+ x_inc;
            error = error - dy;
        else
            y = y + y_inc;
            error = error + dx;
        end
    end
end

