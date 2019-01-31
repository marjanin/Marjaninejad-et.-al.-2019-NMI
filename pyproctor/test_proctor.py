# to run: `python3 -m pytest`
from proctor import *
import sys


class TestClass(object):
    def test_proctor_file_functions(self):

        file_exists_on_pi('/home/pi/.ssh/id_rsa.pub')
        scp_file_from_pi('/home/pi/.ssh/id_rsa.pub', 'Downloads/pubtest.md')
        scp_file_to_pi('Downloads/pubtest.md','/home/pi/Downloads/pubtest.md')
        file_exists_on_pi('/home/pi/Downloads/pubtest.md')


