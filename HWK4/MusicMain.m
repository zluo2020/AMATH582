%% Load Data
clear all; clc;

supfolder = 'H:/AMATH 582/HWK4/Music2/';
data_eminem = load_artist_data(supfolder, 'Eminem');
data_lindsey = load_artist_data(supfolder, 'Lindsey Stirling');
data_michael = load_artist_data(supfolder,'Michael Jackson');
data_lil = load_artist_data(supfolder,'Lil Wayne');
data_travis = load_artist_data(supfolder,'Travis Scott');
%%
% Hip-hop: Eminem; 
% Pop: Michael Jackson; 
% Electronic dubstep: Lindsey Stirling
A = zeros(30, 294921); % SVD matrix
for i = 1:10
    A(i,:) = data_eminem{i}';
    A(i+10,:) = data_lil{i}';
    A(i+20,:) = data_travis{i}';
end
[u,s,v] = svd(A','econ');
%plot(diag(s)/sum(diag(s)), 'bo', 'Linewidth', 2);
feature_eminem = v(1:10, :);
feature_lil = v(11:20, :);
feature_travis = v(21:30, :);
%%
[train_eminem, test_eminem] = train_test_split(feature_eminem, 0.8);
[train_lil, test_lil] = train_test_split(feature_lil, 0.8);
[train_travis, test_travis] = train_test_split(feature_travis, 0.8);
%%
training_set_case1 = [train_eminem;train_lil;train_travis];
test_set_case1 = [test_eminem;test_lil;test_travis];
labels_case1 = [ones(8,1);2*ones(8,1);3*ones(8,1)];
test_labels_case1 = [1 ;1 ;2 ;2; 3; 3];
%%
LCA_accuracy = zeros(2,30);
DCT_accuracy = zeros(2,30);
KNN_accuracy = zeros(2,30);
for r = 1:30
    M = fitmodels(training_set_case1(:,1:r), labels_case1, test_set_case1(:,1:r), test_labels_case1);
    LCA_accuracy(1,r) = M(1,1);
    LCA_accuracy(2,r) = M(1,2);
    DCT_accuracy(1,r) = M(2,1);
    DCT_accuracy(2,r) = M(2,2);
    KNN_accuracy(1,r) = M(3,1);
    KNN_accuracy(2,r) = M(3,2);
end
%%
figure(1)
plot(1:30, LCA_accuracy(1,:),1:30, DCT_accuracy(1,:),1:30, KNN_accuracy(1,:))
ylim([0 1])
xlabel('Number of Features')
ylabel('In Sample Accuracy')
title('In sample Accuracy vs. Feature [Wihtin Same Genre]')
legend('LCA','Decision Tree','KNN')

figure(2)
plot(1:30, LCA_accuracy(2,:),'-bo',1:30, DCT_accuracy(2,:),'-ro',1:30, KNN_accuracy(2,:),'-o')
ylim([0 1])
xlabel('Number of Features')
ylabel('Out of Sample Accuracy')
title('Out of sample Accuracy vs. Feature [Wihtin Same Genre]')
legend('LCA','Decision Tree','KNN')

%%
function M =  fitmodels(training_set, labels, test_set, test_labels)

    mdl_LCA = fitcdiscr(training_set, labels);
    mdl_dct = ClassificationTree.fit(training_set, labels);
    mdl_knn = fitcknn(training_set, labels);
    
 
    [insample_accuracy_LCA ,outsample_accuracy_LCA] =  accuracy(mdl_LCA, training_set, labels, test_set, test_labels);
    [insample_accuracy_dct ,outsample_accuracy_dct] =  accuracy(mdl_dct, training_set, labels, test_set, test_labels);
    [insample_accuracy_knn ,outsample_accuracy_knn] =  accuracy(mdl_knn, training_set, labels, test_set, test_labels);
    
    M = [insample_accuracy_LCA outsample_accuracy_LCA;
         insample_accuracy_dct outsample_accuracy_dct;
         insample_accuracy_knn outsample_accuracy_knn];
end
%% 
function [insample_accuracy, outsample_accuracy] = accuracy(model, training_set, labels, test_set, test_labels)

    pred_c = predict(model, training_set);
    insample_accuracy = mean(labels == pred_c);
    pred_c = predict(model, test_set);
    outsample_accuracy = mean(test_labels == pred_c);
end
%% 
function [train_set, test_set] = train_test_split(data, train_size)
    N = size(data,1);
    idx = randperm(N);
    train_set = data(idx(1:round(N*train_size)),:);
    test_set = data(idx(round(N*train_size)+1:end),:);
end
%%
function [data] = load_artist_data(supfolder, artist)

    data = cell(1,10);
    
    dir_to_search = strcat(supfolder, artist);  
    wavpattern = fullfile(dir_to_search, '*.wav');  
    dinfo = dir(wavpattern);

    for i = 1:10
        filename = dinfo(i).name;
        filepath = fullfile(dir_to_search, filename);
        % load audio file
        [y, fs] = audioread(filepath);
        % convert data into single stereo
        y_single = y(:,1);
        % generate spectrogram with window applied
        spec = spectrogram(y_single, fs);

        spec_reshaped = reshape(real(spec),[294921,1]);
        data{i} = spec_reshaped;
    end
end
