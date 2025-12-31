import os
from pathlib import Path
import shutil

directory = "test"
parent_dir = "/root/"
path = Path(os.path.join(parent_dir,directory))

if not path.is_dir(): #check directory if existist
    os.mkdir(path) #create a directory
else:
    shutil.rmtree(path)
    os.mkdir(path)

for i in range(1,10):
    filename = "File0" + str(i)
    f = open("/root/test/"+filename,mode='w')
    f.write("File0"+str(i))

for i in range(10,21):
    filename = "File" + str(i)
    f = open("/root/test/"+filename,mode='w')
    f.write("File"+str(i))
