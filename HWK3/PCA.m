function PCA(experiment,smooth)
    % 1 = smooth on
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
