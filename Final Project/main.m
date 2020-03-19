%% Construct datastore for images
clear all; close all; clc;
datafolder = 'cell_images';
%creates a datastore imds from the collection of malaria images
imds = imageDatastore(datafolder,...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

%returns a summary table of 'parasitized' vs 'uninfected' cell
T = countEachLabel(imds);
%% Create K-folder Cross Validation Architecture
% Notice that one should not rerun this part of code
% The data is saved in KfolderDataStore
k = 5;
partitionStore{k} = [];

% Shuffle the dataset randomly and split the dataset into 5 partitions
shuffled_imds = shuffle(imds);

% iterate over datastore for partitioning
for i = 1 : k
    temp = partition(shuffled_imds, k, i);
    partitionStore{i} = temp.Files;
end


% Cross validation index 
idx = crossvalind('Kfold', k, k);

% save train set and validation set for later use
% test_collection = struct;
% train_collection = struct;

test_idx = (idx == 1);
train_idx = ~test_idx;
    
test_collection =  imageDatastore(partitionStore{test_idx}, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
train_collection = imageDatastore(cat(1, partitionStore{train_idx}), 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

%% Preprocessing for the data
load KfolderDataStore
%%
T1 = countEachLabel(train_collection.trial1);
T2 = countEachLabel(test_collection.trial1)

%% Construct SVD matrix
Total_count = T1.Count(1) + T1.Count(2);
Parasitized = zeros(250, 250, T1.Count(1));
Uninfected = zeros(250, 250, T1.Count(2));

idx_uninfected = 0;
idx_parasitized = 0;
%%
for i = 1:Total_count
    i
    label = string(train_collection.trial1.Labels(i));
    img = readimage(train_collection.trial1,i);
    img_processed = preprocessing(img);
    
    if strcmp(label, 'Uninfected')
        idx_uninfected = idx_uninfected + 1;
        Uninfected(:,:,idx_uninfected) = img_processed;
    else
        idx_parasitized = idx_parasitized + 1;
        Parasitized(:,:,idx_parasitized) = img_processed; 
    end
end
%% 
% wavelet transform
%[cA, cH, cV, cD] = dwt2(img_processed, 'db1');

%% TODO. ImageDatastore trainer
% extractorFcn = @SVDExtractor;
%bag = bagOfFeatures(train_collection,'CustomExtractor',extractorFcn);

%function [features, featureMetrics ] = SVDExtractor(img)
% img: Binary, grayscale, or truecolor image
% features: An M-by-N matrix of image features, where M is the number of
% features and N is the length of each feature vector
% featureMetrics: An M-by-1 vector of feature metrics indicating the
% strength of each feature vector
%end
training_parasitized = wavelet_transform(Parasitized);
training_uninfected = wavelet_transform(Unifected);
%% Memory too
A = [(training_parasitized(:,1:1000))'; (training_uninfected(:,1:1000))'];
[u,s,v] = svd(A', 0);
%%
feature_parasitized = v(1:1000,:);
feature_uninfected = v(1001:2000,:);
[train_parasitized, test_parasitized] = train_test_split(feature_parasitized, 0.8); 
[train_uninfected, test_uninfected] = train_test_split(feature_uninfected, 0.8); 

training_data = [train_parasitized;train_uninfected];
labels = [ones(800,1);2*ones(800,1)];
mdl_svm = fitcsvm(training_data,labels);
%% 
pred_c = predict(mdl_svm, training_data);
insample_accuracy = mean(labels == pred_c);

%%
function waveletData = wavelet_transform(data)
    s = size(data);
    row = s(3);
    nw = 125 * 125;
    nbcol = size(colormap(gray),1);
    
    for i = 1: row
        X = data(:,:,i);
        [cA, cH, cV, cD] = dwt2(X, 'db1');
        cod_cH1 = wcodemat(cH,nbcol);
        cod_cV1 = wcodemat(cV,nbcol);
        cod_edge=cod_cH1+cod_cV1;
        waveletData(:,i)=reshape(cod_edge,nw,1);
    end
end
        
function [train_set, test_set] = train_test_split(data, train_size)    
    N = size(data,1);  
    idx = randperm(N);    
    train_set = data(idx(1:round(N*train_size)),:);   
    test_set = data(idx(round(N*train_size)+1:end),:); 
end          
