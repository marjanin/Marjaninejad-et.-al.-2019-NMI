from mujoco_py import load_model_from_path, MjSim, MjViewer
import numpy as np
from numpy import matlib
from scipy import signal
from sklearn.neural_network import MLPRegressor
from matplotlib import pyplot as plt
#import pickle
import os
from copy import deepcopy
from mujoco_py.generated import const
################################################
#Functions for main tests
#model versions for the nmi_leg_w_chassis:
#	v0: fixed on air
#	v1: touching the floor and can move in x axis
#	v2: touching the floor and can move in x and y axes (cannot rotate, however)

def learn_to_move_fcn(model, cum_kinematics, cum_activations, reward_thresh=6, refinement = False, Mj_render = False):
	
	prev_reward = np.array([0])
	best_reward_so_far = prev_reward
	best_model= model
	all_rewards = []
	exploitation_run_no = 0
	new_features = gen_features_fcn(prev_reward=prev_reward, reward_thresh=reward_thresh, best_reward_so_far=best_reward_so_far, feat_vec_length=10)
	best_features_so_far = new_features
	while exploitation_run_no<=15:
		if best_reward_so_far>reward_thresh:
			exploitation_run_no+=1
		new_features = gen_features_fcn(reward_thresh=reward_thresh, best_reward_so_far=best_reward_so_far, best_features_so_far=best_features_so_far)# .9*np.ones([9,])#
		[prev_reward, attempt_kinematics, est_attempt_activations, real_attempt_kinematics, real_attempt_activations] = \
			feat_to_run_attempt_fcn(features=new_features, model=model,feat_show=False, model_ver=1)
		
		#kinematics_activations_show_fcn(vs_time=True, kinematics=attempt_kinematics,activations=est_attempt_activations)
		#kinematics_activations_show_fcn(vs_time=True, kinematics=real_attempt_kinematics,activations=real_attempt_activations)
		[cum_kinematics, cum_activations] = \
		concatinate_data_fcn(
			cum_kinematics, cum_activations, real_attempt_kinematics, real_attempt_activations, throw_percentage = 0.20)
		all_rewards = np.append(all_rewards, prev_reward)
		if prev_reward>best_reward_so_far:
			best_reward_so_far = prev_reward
			best_features_so_far = new_features
			best_model = deepcopy(model)
		if refinement:
			model = inverse_mapping_fcn(cum_kinematics, cum_activations, prior_model=model)
		print("best reward so far: ", best_reward_so_far)
	input("Learning to walk completed, Press any key to proceed")
	[prev_reward_best, attempt_kinematics_best, est_attempt_activations_best, real_attempt_kinematics_best, real_attempt_activations_best]= \
	feat_to_run_attempt_fcn(features=best_features_so_far, model=best_model, feat_show=True, Mj_render=Mj_render)
	kinematics_activations_show_fcn(vs_time=True, kinematics=real_attempt_kinematics)
	print("all_reward: ", all_rewards)
	print("prev_reward_best: ", prev_reward_best)
	#import pdb; pdb.set_trace()
	return best_reward_so_far, all_rewards

def feat_to_run_attempt_fcn(features, model,feat_show=False,Mj_render=False, model_ver=1):
	[q0_filtered, q1_filtered] = feat_to_positions_fcn(features, show=feat_show)
	step_kinematics = positions_to_kinematics_fcn(q0_filtered, q1_filtered, timestep = 0.005)
	attempt_kinematics = step_to_attempt_kinematics_fcn(step_kinematics=step_kinematics)
	est_attempt_activations = estimate_activations_fcn(model=model, desired_kinematics=attempt_kinematics)
	[real_attempt_kinematics, real_attempt_activations, chassis_pos]=run_activations_fcn(est_attempt_activations, model_ver=model_ver, Mj_render=Mj_render)
	prev_reward = chassis_pos[-1]
	return prev_reward, attempt_kinematics, est_attempt_activations, real_attempt_kinematics, real_attempt_activations

