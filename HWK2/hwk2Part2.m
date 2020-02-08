clear all; close all; clc;

tr_piano = 16; % record time in seconds
L = tr_piano;
[y,Fs] = audioread('music1.wav');
[y,Fs] = audioread('music2.wav');
y = y.';
n = length(y);
%figure()
%subplot(2,1,1), plot((1:length(y))/Fs, y);

t2=linspace(0,L,n+1); t=t2(1:n); 
k=(2*pi/L)*[0:n/2-1 -n/2:-1]; 
ks=fftshift(k);

%yt = fft(y);
%subplot(2,1,2), plot(ks, abs(fftshift(yt))/max(abs(yt)))

%% Gabor Window
%figure(2)
Ygt_spec=[];
tslide = linspace(0,t(end),100);
for j = 1:length(tslide)
    g=exp(-100*(t-tslide(j)).^2);
    Yg=g.*y;
    Ygt=fft(Yg);
    Ygt_spec=[Ygt_spec;abs(fftshift(Ygt))];
    %subplot(3,1,1), plot(t,y,'k',t,g,'r')
    %subplot(3,1,2), plot(t,Yg,'k')
    %subplot(3,1,3), plot(ks,abs(fftshift(Ygt))/max(abs(Ygt)))
    %drawnow
    %pause(0.1)
end

figure(3)
pcolor(tslide,ks,log(Ygt_spec.'+1)),shading interp
axis([0 15 20 4200])
colormap(hot)
    