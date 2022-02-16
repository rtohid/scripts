import glob
import os
import re

input_list = "/work/rtohid/devel/vascular/VascularModelingTest/vascular/directories"
direcrory = "/work/rtohid/devel/vascular/VascularModelingTest/vascular/vascular"
with open(input_list) as f:
    content = f.readlines()
    for name in content:
        name = re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()[:-1]
        os.mkdir(f"{direcrory}/{name}")
