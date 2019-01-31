clear all;close all;clc;
rng(0)
addpath('../generic_fcns/')
file_name='Aug25_generated_babble';
T=300;
fs=78;
pass_chance=1/fs;
max_in=1000;
min_in=150;
mode='d';

[t_in,in1] = systemID_input_gen_fcn(T,fs,pass_chance,max_in,min_in,mode);
[t_in,in2] = systemID_input_gen_fcn(T,fs,pass_chance,max_in,min_in,mode);
[t_in,in3] = systemID_input_gen_fcn(T,fs,pass_chance,max_in,min_in,mode);

plot(t_in,[in1;in2;in3],'linewidth',2)

babbling_activations=[in1;in2;in3]';
csvwrite(['../../testdata/',file_name,'.csv'],babbling_activations)