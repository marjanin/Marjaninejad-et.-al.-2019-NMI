
# next is to add accel and see the difference
# add stiffness too
import numpy as np
from matplotlib import pyplot as plt
from all_functions import *
import pickle
from warnings import simplefilter

simplefilter(action='ignore', category=FutureWarning)

run_mode=input("Please enter the run mode (1 for in air adaptation or 2 for learn to move): ")
if run_mode=="1":
	babbling_simulation_minutes = 1
elif run_mode=="2":
	babbling_simulation_minutes = 5
else:
	raise ValueError('Invalid run mode')

[babbling_kinematics, babbling_activations] = babbling_fcn(simulation_minutes=babbling_simulation_minutes)
model = inverse_mapping_fcn(kinematics=babbling_kinematics, activations=babbling_activations, early_stopping=False)
cum_kinematics = babbling_kinematics
cum_activations = babbling_activations

pickle.dump([model,cum_kinematics, cum_activations],open("results/mlp_model.sav", 'wb')) # saving the model
#[model,cum_kinematics, cum_activations] = pickle.load(open("results/mlp_model.sav", 'rb')) # loading the model

np.random.seed(2) # change the seed for different initial conditions

if run_mode=="1":
	[model, errors, cum_kinematics, cum_activations] =\
	in_air_adaptation_fcn(
		model=model,
		babbling_kinematics=cum_kinematics,
		babbling_activations=cum_activations,
		number_of_refinements=10,
		Mj_render=True)
elif run_mode=="2":
	[best_reward, all_rewards] =\
	learn_to_move_fcn(
		model=model,
		cum_kinematics=cum_kinematics,
		cum_activations=cum_activations,
		reward_thresh=6,
		refinement=False,
		Mj_render=True)
else:
	raise ValueError('Invalid run mode')
#import pdb; pdb.set_trace()