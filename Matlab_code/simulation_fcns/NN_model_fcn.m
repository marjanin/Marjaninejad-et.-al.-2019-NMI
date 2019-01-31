function [net, tr] = NN_model_fcn(Kinematics, Torques, layers)
%NN_model_fcn creates the NN model for the inverse system
%% NN
In=Kinematics';
Out=Torques';
net=feedforwardnet(layers);
net.layers{2}.transferFcn = 'tansig';
%net.trainParam.goal=.02;
%net.layerConnect=[0 0;
%                  1 0];         
%net.outputs{2}.feedbackMode='closed';
%net.inputweights{1,1}.delays=0:2;
%net.layerWeights{1,2}.delays=1:2;
[net, tr] = train(net,In,Out);
view(net)
%%
% Out_P=net(In);
% figure();plot(Out(1,:));hold on; plot(Out_P(1,:))
% figure();plot(Out(2,:));hold on; plot(Out_P(2,:))
%% closing NN training windows
%nntraintool close
%nnet.guis.closeAllViews()
end

