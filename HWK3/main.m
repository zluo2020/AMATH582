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

