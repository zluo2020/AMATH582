clear all; clc;
%% Load Data
data_classical = loadgenre('classical');
data_jazz = loadgenre('jazz');
data_rock = loadgenre('rock');
%%
A = zeros(300, 110251); % SVD matrix
for i = 1:100
    A(i,:) = data_classical{i}';
    A(i+100,:) = data_jazz{i}';
    A(i+200,:) = data_rock{i}';
end
%%
[u,s,v] = svd(A','econ');
%plot(diag(s)/sum(diag(s)), 'bo', 'Linewidth', 2);
feature_classical = v(1:100, :);
feature_jazz = v(101:200, :);
feature_rock = v(201:300, :);
[train_classical, test_classical] = train_test_split(feature_classical, 0.8);
[train_jazz, test_jazz] = train_test_split(feature_jazz, 0.8);
[train_rock, test_rock] = train_test_split(feature_rock, 0.8);
%%
training_set = [train_classical;train_jazz;train_rock];
test_set = [test_classical;test_jazz;test_rock];
labels = [ones(80,1);2*ones(80,1);3*ones(80,1)];
test_labels= [ones(20,1);2*ones(20,1);3*ones(20,1)];
%%
LCA_accuracy = zeros(2,60);
DCT_accuracy = zeros(2,60);
KNN_accuracy = zeros(2,60);
for r = 1:60
    M = fitmodels(training_set(:,1:r), labels, test_set(:,1:r), test_labels)
    LCA_accuracy(1,r) = M(1,1);
    LCA_accuracy(2,r) = M(1,2);
    DCT_accuracy(1,r) = M(2,1);
    DCT_accuracy(2,r) = M(2,2);
    KNN_accuracy(1,r) = M(3,1);
    KNN_accuracy(2,r) = M(3,2);
end
%%
figure(1)
plot(1:60, LCA_accuracy(1,:),1:60, DCT_accuracy(1,:),1:60, KNN_accuracy(1,:))
ylim([0 1])
xlabel('Number of Features')
ylabel('In Sample Accuracy')
title('In sample Accuracy vs. Feature [Broader Genre]')
legend('LCA','Decision Tree','KNN')

figure(2)
plot(1:60, LCA_accuracy(2,:),1:60, DCT_accuracy(2,:),1:60, KNN_accuracy(2,:))
ylim([0 1])
xlabel('Number of Features')
ylabel('Out of Sample Accuracy')
title('Out of sample Accuracy vs. Feature [Broader Genre]')
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
function data = loadgenre(genre)

    dir_to_search = strcat('H:/AMATH 582/HWK4/Music/genres/', genre);
    data = cell(1,100);
    wavpattern = fullfile(dir_to_search, '*.wav');  
    dinfo = dir(wavpattern);

    for i = 1:100
        filename = dinfo(i).name;
        filepath = fullfile(dir_to_search, filename);
        data{i} = to_spectrogram(filepath);
    end
end
%%
function [clip, reshape_spec] = to_spectrogram(wavfile)
    [y, fs] = audioread(wavfile);
    t_start = 10 * fs;
    t_end = 15 * fs;
    clip = y(t_start:t_end);
    spec = spectrogram(clip, fs);
    spec_info = real(spec);
    reshape_spec = reshape(spec_info,[147465 1]);
end
function [train_set, test_set] = train_test_split(data, train_size)
    N = size(data,1);
    idx = randperm(N);
    train_set = data(idx(1:round(N*train_size)),:);
    test_set = data(idx(round(N*train_size)+1:end),:);
end
