clear all; close all; clc;
file = 'cam1_1';
window = [250 435 200 400]; % camera 1
%window = [200 400 50 400]; % camera 2
%window = [250 400 150 350]; % camera 3
[x_loc, y_loc] = im_process(file, window, 0.5,0.1);
%% Smooth data using Moving average
t = 1:length(y_loc);
window = 15;
meanloc = movmean(y_loc, window);
subplot(3,1,1)
plot(t, y_loc, t, meanloc)
axis tight
Smooth data using Svitzky-Golay
Asgolay_y = smoothdata(y_loc, 'sgolay');
Asgolay_x = smoothdata(x_loc,'sgolay');
subplot(3,1,2)
subplot(2,1,1)
plot(t, y_loc, t, Asgolay_y)
axis tight
subplot(2,1,2)
plot(t, x_loc, t, Asgolay_x)
Smooth data using robust Lowess method
[Arlowess, window] = smoothdata(y_loc, 'rlowess',8);
subplot(3,1,3)
plot(t, y_loc, t, Arlowess)
axis tight

y_loc = Asgolay_y;
x_loc = Asgolay_x;
%% Run PCA against different experiment
PCA(4,1)
function [x,y] = find_loc(filter, frame, threshold_x,threshold_y)
    frame = double(frame);
    frame(:,:,1) = frame(:,:,1).*filter;
    frame(:,:,2) = frame(:,:,2).*filter;
    frame(:,:,3) = frame(:,:,3).*filter;
    
    gy_frame = rgb2gray(uint8(frame));
    
    [row,col] = find(gy_frame==max(max(gy_frame)));
    
    m = [col'; row'];
    m = m(:,find(m(2,:) <= quantile(row,threshold_y)));
    m = m(:,find(m(1,:) <= quantile(m(1,:),threshold_x)));

    x = mean(m(1,:));
    y = mean(m(2,:));
end

function filter = create_filter(x_start, x_end, y_start, y_end)
    % initialize a filter with same resolution
    filter = zeros(480, 640);
    filter(y_start:y_end,x_start:x_end) = ones(1,1);
end

function [x_loc,y_loc] = get_trajectory(file,window, threshold_x,threshold_y)
    [x_loc,y_loc] = im_process(file, window, threshold_x, threshold_y);
end

function [x_loc, y_loc] = im_process(file, window, threshold_x, threshold_y)
    vid_data = load(file);
    cam_data = cell2mat(struct2cell(vid_data));
    s = size(cam_data);
    num_of_frames = s(4);
    
    x_start = window(1);
    x_end = window(2);
    y_start = window(3);
    y_end = window(4);

    x_loc = zeros(1,num_of_frames);
    y_loc = zeros(1,num_of_frames);
    
    y_prev = 0;
    for n = 1:num_of_frames
        frame = cam_data(:,:,:,n);
        filter = create_filter(x_start,x_end,y_start,y_end);
        [x,y] = find_loc(filter, frame, threshold_x, threshold_y);
        % based on average intensity point, we apply a filter again to 
        % get rid of the white area below the flashlight
        filter2 = create_filter(double(x)-20,double(x)+30,double(y)-50, double(y)+10);
        [x,y] = find_loc(filter2, frame,0.1,1);
        plot_frame = double(frame).*filter2;
        imshow(uint8(plot_frame))
        hold on
        plot(x, y,'r.','markersize',20)
        pause(0.1)
        
        x_loc(n) = x;
        y_loc(n) = y;

    end
    
    figure(2)
    plot(1:1:num_of_frames,y_loc)
end

function PCA(experiment,smooth)
    loc_name = {'x_loc','y_loc'};
    data = struct;
    min_length = intmax;

    for i = 1:3
        if smooth == 1
            filename = strcat('smoothv',string(i),'_',string(experiment),'.mat');
        else
            filename = strcat('v',string(i),'_',string(experiment),'.mat');
        end
        cam = load(filename, loc_name{:});
        
        if length(cam.x_loc) < min_length
            min_length = length(cam.x_loc);
        end

        data(i).loc = cam;
    end

    t = 1:min_length;
    X = [data(1).loc.x_loc(1:min_length);
         data(1).loc.y_loc(1:min_length);
         data(2).loc.x_loc(1:min_length);
         data(2).loc.y_loc(1:min_length);
         data(3).loc.x_loc(1:min_length);
         data(3).loc.y_loc(1:min_length);
        ];

    mean_row = mean(X,2);

    for row = 1:6
        X(row,:) = X(row,:) - mean_row(row);
    end

    [u, s, v] = svd(cov(X'));

    sig = diag(s);

    figure(1)
    plot(sig/sum(sig), 'bo', 'Linewidth', 2);
    ylabel('Energy')
    xlabel('Mode')
    title(strcat('Principal Components Analysis Experiment',{' '},string(experiment)));
    % Projection of the original data onto the principal component basis
    Y = u' * X;
    figure(2)
    plot(t,Y(4,:),t,Y(5,:),t,Y(6,:))
    legend('Model 1','Model 2','Model 3')
    xlabel('time')
    ylabel('Height')
    ylim([-100 100])
    xlim([0 min_length])
    title('Principal Components Projection (Y direction)')
    
end
