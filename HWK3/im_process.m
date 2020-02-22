function [x_loc, y_loc] = im_process(file, window, threshold_x, threshold_y)
    vid_data = load(file);
    cam_data = cell2mat(struct2cell(vid_data));
    s = size(cam_data);
    num_of_frames = s(4)
    
    x_start = window(1);
    x_end = window(2);
    y_start = window(3);
    y_end = window(4);

    x_loc = zeros(1,num_of_frames);
    y_loc = zeros(1,num_of_frames);
    for n = 1:num_of_frames
        frame = cam_data(:,:,:,n);
        filter = create_filter(x_start,x_end,y_start,y_end);
        [x,y] = find_loc(filter, frame, threshold_x, threshold_y);
        % based on average intensity point, we apply a filter again to 
        % get rid of the white area below the flashlight
        %filter2 = create_filter(double(x)-20,double(x)+30,double(y)-80, double(y)+10);
        %[x,y] = find_loc(filter2, frame,0.1,1);
        plot_frame = double(frame).*filter;
        imshow(uint8(plot_frame))
        hold on
        plot(x, y,'r.','markersize',20)
        pause(0.1)
        x_loc(n) = x;
        y_loc(n) = y;
    end
    
    figure(2)
    plot(1:1:num_of_frames,480-y_loc)
end
