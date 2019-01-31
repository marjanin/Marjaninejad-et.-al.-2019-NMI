function [net, tr] = physical_NN_model_re_fcn(Kinematics_train, Act_train, net)
%NN_model_fcn creates the NN model for the inverse system
%% NN
%net.trainParam.goal=.02;
%net.layerConnect=[0 0;
%                  1 0];         
%net.outputs{2}.feedbackMode='closed';
%net.inputweights{1,1}.delays=0:2;
%net.layerWeights{1,2}.delays=1:2;
%net.trainParam.epochs = 1;
%net.trainParam.goal = 5000;
[net, tr] = train(net,Kinematics_train',Act_train');
%view(net)
%%
% Out_P=net(In);
% figure();plot(Out(1,:));hold on; plot(Out_P(1,:))
% figure();plot(Out(2,:));hold on; plot(Out_P(2,:))
%% closing NN training windows
%nntraintool close
nnet.guis.closeAllViews()
end

