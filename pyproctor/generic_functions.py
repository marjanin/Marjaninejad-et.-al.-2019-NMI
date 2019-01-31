import os


def abspath_join(a,b):
    return(os.path.abspath(os.path.join(a,b)))

def hline():
    print("=======================\n")

def hlinewrap(msg, and_close=True):
	hline()
	print(msg)
	if and_close:
		hline()