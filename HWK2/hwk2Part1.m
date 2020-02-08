clear all; close all; clc;
load handel
%[y,Fs] = audioread(filename),y:sample data, Fs: sample rate
v = y'/2;
subplot(2,1,1), plot((1:length(v))/Fs,v,'Color','blue');
xlabel('Time(t)');
ylabel('v(t)');
title('Handel''s Messiah Signal');

%% Preview of signal file and FFT value
% L units of time
L = length(v)/ Fs;
n = length(v); % Fourier modes
t2 = linspace(0,L,n); t = t2(1:n);
df = Fs/n; % incremental frequency = sampling reate / number of points
ks = (2*pi/L)*((0:df:(Fs-df)) - (Fs-mod(n,2)*df)/2);
vt = fft(v);
subplot(2,1,2), plot(ks, abs(fftshift(vt))/max(abs(vt)),'Color','blue');
xlabel('Frequency (\omega)');
ylabel('FFT(v)');
title('FFT Vs. Frequency');

%% GABOR WINDOW
figure(2)
width = [10 1 0.2];
for j = 1:3
    g = exp(-width(j)*(t-4).^2);
    subplot(3,1,j)
    plot(t,v,'k','Color','blue'), hold on
    plot(t,g,'k','Color','red')
    ylabel('v(t), g(t)')
end
xlabel('time (t)')
sgtitle('Gabor Window with different width','Fontsize',[10])

%% Construct filters
gaussian = @(x,width) exp(-width*(x).^2);
super_gaussian = @(x,width) exp(-width*(x).^10);
mexican_hat = @(x,width) (1-(x/width).^2).*exp(-((x/width).^2)/2);
shannon = @(x,width) (x>-width/2 & x<width/2);
%% Gabor Transform
figure(3)
Vgt_spec=[];
tslide=linspace(0,t(end-1),1000);
for j = 1:length(tslide)
    % g = gaussian/super_guassian/mexican_hat/shannon
    g = gaussian(t-tslide(j),1);
    Vg = g.*v;
    Vgt=fft(Vg);
    Vgt_spec=[Vgt_spec;abs(fftshift(Vgt))];
    subplot(3,1,1), plot(t,v,'k',t,g,'r')
    subplot(3,1,2), plot(t,Vg,'k')
    subplot(3,1,3), plot(ks,abs(fftshift(Vgt))/max(abs(Vgt)))
    drawnow
    pause(0.1)
end
%% Spectrogram
figure(4)
pcolor(tslide, ks, Vgt_spec.'),
shading interp
colormap(hot), xlabel('Time(t)'), ylabel('Frequency')
