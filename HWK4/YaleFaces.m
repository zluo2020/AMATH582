clear all; clc;

% convert '1' to '01' format
numFolder = cellstr(num2str((1:39).', '%02d'));

croppedData = [];

for i = 1:39
    % directory path
    dir_to_search = strcat('H:\AMATH 582\HWK4\CroppedYale\yaleB',string(numFolder(i)));
    
    % dictionary of PGM file
    pgmpattern = fullfile(dir_to_search, '*.PGM');
    
    dinfo = dir(pgmpattern);
    
    for j = 1:length(dinfo)
        % file name
        pgmfile = fullfile(dir_to_search, dinfo(j).name);
        
        % read pgm file as image data
        data = imread(pgmfile);
        
        dataReshaped = reshape(data,[],1);
        
        croppedData = [croppedData, dataReshaped];
    end
        
end
%% Image Processing and SVD

% convert uint8 data into double
croppedData = double(croppedData);
[u,s,v] = svd(croppedData, 'econ'); % perform SVD

numOfModes = nnz(diag(s));

%% SVD Plots
figure(1)
plot(diag(s)/sum(diag(s)),'ko')
ylabel('Singular Value Percentage')
xlabel('Modes')
title('Singular values of Cropped Picture')
%%
percentage = diag(s)/sum(diag(s));
sum_var = 0;
for i = 1:length(percentage)
    sum_var = sum_var + percentage(i);
    if sum_var > 0.9
        break;
    end
end
i
% Answer: How many modes are necessary for good image reconstructions?
% What is the rank r of the face space?
%%
figure(2)
for i = 1:4
    subplot(2,2,i) % generic faces
    genericface = reshape(u(:,i),[192,168]);
    pcolor(genericface),shading flat, colormap gray, axis ij;
    title(strcat('Principal Component ',{' '}, string(i))) 
end
%% Reconstruction Cropped Faces with different number of modes
figure(3)

reconstruct(80, 1, u, s, v, croppedData, 192, 168)

%% Uncropped Images
uncroppedData = [];

dir_to_search2 = 'H:\AMATH 582\HWK4\yalefaces';
    
    % dictionary of PGM file
listing = fullfile(dir_to_search2);
    
dinfo2 = dir(listing);

for i = 3:length(dinfo2)
    file = fullfile(dir_to_search2, dinfo2(i).name);
    imdata = imread(file);
    imdata = reshape(imdata,[],1);
    uncroppedData = [uncroppedData, imdata];
end
uncroppedData = double(uncroppedData);
%%
[u2,s2,v2] = svd(uncroppedData, 'econ'); % perform SVD
nnz(u2);
%%
figure(4)
plot(diag(s2)/sum(diag(s2)),'ko')
ylabel('Singular Value Percentage')
xlabel('Modes')
title('Singular values of Uncropped Picture')
%%
figure(5)
for i = 1:4
    subplot(2,2,i) % generic faces
    genericface = reshape(u2(:,i),[243, 320]);
    pcolor(genericface),shading flat, colormap gray, axis ij;
    title(strcat('Principal Component ',{' '}, string(i))) 
end
%%
reconstruct(125,45,u2,s2,v2,uncroppedData, 243, 320)

%%

function [] = reconstruct(numOfModes, imageID, u, s, v, data, pixelx,pixely)
    reconstruction1 = u(:,1:numOfModes) * s(1:numOfModes,1:numOfModes) * v(:,1:numOfModes)';
    reconstruction2 = u(:,1:5) * s(1:5,1:5) * v(:,1:5)';
    reconstruction3 = u(:,1:90) * s(1:90,1:90) * v(:,1:90)';
    subplot(2,2,1)
    imshow(uint8(reshape(data(:,imageID),pixelx,pixely)));
    title('Original Image')
    subplot(2,2,2)
    imshow(uint8(reshape(reconstruction2(:,imageID),pixelx,pixely)));
    title(strcat('Reconstructed Image', ' r = ', string(5)))
    subplot(2,2,3)
    imshow(uint8(reshape(reconstruction3(:,imageID),pixelx,pixely)));
    title(strcat('Reconstructed Image', ' r = ', string(90)))
    subplot(2,2,4)
    imshow(uint8(reshape(reconstruction1(:,imageID),pixelx,pixely)));
    title(strcat('Reconstructed Image', ' r = ', string(numOfModes)))
end
