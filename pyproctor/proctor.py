import os
import subprocess
# run locally to get the path to the user's home directory.
# ex. get_user_home_cmd() --> /home/briancohn.
global_host = "pi@10.120.80.222"
import random
import string
import time
from generic_functions import *
from matlab_connector import *
import numpy as np
from log_extractor import *

########################################################################
# Global parameters:


def initialize_pi():
    user = "pi"
    ip = "10.120.80.222"
    ensure_rpi_online(ip)
    remote_user_host = "%s@%s" % (user, ip)
    return(user, ip, remote_user_host)


def initialize_babble_params(babble_id):
    babble_response = "/Users/briancohn/Documents/GitHub/marjanin/Tendon_Driven_Robotics/output/%s_response.csv" % babble_id
    babble_mat_path = "/Users/briancohn/Documents/GitHub/marjanin/Tendon_Driven_Robotics/output/%s_response_environment.mat" % babble_id

    # These don't tend to change
    local_output_folderpath = "/Users/briancohn/Documents/GitHub/marjanin/Tendon_Driven_Robotics/output/reinforcements/"
    input_babble = "Users/briancohn/Documents/GitHub/marjanin/Tendon_Driven_Robotics/testdata/%s.csv" % babble_id
    return(babble_response,
           babble_mat_path,
           local_output_folderpath,
           input_babble)
########################################################################


def prep_filepaths_for_bypython(experiment_id, attempt_number, adapt, target_folderpath):
    prior_physics_filepath = abspath_join(
        target_folderpath, compose_prefix(experiment_id, attempt_number - 1, adapt)) + ".csv"
    prefix = compose_prefix(
        experiment_id, attempt_number, adapt)
    new_desired_kinematics_filepath = abspath_join(
        target_folderpath, "new_desired_kinematics%s.csv" % prefix)
    mat_output_filepath = abspath_join(target_folderpath,
                                       "matfile%s.mat" % prefix)
    new_activations_filepath = abspath_join(target_folderpath,
                                            "new_trajectory%s.csv" % prefix)
    optional_response_prefix = compose_prefix_wo_experiment(
        attempt_number, adapt)
    return optional_response_prefix, mat_output_filepath, new_activations_filepath, prior_physics_filepath, new_desired_kinematics_filepath


def save_summary(bigexperiment_id, reward_path_per_experiment, local_output_folderpath, announce=False):
    summary_filepath = abspath_join(
        local_output_folderpath, "%s_summary_rewards_per_experiment.csv" % bigexperiment_id)
    if announce:
        hlinewrap("Rewards:")
        hlinewrap(reward_path_per_experiment)
    np.save(summary_filepath, np.asarray(reward_path_per_experiment))


def ensure_mkdir(path):
    if not os.path.exists(path):
        os.makedirs(path)


def compose_prefix(experiment_id, attempt_number, adapt_bool):
    return("_experimentid_%s_attempt_%s_adaptation_%s" % (experiment_id, attempt_number, adapt_string(adapt_bool)))

# So it is not duplicated in the scp filepath formation step


def compose_prefix_wo_experiment(attempt_number, adapt_bool):
    return("_attempt_%s_adaptation_%s" % (attempt_number, adapt_string(adapt_bool)))


def adapt_string(bool_adapt):
    if bool_adapt:
        return "T"
    else:
        return "F"
# ' Prepares the filenames for the outputs that the matlab script will create


def get_validation_action_filepath(number):
    return "../testdata/validation_list/%s.csv" % number


def cmd_optional_quiet(cmd, quiet=True):
    stderr_target = subprocess_stderr_based_on_quiet(quiet)
    result = subprocess.check_output(cmd, shell=True, stderr=stderr_target)
    return(result)


def start_matlab_in_working_dir_with_added_paths(dirname):
    eng = matlab.engine.start_matlab()
    eng.cd(r'%s' % dirname, nargout=0)
    eng.eval("addpath('../physical_system_fcns/')", nargout=0)
    eng.eval("addpath('../generic_fcns/')", nargout=0)
    return(eng)


def collect_response_commands(cmd_list):
    results = [subprocess.call(cmd, shell=True) for cmd in cmd_list]


