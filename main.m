clear all; close all; clc;
load Testdata
%% Setup
L=15; % define the spatial domain 
n=64; % define the number of Fourier modes 2^n
x2=linspace(-L,L,n+1); x=x2(1:n); y=x; z=x; % time discretization
k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);  
[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);

%% AVERAGE SIGNAL
Untave = zeros(n,n,n);
for j=1:20
    Un(:,:,:) = reshape(Undata(j,:),n,n,n);
    Unt = fftn(Un); % FFT the observation
    Untave = Untave + Unt; % Aggregate all 20 observations
end
Untave = Untave./20;
% isosurface?
%% CENTER FREQUENCY

% reshape and indexing the maximum
[max_val,index] = max((Untave(:)));
%  linear index to [row, column, slice] indices
[y,x,z]=ind2sub(size(Untave),index);

%% GAUSSIAN FILTER
tau = 1;
% filter = exp(-tau*((Kx - fx).^2 + (Ky - fy).^2 + (Kz - fz).^2));
filter = exp(-tau*((fftshift(Kx) - k(x)).^2 + (fftshift(Ky) - k(y)).^2 + (fftshift(Kz) - k(z)).^2));

%% LOOP OVER OBSERVATION AND FILTERING
trajectory = zeros(20, 3);
for j=1:20
    Un(:,:,:)=reshape(Undata(j,:),n,n,n);
    % FFT current observation
    Unt=fftn(Un);
    % filter data around the center frequency
    Unft = filter.* Unt;
    % inverse transform to get coordinate
    Unf = ifftn(Unft);
    % retrive coordiantes
    [max_val,index] = max(abs(Unf(:)));
    trajectory(j,:) = [X(index), Y(index), Z(index)];
end

%% PLOT FILTERED OBSERVATION
figure(2)
isosurface(X,Y,Z,abs(Unf)/max_val,0.8)
axis([-L L -L L -L L]),grid on, drawnow
xlabel('x'); ylabel('y');zlabel('z');

%% PLOT TRAJECTORY
figure(3)
plot3(trajectory(:,1),trajectory(:,2),trajectory(:,3),'-o')
axis([-L L -L L -L L]),grid on, drawnow
xlabel('x'); ylabel('y');zlabel('z');