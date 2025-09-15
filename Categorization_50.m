clear;
% Test Accuracy = 99.50%
%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0,'defaultlinelinewidth',3)
set(0,'DefaultAxesFontSize',18)
set(0,'DefaultTextFontSize',18)
rng(1);

XTrain = [];
YTrain = [];

mmin = 154;
mmax = 355;

load ./files_mn_mat_big/SiNtraining_Dint_SM1_50.mat
Dint_Dataset = Dints_50(:,(m_values>=mmin & m_values<=mmax));
XTrain = [XTrain; Dint_Dataset/5e11];
YTrain = [YTrain; ones(length(Dint_Dataset),1)];

load ./files_mn_mat_big/SiNtraining_Dint_SM2_50.mat
Dint_Dataset = Dints_50(:,(m_values>=mmin & m_values<=mmax));
XTrain = [XTrain; Dint_Dataset/5e11];
YTrain = [YTrain; 2*ones(length(Dint_Dataset),1)];

load ./files_mn_mat_big/SiNtraining_Dint_SM3_50.mat
Dint_Dataset = Dints_50(:,(m_values>=mmin & m_values<=mmax));
XTrain = [XTrain; Dint_Dataset/5e11];
YTrain = [YTrain; 3*ones(length(Dint_Dataset),1)];

load ./files_mn_mat_big/SiNtraining_Dint_SM4_50.mat
Dint_Dataset = Dints_50(:,(m_values>=mmin & m_values<=mmax));
XTrain = [XTrain; Dint_Dataset/5e11];
YTrain = [YTrain; 4*ones(length(Dint_Dataset),1)];

XTest = [];
YTest = [];

load ./files_mn_mat_big/SiNtest_Dint_SM1_50.mat
Dint_Dataset = Dints_50(:,(m_values>=mmin & m_values<=mmax));
XTest = [XTest; Dint_Dataset/5e11];
YTest = [YTest; ones(50,1)];


load ./files_mn_mat_big/SiNtest_Dint_SM2_50.mat
Dint_Dataset = Dints_50(:,(m_values>=mmin & m_values<=mmax));
XTest = [XTest; Dint_Dataset/5e11];
YTest = [YTest; 2*ones(50,1)];

load ./files_mn_mat_big/SiNtest_Dint_SM3_50.mat
Dint_Dataset = Dints_50(:,(m_values>=mmin & m_values<=mmax));
XTest = [XTest; Dint_Dataset/5e11];
YTest = [YTest; 3*ones(50,1)];

load ./files_mn_mat_big/SiNtest_Dint_SM4_50.mat
Dint_Dataset = Dints_50(:,(m_values>=mmin & m_values<=mmax));
XTest = [XTest; Dint_Dataset/5e11];
YTest = [YTest; 4*ones(50,1)];

% Convert data to proper format
YTrain = categorical(YTrain); % convert integer labels to categorical
YTest  = categorical(YTest);

% Define network architecture
layers = [
    featureInputLayer(202)              % input size = number of features
    fullyConnectedLayer(64)             % hidden layer 1
    tanhLayer                           % good for [-1,1] inputs
    fullyConnectedLayer(32)             % hidden layer 2
    reluLayer                           % mix of activations often helps
    fullyConnectedLayer(4)              % output layer = # of classes
    softmaxLayer                        % softmax for multi-class
    classificationLayer];

% Training options
options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 32, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XTest, YTest}, ...
    'Verbose',false, ...
    'Plots','training-progress');

% Train the network
net = trainNetwork(XTrain, YTrain, layers, options);

% Evaluate on test set
YPred = classify(net, XTest);

accuracy = mean(YPred == YTest);
disp(['Test Accuracy = ' num2str(accuracy*100, '%.2f') '%']);

% Plot confusion chart
figure;
confusionchart(YTest, YPred);
title('50 MHz Random Noise');

save ./files_mat_results/pred_vs_truth_50.mat YTest YPred