def ensure_rpi_online(ip):
    if ping_successful(ip):
        pass
    else:
        raise("Rpi not online. Ensure you are connected to Guest Wireless, and that the Pi is powered.")


def interrupt_current_processes(remote_user_host):
    processnames = ["python3", "python", "pigpiod"]
    [subprocess.call("ssh -o LogLevel=QUIET %s '%s'" %
                     (remote_user_host, "sudo killall python3"), shell=True) for x in processnames]
    print('Killed all python3 and pigpiod processes.')


def announce_response(result_csv_local_filepath, result_log_local_filepath):
    hlinewrap('Completed activations and SCP', and_close=False)
    hlinewrap('Output CSV saved locally to: %s' %
              result_csv_local_filepath, and_close=False)
    hlinewrap('Output LOG saved locally to: %s' % result_log_local_filepath)


def announce_id(experiment_id, optional_response_prefix):
    hlinewrap('Completed %s%s' %
              (experiment_id, optional_response_prefix), and_close=True)


def extract_reward(result_log_local_filepath, verbose=False):
    reward = extract_reward_from_log_filepath(result_log_local_filepath)
    if verbose:
        print("Reward recorded: %s°" % reward)
    return(reward)


def prescribe_activations(experiment_id, remote_user_host, local_activations_filepath, local_activations_filename, optional_response_prefix="", publish_zmq=False, verbose=False):
    pi_activation_prescription_target = get_activation_prescription_target_filepath(
        local_activations_filename)
    scp_file_to_pi(local_activations_filepath,
                   pi_activation_prescription_target)
    successful_tx = file_exists_on_pi(
        pi_activation_prescription_target, quiet=verbose)
    if not successful_tx:
        raise("Unsuccessful attempt to send prescribed activations csv to rpi. Not existent at %s" %
              pi_activation_prescription_target)

    start_timestamp = str(time.time())
    observations_path = "/home/pi/Documents/GitHub/bc/pi-zmq/observations/"
    output_filepath = "%s%s%s_response.csv" % (
        observations_path, experiment_id, optional_response_prefix)
    log_filepath = "%s%s%s_log.txt" % (
        observations_path, experiment_id, optional_response_prefix)
    if publish_zmq:
        hlinewrap(
            "WARNING: ZMQ ENABLED. Sampling rate is reduced significantly by this option. Set publish_zmq=False to disable.")
    response_cmd = "ssh %s 'sudo nice --12 sudo python3 /home/pi/Documents/GitHub/bc/pi-zmq/collect_response.py %s %s %s %s'" % (
        remote_user_host, pi_activation_prescription_target, output_filepath, publish_zmq, log_filepath)
    # if verbose:
    print('Running "%s"' % response_cmd)
    try:
        result = os.system(response_cmd)
    except KeyboardInterrupt:
        interrupt_current_processes(remote_user_host)
    datalogging_success = file_exists_on_pi(output_filepath, quiet=False)
    if datalogging_success:
        return(output_filepath, log_filepath)
    else:
        raise("Data output file nonexistent on pi. Data logging was not successul.")

# https://stackoverflow.com/questions/100210/what-is-the-standard-way-to-add-n-seconds-to-datetime-time-in-python


def predict_csv_time(local_activations_filepath):
    minutes = (sum(1 for line in open(local_activations_filepath)) / 78) / 60
    print("Minutes expected: %s" % minutes)

# if optional response prefix is used, make it start with an underscore


def prescribe_activations_and_scp_results(experiment_id, remote_user_host, local_activations_filepath, local_output_folderpath, optional_response_prefix="", publish_zmq=False):
    predict_csv_time(local_activations_filepath)
    res_filepath, res_log_filepath = prescribe_activations(
        experiment_id, remote_user_host, local_activations_filepath, os.path.basename(local_activations_filepath), optional_response_prefix, publish_zmq)
    result_csv_local_filepath, result_log_local_filepath = pull_response_and_log(
        remote_user_host, res_filepath, res_log_filepath, local_output_folderpath)
    return(result_csv_local_filepath, result_log_local_filepath)


def ssh_collect_response_cmd(remote_user_host, pi_activation_prescription_target):
    collect_response_cmd = "ssh -o LogLevel=QUIET %s './collect_response %s'" % (
        remote_user_host, pi_activation_prescription_target)
    return(collect_response_cmd)


