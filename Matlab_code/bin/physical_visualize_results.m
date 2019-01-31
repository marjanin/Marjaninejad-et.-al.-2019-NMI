close all;clear all;clc;
addpath('../../output/')
attemp_nums=[15, 15, 17];
for run_num=0:2
    max_iter_num=attemp_nums(run_num+1);
    visu_rewards=zeros(1,max_iter_num);
    for attemp=1:max_iter_num
        load(['matfile_experimentid_reinforce_experiment_aug18A_runno_',num2str(run_num),'_iteration_',num2str(attemp),'_adaptation_F.mat']);
        if reward==-10000
            reward=0;
            best_reward=0;
        end
        visu_kinematics{attemp}=Kinematics;
        visu_rewards(attemp)=reward;
        visu_best_rewards(attemp)=best_reward;
    end
figure()
subplot(2,1,1)
highest_reward_index=find(visu_rewards==max(visu_rewards));
plot(visu_rewards,'r*','linewidth',2); hold on;
plot(visu_best_rewards,'linewidth',2)
line([0 max_iter_num],[60 60],'Color','red','LineStyle','--')
xlim([1, max_iter_num])
xlabel('attempt')
ylabel('reward')
subplot(2,1,2)
    for attemp=1:max_iter_num
        plot(visu_kinematics{attemp}(:,[1,4]),'color',[.4 .6 1 .3]);
        hold on
    end
    plot(visu_kinematics{highest_reward_index}(:,[1,4]),'color',[1 .5 .5 .9],'linewidth',2);
    xlabel('sample')
    ylabel('angles for each joint')
end