def in_air_adaptation_fcn(model, babbling_kinematics, babbling_activations, number_of_refinements=10, Mj_render=False):
	Mj_render_last_run = False
	model_ver = 0
	cum_kinematics = babbling_kinematics
	cum_activations = babbling_activations
	attempt_kinematics = create_sin_cos_kinematics_fcn(attempt_length=10, number_of_cycles=7)
	#kinematics_activations_show_fcn(vs_time=False, kinematics=attempt_kinematics)
	est_attempt_activations = estimate_activations_fcn(model=model, desired_kinematics=attempt_kinematics)
	if (number_of_refinements == 0) and (Mj_render==True):
		Mj_render_last_run = True
	[real_attempt_kinematics, real_attempt_activations, chassis_pos] = run_activations_fcn(est_attempt_activations, model_ver = model_ver, Mj_render=Mj_render_last_run)
	error0 = np.array([error_cal_fcn(attempt_kinematics[:,0], real_attempt_kinematics[:,0])])
	error1 = np.array([error_cal_fcn(attempt_kinematics[:,3], real_attempt_kinematics[:,3])])
	average_error = (error0+error1)/2
	for ii in range(number_of_refinements):
		if (ii+1 == number_of_refinements) and (Mj_render==True):
			Mj_render_last_run = True
		print("Refinement_no", ii+1)
		[cum_kinematics, cum_activations] = concatinate_data_fcn(cum_kinematics, cum_activations, real_attempt_kinematics, real_attempt_activations)
		model = inverse_mapping_fcn(kinematics=cum_kinematics, activations=cum_activations, prior_model=model)
		est_attempt_activations = estimate_activations_fcn(model=model, desired_kinematics=attempt_kinematics)
		[real_attempt_kinematics, real_attempt_activations, chassis_pos] = run_activations_fcn(est_attempt_activations, model_ver = model_ver, Mj_render=Mj_render_last_run)
		error0 = np.append(error0, error_cal_fcn(attempt_kinematics[:,0], real_attempt_kinematics[:,0]))
		error1 = np.append(error1, error_cal_fcn(attempt_kinematics[:,3], real_attempt_kinematics[:,3]))
		average_error = np.append(average_error, (error0[-1]+error1[-1])/2)
	# plotting error plots
	plt.figure()
	plt.subplot(3, 1, 1)
	plt.plot(range(error0.shape[0]), error0, marker='o',)
	plt.ylabel("q0 error (rads)")
	plt.subplot(3, 1, 2)
	plt.plot(range(error1.shape[0]), error1, marker='o',)
	plt.ylabel("q1 error (rads)")
	plt.subplot(3, 1, 3)
	plt.plot(range(average_error.shape[0]), average_error, marker='o',)
	plt.ylabel("average error (rads)")
	plt.xlabel("Refinement #")
	# plotting desired vs real joint positions after refinements
	plt.figure()
	plt.subplot(2, 1, 1)
	plt.plot(range(attempt_kinematics.shape[0]), real_attempt_kinematics[:,0], range(attempt_kinematics.shape[0]), attempt_kinematics[:,0])
	plt.ylabel("q0 desired vs. simulated")
	plt.subplot(2, 1, 2)
	plt.plot(range(attempt_kinematics.shape[0]), real_attempt_kinematics[:,3], range(attempt_kinematics.shape[0]), attempt_kinematics[:,3])
	plt.ylabel("q1  desired vs. simulated")
	plt.xlabel("Sample #")
	plt.show()
	errors=np.concatenate([[error0], [error1]],axis=0)
	return model, errors, cum_kinematics, cum_activations
################################################
#Higher level control functions
def gen_features_fcn(reward_thresh, best_reward_so_far, **kwargs):
	#import pdb; pdb.set_trace()
	feat_min = 0.4
	feat_max = 0.9
	if ("best_features_so_far" in kwargs):
		best_features_so_far = kwargs["best_features_so_far"]
	elif ("feat_vec_length" in kwargs):
		best_features_so_far = np.random.uniform(feat_min,feat_max,kwargs["feat_vec_length"])
	else:
		raise NameError('Either best_features_so_far or feat_vec_length needs to be provided')
	
	if best_reward_so_far<reward_thresh:
		new_features = np.random.uniform(feat_min, feat_max, best_features_so_far.shape[0])	
	else:
		sigma= np.max([(12-best_reward_so_far)/100, 0.01])# should be inversly proportional to reward
		new_features = np.zeros(best_features_so_far.shape[0],)
		for ii in range(best_features_so_far.shape[0]):
			new_features[ii] = np.random.normal(best_features_so_far[ii],sigma)
		new_features = np.maximum(new_features, feat_min*np.ones(best_features_so_far.shape[0],))
		new_features = np.minimum(new_features, feat_max*np.ones(best_features_so_far.shape[0],))
	return new_features