def get_activation_prescription_target_filepath(filename):
    return("/home/pi/Documents/GitHub/bc/pi-zmq/activation_prescriptions_queue/%s" % filename)


def get_user_home_cmd():
    return('eval echo "/Users/$USER"')


def get_user_home_path(quiet=True):
    stderr_target = subprocess_stderr_based_on_quiet(quiet)
    result = subprocess.check_output(
        get_user_home_cmd(), shell=True, stderr=stderr_target)
    string_path = result.decode("utf-8")[:-1] + "/"
    return(string_path)

# send a file from local to the pi
# ex: scp_file_to_pi('/Users/briancohn/Downloads/test.md','/home/pi/Downloads/test.md')


def scp_file_to_pi(local_filepath, pi_filepath, remote_user_host=global_host, verbose=False):
    nullifier = "> /dev/null"  # to silence
    cmd = 'scp -q -o LogLevel=QUIET "%s" "%s:%s" %s' % (
        local_filepath, remote_user_host, pi_filepath, nullifier)
    if verbose:
        print(cmd)
    os.system(cmd)


def ping_successful(ip):
    # 0 means no issue connecting
    response = os.system(
        "ping -q -w1 -c1 %s &>/dev/null && echo 0 || echo 1" % ip)
    if response == 0:
        return(True)
    else:
        return(False)


# download a file from pi to local
# ex: scp_file_from_pi('/home/pi/Downloads/test.md', '/Users/briancohn/Downloads/test1.md')
def scp_file_from_pi(pi_filepath, local_filepath, remote_user_host=global_host):
    nullifier = "> /dev/null"  # to silence
    os.system('scp -q -o LogLevel=QUIET "%s:%s" "%s" %s' %
              (remote_user_host, pi_filepath, local_filepath, nullifier))

# composes command for file_exists_on_pi
# ex. scp_file_from_pi('/home/pi/.ssh/id_rsa.pub')


def ssh_check_file_cmd(pi_filepath, remote_user_host):
    return("ssh -o LogLevel=QUIET %s 'test -e %s && echo True || echo False'" % (remote_user_host, pi_filepath))


def gen_alphanumeric(n=16):
    return(''.join(random.choice(string.ascii_uppercase +
                                 string.ascii_lowercase + string.digits) for _ in range(n)))


def subprocess_stderr_based_on_quiet(quiet):
    if quiet:
        stderr_target = subprocess.DEVNULL
    else:
        stderr_target = None
    return(stderr_target)

# return True if the filepath exists on the pi. uses ssh command.
# ex. file_exists_on_pi('/home/pi/.ssh/id_rsa.pub')
# if not quiet, will print warnings/etc


def file_exists_on_pi(pi_filepath, remote_user_host=global_host, quiet=True):
    cmd = ssh_check_file_cmd(pi_filepath, remote_user_host)
    stderr_target = subprocess_stderr_based_on_quiet(quiet)

    result = subprocess.check_output(cmd, shell=True, stderr=stderr_target)
    return("True" in str(result))


def pull_response_and_log(remote_user_host, res_filepath, res_log_filepath, local_output_folderpath):

    local_response_filepath = abspath_join(
        local_output_folderpath, os.path.basename(res_filepath))
    local_logfile_filepath = abspath_join(
        local_output_folderpath, os.path.basename(res_log_filepath))
    if not ping_successful(remote_user_host.split("@", 1)[1]):
        print('Pi inaccessible over connection. Ensure connection to Guest Wireless')
        return(False)
    # pull the log first, so if it failed at least we get the log
    scp_file_from_pi(res_log_filepath, local_logfile_filepath,
                     remote_user_host=remote_user_host)
    scp_file_from_pi(res_filepath, local_response_filepath,
                     remote_user_host=remote_user_host)

    if not os.path.isfile(local_response_filepath):
        raise("Unsuccessful download of response file %s from Rpi. try SFTP'ing into the server or scp manually." %
              local_response_filepath)

    if not os.path.isfile(local_logfile_filepath):
        raise("Unsuccessful download of log file file %s from Rpi. try SFTP'ing into the server or scp manually." %
              local_logfile_filepath)

    return(local_response_filepath, local_logfile_filepath)
