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