def feat_to_positions_fcn(features, timestep=0.005, cycle_duration_in_seconds = 1.3, show=False):
	number_of_features = features.shape[0]
	each_feature_length =  int(np.round((cycle_duration_in_seconds/number_of_features)/timestep))
	feat_angles = np.linspace(0, 2*np.pi*(number_of_features/(number_of_features+1)), number_of_features)
	q0_raw = features*np.sin(feat_angles)
	q1_raw = features*np.cos(feat_angles)
	q0_scaled = (q0_raw*np.pi/3)
	q1_scaled = -1*((-1*q1_raw+1)/2)*(np.pi/2) # since the mujoco model goes from 0 to -pi/2
	q0_scaled_extended = np.append(q0_scaled, q0_scaled[0])
	q1_scaled_extended = np.append(q1_scaled, q1_scaled[0])

	q0_scaled_extended_long = np.array([])
	q1_scaled_extended_long = np.array([])
	for ii in range(features.shape[0]):
		q0_scaled_extended_long = np.append(
			q0_scaled_extended_long, np.linspace(
				q0_scaled_extended[ii], q0_scaled_extended[ii+1], each_feature_length))
		q1_scaled_extended_long = np.append(
			q1_scaled_extended_long, np.linspace(
				q1_scaled_extended[ii], q1_scaled_extended[ii+1], each_feature_length))
	q0_scaled_extended_long_3 = np.concatenate(
		[q0_scaled_extended_long[:-1], q0_scaled_extended_long[:-1], q0_scaled_extended_long])
	q1_scaled_extended_long_3 = np.concatenate(
		[q1_scaled_extended_long[:-1], q1_scaled_extended_long[:-1], q1_scaled_extended_long])

	fir_filter_length = int(np.round(each_feature_length/(1)))
	b=np.ones(fir_filter_length,)/fir_filter_length # a simple moving average filter > users can 
	#change these if they need smoother pattern
	a=1
	q0_filtered_3 = signal.filtfilt(b, a, q0_scaled_extended_long_3)
	q1_filtered_3 = signal.filtfilt(b, a, q1_scaled_extended_long_3)

	q0_filtered = q0_filtered_3[q0_scaled_extended_long.shape[0]:2*q0_scaled_extended_long.shape[0]-1] # length = 1999 (the 
	#very last was ommited since it is going to be the first one on the next cycle)
	q1_filtered = q1_filtered_3[q1_scaled_extended_long.shape[0]:2*q1_scaled_extended_long.shape[0]-1]
	if show:
		plt.figure()
		plt.scatter(q0_scaled, q1_scaled)
		plt.plot(q0_filtered, q1_filtered)
		plt.xlabel("q0")
		plt.ylabel("q1")
		plt.show(block=True)
	return q0_filtered, q1_filtered
def step_to_attempt_kinematics_fcn(step_kinematics, number_of_steps_in_an_attempt = 10):
	attempt_kinematics=np.matlib.repmat(step_kinematics,number_of_steps_in_an_attempt,1)
	return(attempt_kinematics)

def concatinate_data_fcn( cum_kinematics, cum_activations, kinematics, activations, throw_percentage = 0.20):
	size_of_incoming_data = kinematics.shape[0]
	samples_to_throw = int(np.round(throw_percentage*size_of_incoming_data))
	cum_kinematics = np.concatenate([cum_kinematics, kinematics[samples_to_throw:,:]])
	cum_activations = np.concatenate([cum_activations, activations[samples_to_throw:,:]])
	return cum_kinematics, cum_activations

