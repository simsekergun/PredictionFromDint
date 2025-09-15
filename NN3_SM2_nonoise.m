clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0,'defaultlinelinewidth',3)
set(0,'DefaultAxesFontSize',18)
set(0,'DefaultTextFontSize',18)

load ./files_mn_mat_big/SiNtraining_Dint_SM2.mat
Dint_Dataset = Dints;
XTrain = Dint_Dataset/5e11;
YTrain = dimensions*1e7;
m_values_train = m_values;
lambdas_train = final_lambdas;

load('./files_mn_mat_big/SiNtest_Dint_SM2.mat')
Dint_TestDataset = Dints;

XTest = Dint_TestDataset/5e11;
YTest = dimensions*1e7;
m_values_test = m_values;
lambdas_test = final_lambdas;

% Normalize input and output to [-1, 1] using mapminmax
[XTrainNorm, inputSettings] = mapminmax(XTrain', -1, 1); % Transpose for mapminmax
%XTrainNorm = XTrain;
[YTrainNorm, outputSettings] = mapminmax(YTrain', -1, 1);

XTrainNorm = XTrainNorm'; % Transpose back
YTrainNorm = YTrainNorm';

% Normalize XTest and YTest using training settings
XTestNorm = mapminmax.apply(XTest', inputSettings)';
% XTestNorm = XTest;
YTestNorm = mapminmax.apply(YTest', outputSettings)';

fig = figure(123); 
fig.Position = [100 100 900 800];
subplot(221); plot(m_values_train, XTrain.')
axis tight
xlabel('Mode Number');
ylabel('Normalized D_{int}');
grid on;
title('Training X')
subplot(222); plot(YTrainNorm(:,1), YTrainNorm(:,2),'bo')
grid on;
xlabel('Normalized Width');
ylabel('Normalized Height');
title('Test Y')
subplot(223); plot(m_values_train, XTest.')
axis tight
xlabel('Mode Number');
ylabel('Normalized D_{int}');
grid on;
title('Test X')
subplot(224); plot(YTrainNorm(:,1), YTrainNorm(:,2),'r.',YTestNorm(:,1), YTestNorm(:,2),'bo')
grid on;
xlabel('Normalized Width');
ylabel('Normalized Height');
title('Test Y')
print -dpng ./figures/figure_mn_SM2_InOut

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
[net, tr] = train(net, XTrainNorm', YTrainNorm');

SM2_net = net;
save ./files_mat_networks/SM2_mn_net;

% Predict on test data
YPredNorm = net(XTestNorm');
YPred = mapminmax.reverse(YPredNorm, outputSettings)';  % Convert back to original scale

% Evaluate performance
mseError = mean((YTest(:) - YPred(:)).^2);
fprintf('Test MSE: %.4e\n', mseError);

% plot actual vs predicted
yt1 = 1e2*YTest(:,1); 
yt2 = 1e2*YTest(:,2); 
pred1 = 1e2*YPred(:,1);
pred2 = 1e2*YPred(:,2);


errors_percentile1 = 100*abs(yt1-pred1)./yt1;
disp([min(errors_percentile1) mean(errors_percentile1) max(errors_percentile1)]);
normal_errorsW = abs(yt1-pred1);
normal_errors = abs(yt2-pred2);
errors_percentile2 = 100*abs(yt2-pred2)./yt2;
disp([min(errors_percentile2) mean(errors_percentile2) max(errors_percentile2)]);
disp(['Width Errors (nm): ' [num2str(min(normal_errorsW)) ' ' num2str(mean(normal_errorsW)) ' ' num2str(max(normal_errorsW))]]);disp(['Height Errors (nm): ' [num2str(min(normal_errors)) ' ' num2str(mean(normal_errors)) ' ' num2str(max(normal_errors))]]);


fig = figure(6); clf;
fig.Position = [200 200 1200 900];
subplot(2,2,1);
plot([min(yt1) max(yt1)], [min(yt1) max(yt1)],yt1,pred1, 'ro'); 
title('Ring Width');
xlabel('True Values');
ylabel('Predicted Values');
grid on

subplot(2,2,2);
plot([min(yt2) max(yt2)], [min(yt2) max(yt2)],yt2, pred2, 'ro');
title('Ring Height');
xlabel('True Values');
ylabel('Predicted Values');
grid on

subplot(234)
plot(yt1,yt2,'o',pred1,pred2,'x');
xlabel('Ring Width');
ylabel('Ring Height');
grid on;
legend('Truth','Prediction','Location','West')


subplot(2,3,5); 
hist(normal_errors)
xlabel('Height Pred. Error (nm)')
ylabel('Count');
grid on

subplot(2,3,6); 
hist(normal_errorsW)
xlabel('Width Pred. Error (nm)')
ylabel('Count');
grid on

print -dpng ./figures/figure_mn_NN3_SM2_LM

% Width Regression Accuracy
[MAE, MSE, RMSE, MAPE, R2] = regression_metrics(yt1, pred1);
no_of_errors_larger_than_1nm = length(find(abs(yt1-pred1)>1));
highest_error = max(abs(yt1-pred1));
disp([MAE, highest_error, R2, no_of_errors_larger_than_1nm])

% Height Regression Accuracy
[MAEh, MSEh, RMSEh, MAPEh, R2h] = regression_metrics(yt2, pred2);
no_of_errors_larger_than_1nmh= length(find(abs(yt2-pred2)>1));
highest_errorh = max(abs(yt2-pred2));
disp([MAEh, highest_errorh, R2h, no_of_errors_larger_than_1nmh])

% RESULTS
% Width Errors (nm): 0.007098 0.17225 0.82394
% Height Errors (nm): 0.0082032 0.15655 1.4685
%     0.1723    0.8239    1.0000         0
%     0.1565    1.4685    0.9999    1.0000

save ./files_mat_results/results_mn_NN3_SM2