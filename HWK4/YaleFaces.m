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
plot(diag(s),'ko')
xlabel('Singular Values')
title('Singular values of the SVD decomposition of Cropped Picture')

% Answer: How many modes are necessary for good image reconstructions?
% What is the rank r of the face space?

figure(2)
for i = 1:4
    subplot(2,2,i) % generic faces
    genericface = reshape(u(:,i),[192,168]);
    pcolor(genericface),shading flat, colormap gray, axis ij;
end

%% Reconstruction Cropped Faces with different number of modes
figure(3)
reconstruct(80, 150, u, s, v, croppedData, 192, 168)

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
reconstruct(90,1,u2,s2,v2,uncroppedData, 243, 320)

%%

function [] = reconstruct(numOfModes, imageID, u, s, v, data, pixelx,pixely)
    reconstruction = u(:,1:numOfModes) * s(1:numOfModes,1:numOfModes) * v(:,1:numOfModes)';
    subplot(1,2,1)
    imshow(uint8(reshape(data(:,imageID),pixelx,pixely)));
    title('Original Image')
    subplot(1,2,2)
    imshow(uint8(reshape(reconstruction(:,imageID),pixelx,pixely)));
    title(strcat('Reconstructed Image', ' r = ', string(numOfModes)))
end