################################################
#Lower level control functions
def babbling_fcn(simulation_minutes=5):
	"""
	this function babbles in the mujoco environment and then
	returns input outputs (actuation values and kinematics)
	"""
	np.random.seed(0) # to get consistent results for debugging purposes

	model = load_model_from_path("./models/nmi_leg_w_chassis_v0.xml")
	sim = MjSim(model)

	# viewer = MjViewer(sim)
	sim_state = sim.get_state()

	control_vector_length=sim.data.ctrl.__len__()
	# print("control_vector_length: "+str(control_vector_length))
	simulation_time=simulation_minutes*60.0
	timestep=0.005
	# babble_phase_time=3

	run_samples=int(np.round(simulation_time/timestep))
	# babble_phase_samples=int(np.round(babble_phase_time/timestep))
	# babbling_positions=np.zeros((run_samples,2))
	# babbling_activations=np.zeros((run_samples,3))

	#while True:
	sim.set_state(sim_state)
	max_in = 1
	min_in = 0
	pass_chance = timestep
	motor1_act = \
	systemID_input_gen_fcn(
		signal_duration_in_seconds=simulation_time, pass_chance=pass_chance, max_in=max_in, min_in=min_in, timestep=timestep)
	motor2_act = \
	systemID_input_gen_fcn(
		signal_duration_in_seconds=simulation_time, pass_chance=pass_chance, max_in=max_in, min_in=min_in, timestep=timestep)
	motor3_act = \
	systemID_input_gen_fcn(
		signal_duration_in_seconds=simulation_time, pass_chance=pass_chance, max_in=max_in, min_in=min_in, timestep=timestep)
	babbling_activations = np.transpose(
		np.concatenate(
			[[motor1_act],[motor2_act],[motor3_act]],
			axis=0)
		)
	kinematics_activations_show_fcn(activations=babbling_activations)
	[babbling_kinematics, babbling_activations, chassis_pos] = \
	run_activations_fcn(
		babbling_activations, model_ver=0, timestep=0.005, Mj_render=False
		)

	# for ii in range(run_samples):
	#     # # current_kinematics_array=np.array(
	#     # # 	[sim.data.qpos[0],
	#     # # 	sim.data.qvel[0],
	#     # # 	0, sim.data.qpos[1],
	#     # # 	sim.data.qvel[1],
	#     # # 	0])
	#     # if (ii%babble_phase_samples)==0:
	#     #     sim.data.ctrl[:] = np.random.uniform(0,1,control_vector_length)
	#     sim.data.ctrl[:] = babbling_activations[ii,:]
	#     sim.step()
	#     babbling_positions[ii,:]=sim.data.qpos
	#     babbling_activations[ii,:]=sim.data.ctrl
	#     # viewer.render()
 #    # adding acceleration
	# babbling_kinematics = positions_to_kinematics_fcn(
	# 	babbling_positions[:,0], babbling_positions[:,1], timestep)
	# # babbling_kinematics = np.transpose(
	# # 	np.concatenate(
	# # 		(
	# # 			[babbling_kinematics[:,0]],
	# # 			[np.gradient(babbling_kinematics[:,0])/timestep],
	# # 			[np.gradient(np.gradient(babbling_kinematics[:,0]))/timestep/timestep],
	# # 			[babbling_kinematics[:,3]],
	# # 			[np.gradient(babbling_kinematics[:,3])/timestep],
	# # 			[np.gradient(np.gradient(babbling_kinematics[:,3]))/timestep/timestep]),
	# # 		axis=0)
	# # 	)
	print("min and max joint 0, min and max joint 1:")
	print(
		np.min(babbling_kinematics[:,0]),
		np.max(babbling_kinematics[:,0]),
		np.min(babbling_kinematics[:,3]),
		np.max(babbling_kinematics[:,3]))
	return babbling_kinematics[1000:,:], babbling_activations[1000:,:]
	#np.save("babbling_kinematics",babbling_kinematics)
	#np.save("babbling_activations",babbling_activations)

def systemID_input_gen_fcn(signal_duration_in_seconds, pass_chance, max_in, min_in, timestep):
	number_of_samples = int(np.round(signal_duration_in_seconds/timestep))
	samples = np.linspace(
		0, signal_duration_in_seconds, number_of_samples)
	gen_input = np.zeros(number_of_samples,)*min_in

	for ii in range(1, number_of_samples):
		pass_rand = np.random.uniform(0,1,1)
		if pass_rand < pass_chance:
			gen_input[ii] = ((max_in-min_in)*np.random.uniform(0,1,1)) + min_in
		else:
			gen_input[ii] = gen_input[ii-1]
	return gen_input

