function filter = create_filter(x_start, x_end, y_start, y_end)
    % initialize a filter with same resolution
    filter = zeros(480, 640);
    filter(y_start:y_end,x_start:x_end) = ones(1,1);
end
