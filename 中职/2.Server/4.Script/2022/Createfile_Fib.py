import os
from pathlib import Path
import shutil

f1 = 1
f2 = 2
s = 0

directory = "test"
parent_dir = "/root/"
path = Path(os.path.join(parent_dir,directory))

if not path.is_dir(): #check directory if existist
    os.mkdir(path) #create a directory
else:
    shutil.rmtree(path)
    os.mkdir(path)


filename = "File00" + str(f1)
f = open("/root/test/"+filename,mode='w')
f.write("File00"+str(f1))


filename = "File00" + str(f2)
f = open("/root/test/"+filename,mode='w')
f.write("File00"+str(f2))


for i in range(51):
    s = f1 + f2
    f1 = f2
    f2 = s


    if f2 < 10:
        filename = "File00" + str(f2)
        f = open("/root/test/"+filename,mode='w')
        f.write("File00"+str(f2))

    if f2 > 10 and f2 < 100:
        filename = "File0" + str(f2)
        f = open("/root/test/"+filename,mode='w')
        f.write("File0"+str(f2))

    if f2 > 100 and f2 < 1000:
        filename = "File" + str(f2)
        f = open("/root/test/"+filename,mode='w')
        f.write("File"+str(f2))

    if f2 > 1000:
        num_f2 = str(f2)
        f2 = int(num_f2[:3])
        filename = "File" + str(f2)
        f = open("/root/test/"+filename,mode='w')
        f.write("File"+str(f2))