def inverse_mapping_fcn(kinematics, activations, early_stopping=False, **kwargs):
	"""
	this function used the babbling data to create an inverse mapping using a
	MLP NN
	"""
	number_of_samples=activations.shape[0]
	train_ratio=1 # from 0 to 1, 0 being all test and 1 being all train
	kinematics_train=kinematics[:int(np.round(train_ratio*number_of_samples)),:]
	kinematics_test=kinematics[int(np.round(train_ratio*number_of_samples))+1:,:]
	activations_train=activations[:int(np.round(train_ratio*number_of_samples)),:]
	activations_test=activations[int(np.round(train_ratio*number_of_samples))+1:,:]
	number_of_samples_test=activations_test.shape[0]

	#training the model
	print("training the model")
	if ("prior_model" in kwargs):
		model=kwargs["prior_model"]
	else:
		model = MLPRegressor(
			hidden_layer_sizes=15,
			activation="logistic",
			verbose=True,
			warm_start=True,
			early_stopping=early_stopping)

	model.fit(kinematics_train, activations_train)
	#pickle.dump(model,open("mlp_model.sav", 'wb'))

	# running the model
	#model=pickle.load(open("mlp_model.sav", 'rb')) # loading the model
	est_activations=model.predict(kinematics)

	# plotting the results
	# plt.figure()
	# plt.subplot(3, 1, 1)
	# plt.plot(range(activations.shape[0]), activations[:,0], range(activations.shape[0]), est_activations[:,0])

	# plt.subplot(3, 1, 2)
	# plt.plot(range(activations.shape[0]), activations[:,1], range(activations.shape[0]), est_activations[:,1])

	# plt.subplot(3, 1, 3)
	# plt.plot(range(activations.shape[0]), activations[:,2], range(activations.shape[0]), est_activations[:,2])
	# plt.show(block=False)
	return model
	#import pdb; pdb.set_trace()

def positions_to_kinematics_fcn(q0, q1, timestep = 0.005):
	kinematics=np.transpose(
	np.concatenate(
		(
			[[q0],
			[np.gradient(q0)/timestep],
			[np.gradient(np.gradient(q0)/timestep)/timestep],
			[q1],
			[np.gradient(q1)/timestep],
			[np.gradient(np.gradient(q1)/timestep)/timestep]]),
		axis=0
		)
	)
	return kinematics

def kinematics_activations_show_fcn(vs_time=False, timestep=0.005, **kwargs):
	#plotting the resulting kinematics or activations
	sample_no_kinematics=0
	sample_no_activations=0
	if ("kinematics" in kwargs):
		kinematics = kwargs["kinematics"]
		sample_no_kinematics = kinematics.shape[0]
	if ("activations" in kwargs):
		activations = kwargs["activations"]
		sample_no_activations = activations.shape[0]
	if not (("kinematics" in kwargs) or ("activations" in kwargs)):
		raise NameError('Either kinematics or activations needs to be provided')
	if (sample_no_kinematics!=0) & (sample_no_activations!=0) & (sample_no_kinematics!=sample_no_activations):
		raise ValueError('Number of samples for both kinematics and activation matrices should be equal and not zero')
	else:
		number_of_samples = np.max([sample_no_kinematics, sample_no_activations])
		if vs_time:
			x = np.linspace(0,timestep*number_of_samples,number_of_samples)
		else:
			x = range(number_of_samples)
	if ("kinematics" in kwargs):
		plt.figure()
		plt.subplot(6, 1, 1)
		plt.plot(x, kinematics[:,0])
		plt.ylabel('q0 (rads)')
		plt.subplot(6, 1, 2)
		plt.plot(x, kinematics[:,1])
		plt.ylabel('q0 dot (rads/s)')
		plt.subplot(6, 1, 3)
		plt.plot(x, kinematics[:,2])
		plt.ylabel('q0 double dot (rads/s^2)')
		plt.subplot(6, 1, 4)
		plt.plot(x, kinematics[:,3])
		plt.ylabel('q1 (rads)')
		plt.subplot(6, 1, 5)
		plt.plot(x, kinematics[:,4])
		plt.ylabel('q1 dot (rads/s)')
		plt.subplot(6, 1, 6)
		plt.plot(x, kinematics[:,5])
		plt.ylabel('q1 double dot (rads/s^2)')
		plt.xlabel('motor 1 activation values')
	if ("activations" in kwargs):
		plt.figure()
		plt.subplot(3, 1, 1)
		plt.plot(x, activations[:,0])
		plt.ylabel('motor 1 activation values')
		plt.subplot(3, 1, 2)
		plt.plot(x, activations[:,1])
		plt.ylabel('motor 1 activation values')
		plt.subplot(3, 1, 3)
		plt.plot(x, activations[:,2])
		plt.ylabel('motor 1 activation values')
		plt.xlabel('Sample #')
	plt.show(block=True)
