import glob
import os

[os.rename(f, f+'pp') for f in glob.glob("/work/rtohid/devel/vascular/VascularModelingTest/vascular/*/*.h", recursive=True)]
