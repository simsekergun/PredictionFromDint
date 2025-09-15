clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0,'defaultlinelinewidth',3)
set(0,'DefaultAxesFontSize',18)
set(0,'DefaultTextFontSize',18)

rng(1);

% no of measurement in each region
Ns = [2:2:16];  % HAS TO BE AN EVEN NUMBER
no_of_trials = 40;

load ./files_mn_mat_big/SiNtraining_Dint_SM1_200.mat
Dint_Dataset = Dints_200;
[adsa, Nall] = size(Dint_Dataset);
xmax = max(max(abs(Dint_Dataset)));
XTrain = Dint_Dataset/xmax;
YTrain = dimensions*1e7;
m_values_train = m_values;
lambdas_train = final_lambdas;

load('./files_mn_mat_big/SiNtest_Dint_SM1_200.mat')
Dint_TestDataset = Dints_200;

XTest = Dint_TestDataset/xmax;
YTest = dimensions*1e7;
m_values_test = m_values;
lambdas_test = final_lambdas;

% Normalize input and output to [-1, 1] using mapminmax
[XTrainNorm, inputSettings] = mapminmax(XTrain', -1, 1); % Transpose for mapminmax
[YTrainNorm, outputSettings] = mapminmax(YTrain', -1, 1);

XTrainNorm = XTrainNorm'; % Transpose back
YTrainNorm = YTrainNorm';

% Normalize XTest and YTest using training settings
XTestNorm = mapminmax.apply(XTest', inputSettings)';
YTestNorm = mapminmax.apply(YTest', outputSettings)';


N1 = floor(Nall/3);
N2 = floor(2*Nall/3);


minerrorsW = zeros(length(Ns), no_of_trials);
maxerrorsW = zeros(length(Ns), no_of_trials);
meanerrorsW = zeros(length(Ns), no_of_trials);
minerrorsH = zeros(length(Ns), no_of_trials);
maxerrorsH = zeros(length(Ns), no_of_trials);
meanerrorsH = zeros(length(Ns), no_of_trials);

center1s= zeros(length(Ns), no_of_trials);
center2s= zeros(length(Ns), no_of_trials);
center3s= zeros(length(Ns), no_of_trials);

for iNs = 1:length(Ns)
    N = Ns(iNs);
    Nhalf = round(N/2);
    % par
    for trial_no = 1:no_of_trials
        disp([iNs, trial_no])

        center1 = randi([Nhalf+1, N1-Nhalf-1],1,1);
        center2 = randi([N1+1+Nhalf, N2-Nhalf-1],1,1);
        center3 = randi([N2+1+Nhalf, Nall-Nhalf-1],1,1);
        center1s(iNs,trial_no) = center1;
        center2s(iNs,trial_no) = center2;
        center3s(iNs,trial_no) = center3;

        samples = [center1-Nhalf:center1+Nhalf-1,center2-Nhalf:center2+Nhalf-1,center3-Nhalf:center3+Nhalf-1 ];

        % Define network architecture
        % Create and configure the feedforward neural network
        hiddenLayerSize = 20;  % You can tune this
        net = fitnet(hiddenLayerSize, 'trainlm');  % Levenberg-Marquardt

        % Training options
        net.trainParam.epochs = 100;
        net.trainParam.goal = 1e-9;
        net.trainParam.min_grad = 1e-7;
        net.trainParam.showWindow = true;
        net.performFcn = 'mse';  % Mean squared error

        % Use all data for training (no internal division)
        net.divideParam.trainRatio = 1.0;
        net.divideParam.valRatio = 0.0;
        net.divideParam.testRatio = 0.0;

        % Train the network
        [net, tr] = train(net, XTrainNorm(:,samples)', YTrainNorm');

        % Predict on test data
        YPredNorm = net(XTestNorm(:,samples)');
        YPred = mapminmax.reverse(YPredNorm, outputSettings)';  % Convert back to original scale

        % plot actual vs predicted
        yt1 = 1e2*YTest(:,1);
        yt2 = 1e2*YTest(:,2);
        pred1 = 1e2*YPred(:,1);
        pred2 = 1e2*YPred(:,2);


        errors_percentile1 = 100*abs(yt1-pred1)./yt1;
        disp([min(errors_percentile1) mean(errors_percentile1) max(errors_percentile1)]);
        normal_errorsW = abs(yt1-pred1);
        normal_errorsH = abs(yt2-pred2);


        minerrorsW(iNs, trial_no) = min(normal_errorsW);
        maxerrorsW(iNs, trial_no) = max(normal_errorsW);
        meanerrorsW(iNs, trial_no) = mean(normal_errorsW);
        minerrorsH(iNs, trial_no) = min(normal_errorsH);
        maxerrorsH(iNs, trial_no) = max(normal_errorsH);
        meanerrorsH(iNs, trial_no) = mean(normal_errorsH);

    end
end

figure(1); clf;
plot(3*Ns, min(meanerrorsW.'), 3*Ns, max(meanerrorsW.'), 3*Ns, mean(meanerrorsW.'), 3*Ns, median(meanerrorsW.'))
grid on;
xlabel('Number of Measurements');
ylabel('Width Errors (nm)');
legend('Minimum','Maximum', 'Mean','Median','Location','NorthWest')

figure(2); clf;
plot(3*Ns, min(meanerrorsH.'), 3*Ns, max(meanerrorsH.'), 3*Ns, mean(meanerrorsH.'), 3*Ns, median(meanerrorsH.'))
grid on;
xlabel('Number of Measurements');
ylabel('Height Errors (nm)');
legend('Minimum','Maximum', 'Mean','Median','Location','NorthWest')

save ./files_mat_results/N_vs_w_h_error_SM1_200.mat minerrorsW maxerrorsW meanerrorsW minerrorsH maxerrorsH meanerrorsH Ns