def create_sin_cos_kinematics_fcn(attempt_length = 10 , number_of_cycles = 7, timestep = 0.005):
	"""
	this function creates desired task kinematics and their corresponding 
	actuation values predicted using the inverse mapping
	"""
	#attempt_length=5 # in seconds
	number_of_attempt_samples=int(np.round(attempt_length/timestep))

	q0=np.zeros(number_of_attempt_samples)
	q1=np.zeros(number_of_attempt_samples)

	for ii in range(number_of_attempt_samples):
		q0[ii]=(np.pi/3)*np.sin(number_of_cycles*(2*np.pi*ii/number_of_attempt_samples))
		q1[ii]=-1*(np.pi/2)*((-1*np.cos(number_of_cycles*(2*np.pi*ii/number_of_attempt_samples))+1)/2)
	#import pdb; pdb.set_trace()
	attempt_kinematics=positions_to_kinematics_fcn(q0, q1, timestep)
	#np.save("attempt_kinematics",attempt_kinematics)
	#np.save("est_task_activations",est_attempt_activations)
	#import pdb; pdb.set_trace()
	return attempt_kinematics

def estimate_activations_fcn(model, desired_kinematics):
# running the model
	print("running the model")
	#model=pickle.load(open("mlp_model.sav", 'rb')) # loading the model
	est_activations=model.predict(desired_kinematics)
	# plotting the results
	# plt.figure()
	# plt.subplot(3, 1, 1)
	# plt.plot(range(desired_kinematics.shape[0]), est_activations[:,0])

	# plt.subplot(3, 1, 2)
	# plt.plot(range(desired_kinematics.shape[0]), est_activations[:,1])

	# plt.subplot(3, 1, 3)
	# plt.plot(range(desired_kinematics.shape[0]), est_activations[:,2])
	# plt.show(block=False)
	return est_activations

def run_activations_fcn(est_activations, model_ver=0, timestep=0.005, Mj_render=False):
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! the q0 is now the chasis pos. needs to be fixed
	"""
	this function runs the predicted activations generatred from running
	the inverse map on the desired task kinematics
	"""

	#loading data
	#print("loading data")
	#task_kinematics=np.load("task_kinematics.npy")
	#est_task_activations=np.load("est_task_activations.npy")

	model = load_model_from_path("./models/nmi_leg_w_chassis_v{}.xml".format(model_ver))
	sim = MjSim(model)
	if Mj_render:
		viewer = MjViewer(sim)
		# viewer.cam.fixedcamid += 1
		# viewer.cam.type = const.CAMERA_FIXED
	sim_state = sim.get_state()
	control_vector_length=sim.data.ctrl.__len__()
	print("control_vector_length: "+str(control_vector_length))

	number_of_task_samples=est_activations.shape[0]

	real_attempt_positions = np.zeros((number_of_task_samples,2))
	real_attempt_activations = np.zeros((number_of_task_samples,3))
	chassis_pos=np.zeros(number_of_task_samples,)
	sim.set_state(sim_state)
	for ii in range(number_of_task_samples):
	    sim.data.ctrl[:] = est_activations[ii,:]
	    sim.step()
	    current_positions_array = sim.data.qpos[-2:]

	    # current_kinematics_array=np.array(
	    # 	[sim.data.qpos[0],
	    # 	sim.data.qvel[0],
	    # 	sim.data.qacc[0],
	    # 	sim.data.qpos[1],
	    # 	sim.data.qvel[1],
	    # 	sim.data.qacc[1]]
	    # 	)
	    chassis_pos[ii]=sim.data.get_geom_xpos("Chassis_frame")[0]
	    real_attempt_positions[ii,:] = current_positions_array
	    real_attempt_activations[ii,:] = sim.data.ctrl
	    if Mj_render:
	    	viewer.render()
	real_attempt_kinematics = positions_to_kinematics_fcn(
		real_attempt_positions[:,0], real_attempt_positions[:,1], timestep = 0.005)
	return real_attempt_kinematics, real_attempt_activations, chassis_pos

def error_cal_fcn(input1, input2):
	error = np.mean(np.abs(input1-input2))
	return error

#import pdb; pdb.set_trace()
	