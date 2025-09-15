clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0,'defaultlinelinewidth',3)
set(0,'DefaultAxesFontSize',18)
set(0,'DefaultTextFontSize',18)

rng(1);

% no of measurement in each region
Ns = [2:2:16];  % HAS TO BE AN EVEN NUMBER
no_of_trials = 40;

XTrain = [];
YTrain = [];

mmin = 154;
mmax = 355;

load ./files_mn_mat_big/SiNtraining_Dint_SM1.mat
Dint_Dataset = Dints(:,(m_values>=mmin & m_values<=mmax));
XTrain = [XTrain; Dint_Dataset/5e11];
YTrain = [YTrain; ones(length(Dint_Dataset),1)];

load ./files_mn_mat_big/SiNtraining_Dint_SM2.mat
Dint_Dataset = Dints(:,(m_values>=mmin & m_values<=mmax));
XTrain = [XTrain; Dint_Dataset/5e11];
YTrain = [YTrain; 2*ones(length(Dint_Dataset),1)];

load ./files_mn_mat_big/SiNtraining_Dint_SM3.mat
Dint_Dataset = Dints(:,(m_values>=mmin & m_values<=mmax));
XTrain = [XTrain; Dint_Dataset/5e11];
YTrain = [YTrain; 3*ones(length(Dint_Dataset),1)];

load ./files_mn_mat_big/SiNtraining_Dint_SM4.mat
Dint_Dataset = Dints(:,(m_values>=mmin & m_values<=mmax));
XTrain = [XTrain; Dint_Dataset/5e11];
YTrain = [YTrain; 4*ones(length(Dint_Dataset),1)];

XTest = [];
YTest = [];

load ./files_mn_mat_big/SiNtest_Dint_SM1.mat
Dint_Dataset = Dints(:,(m_values>=mmin & m_values<=mmax));
XTest = [XTest; Dint_Dataset/5e11];
YTest = [YTest; ones(50,1)];


load ./files_mn_mat_big/SiNtest_Dint_SM2.mat
Dint_Dataset = Dints(:,(m_values>=mmin & m_values<=mmax));
XTest = [XTest; Dint_Dataset/5e11];
YTest = [YTest; 2*ones(50,1)];

load ./files_mn_mat_big/SiNtest_Dint_SM3.mat
Dint_Dataset = Dints(:,(m_values>=mmin & m_values<=mmax));
XTest = [XTest; Dint_Dataset/5e11];
YTest = [YTest; 3*ones(50,1)];

load ./files_mn_mat_big/SiNtest_Dint_SM4.mat
Dint_Dataset = Dints(:,(m_values>=mmin & m_values<=mmax));
XTest = [XTest; Dint_Dataset/5e11];
YTest = [YTest; 4*ones(50,1)];

% Convert data to proper format
YTrain = categorical(YTrain); % convert integer labels to categorical
YTest  = categorical(YTest);

Nall = 202;
N1 = round(Nall/3);
N2 = round(2*Nall/3);


accuracies = zeros(length(Ns), no_of_trials);
center1s= zeros(length(Ns), no_of_trials);
center2s= zeros(length(Ns), no_of_trials);
center3s= zeros(length(Ns), no_of_trials);

for iNs = 1:length(Ns)
    N = Ns(iNs);
    Nhalf = round(N/2);
    parfor trial_no = 1:no_of_trials

        center1 = randi([Nhalf+1, N1-Nhalf-1],1,1);
        center2 = randi([N1+1+Nhalf, N2-Nhalf-1],1,1);
        center3 = randi([N2+1+Nhalf, Nall-Nhalf-1],1,1);
        center1s(iNs,trial_no) = center1;
        center2s(iNs,trial_no) = center2;
        center3s(iNs,trial_no) = center3;        

        sampless = [center1-Nhalf:center1+Nhalf-1,center2-Nhalf:center2+Nhalf-1,center3-Nhalf:center3+Nhalf-1 ];

        % Define network architecture
        layers = [
            featureInputLayer(3*N)              % input size = number of features
            fullyConnectedLayer(64)             % hidden layer 1
            tanhLayer                           % good for [-1,1] inputs
            fullyConnectedLayer(32)             % hidden layer 2
            reluLayer                           % mix of activations often helps
            fullyConnectedLayer(4)              % output layer = # of classes
            softmaxLayer                        % softmax for multi-class
            classificationLayer];

        % Training options
        options = trainingOptions('adam', ...
            'MaxEpochs', 200, ...
            'MiniBatchSize', 32, ...
            'Shuffle','every-epoch', ...
            'ValidationData',{XTest(:,sampless), YTest}, ...
            'Verbose',false, ...
            'Plots','training-progress');

        % Train the network
        net = trainNetwork(XTrain(:,sampless), YTrain, layers, options);

        % Evaluate on test set
        YPred = classify(net, XTest(:,sampless));

        accuracy = mean(YPred == YTest);
        disp(['Test Accuracy = ' num2str(accuracy*100, '%.2f') '%']);

        accuracies(iNs, trial_no) = accuracy*100;
    end
end

figure(1); clf; 
plot(3*Ns, min(accuracies.'), 3*Ns, max(accuracies.'), 3*Ns, mean(accuracies.'), 3*Ns, median(accuracies.'))
grid on;
xlabel('Number of Measurements');
ylabel('Accuracy');
legend('Minimum','Maximum', 'Mean','Median','Location','NorthWest')

save ./files_mat_results/N_vs_cat_no_noise.mat accuracies Ns center1s center2s center3s