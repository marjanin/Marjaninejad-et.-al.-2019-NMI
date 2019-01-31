##' we needed to note where the cost function would save into the log. 
##' As such, I added a line with three ampersands, to denote the keys before the 
##' cost function val was shown. same was done for power, with three $ symbols before the value.

def extract_reward_from_log_filepath(log_filepath):
    with open(log_filepath) as f:
        lines = f.readlines()
    linevals = [x.strip() for x in lines]
    reward_string = extract_ampersandline_val(linevals)
    return float(reward_string)

def extract_ampersandline_val(linevals):
    is_reward_line = [x.startswith("&&&") for x in linevals]
    reward_line_index = [i for i, x in enumerate(is_reward_line) if x][0]
    val_line = linevals[reward_line_index]
    # 3 matches the length of the 3 &&& that denote the cost value within the logfile:
    val_string = val_line[3:]
    return(val_string)

def extract_power_from_log_filepath(log_filepath):
    with open(log_filepath) as f:
        lines = f.readlines()
    linevals = [x.strip() for x in lines]
    power_string = extract_cashsymbolline_val(linevals)
    return float(power_string)


def extract_cashsymbolline_val(linevals):
    is_power_line = [x.startswith("$$$") for x in linevals]
    power_line_index = [i for i, x in enumerate(is_power_line) if x][0]
    val_line = linevals[power_line_index]
    # 3 matches the length of the 3 &&& that denote the cost value within the logfile:
    val_string = val_line[3:]
    return(val_string)