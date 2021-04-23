from snakemake.io import *
import os, re

SPECIES = []
REFNAME = []
for directory in os.listdir(os.getcwd()):
    if not directory.startswith('.'):
        SPECIES.append(directory)
        for root, dirs, files in os.walk(os.path.join(os.path.abspath(directory), 'ref')):
            for name in files:
                if re.match(r'(.+)\.fa\w*$', name):
                    REFNAME.append(re.match(r'(.+)(?=(\.fa\w*$))', name).group(0))
# print('species:', SPECIES, 'filename:', REFNAME)

filesetlist = list()
for directory in SPECIES:
        shotgun = list()
        for root, dirs, files in os.walk(os.path.join(os.path.abspath(directory), 'shotgun')):
            for name in files:
                if not name.startswith('.'):
                    shotgun.append(os.path.join(os.path.abspath(root), name))
        filesetlist.append(','.join(shotgun))
print(filesetlist)