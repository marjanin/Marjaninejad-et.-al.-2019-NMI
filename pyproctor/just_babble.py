# to run this file, run python3 -i interactive.py

from proctor import *
from log_extractor import *


def babble_target_paths(babble_id):
    local_output_folderpath = "../output/"
    input_filepath = "../testdata/%s.csv" % babble_id  # about 5min
    return(input_filepath, local_output_folderpath)


def main(babble_id, remote_user_host, verbose=False):
    input_filepath, local_output_folderpath = babble_target_paths(babble_id)
    if verbose:
        hlinewrap('Starting activations on Rpi for %s' % babble_id)
    response_path, log_path = prescribe_activations_and_scp_results(
        babble_id, remote_user_host, input_filepath, local_output_folderpath)

    # print out the results:
    announce_response(response_path, log_path)


if __name__ == '__main__':
    user, ip, remote_user_host = initialize_pi()
    try:
        babble_id = "aug25_generated_babble_78hz_via_aug31_eve"
        main(babble_id, remote_user_host, verbose=False)
    except:
        print('Exception raised, exiting out.')
        pass
    finally:
        interrupt_current_processes(remote_user_host)
