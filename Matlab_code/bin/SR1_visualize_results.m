clear all;close all;clc;
addpath('../generic_fcns/')
addpath('../simulation_fcns/')
addpath('../results')
N=100;
load(['../results/', num2str(N),'run_results_cf2.mat'])
threshold=2.2;
run_results_filtered=run_results([1:34,35,36:end],:);
vis_reward_vs_rep_fcn(run_results, threshold)
vis_try_and_reward_distributions_fcn(run_results)

tmp=0;
for k=1:N
    tmp=tmp+(run_results{k,2}(end)-run_results{k,2}(1));
end
tmp=tmp/N

%mean attempt number: 16.84
%mean final reward: 0.97214