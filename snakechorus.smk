import os, re

SPECIES = list()
REFNAME = list()
for directory in os.listdir(os.getcwd()):
    if not directory.startswith('.'):
        SPECIES.append(directory)
        for root, dirs, files in os.walk(os.path.join(os.path.abspath(directory), 'ref')):
            for name in files:
                if re.match(r'(.+)\.fa\w*$', name):
                    REFNAME.append(re.match(r'(.+)(?=(\.fa\w*$))', name).group(0))
def shotgunfiles(wildcards):
    filesetlist = list()
    for directory in SPECIES:
            shotgun = list()
            for root, dirs, files in os.walk(os.path.join(os.path.abspath(directory), 'shotgun')):
                for name in files:
                    if not name.startswith('.'):
                        shotgun.append(os.path.join(os.path.abspath(root), name))
            filesetlist.append(','.join(shotgun))
    return filesetlist

rule all:
    input:
        expand('{spe}/probe/{refname}.fa_all.bed', spe=SPECIES, refname=REFNAME),
        expand('{spe}/filtout/{refname}_filterout.bed', spe=SPECIES, refname=REFNAME),
        expand('{spe}/selectout/{refname}_selectout.bed', spe=SPECIES, refname=REFNAME)

rule chorus:
    input:
        region = '{spe}/ref/{refname}.fa',
        genome = '{spe}/ref/{refname}.fa'
    params:
        outdir = '{spe}/probe/'
    output:
        '{spe}/probe/{refname}.fa_all.bed'
    threads: 16
    log: '{spe}/log/{refname}_chorus.log'
    shell:
        "Chorus2"
        " -i {input.region}"
        " -g {input.genome}"
        " -t {threads}"
        " -s {params.outdir}"
        " > {log}"

rule ngsfilter:
    input:
        probe = '{spe}/probe/{refname}.fa_all.bed',
        genome = '{spe}/ref/{refname}.fa'
    output:
        '{spe}/filtout/{refname}_filterout.bed'
    params:
        shotgun = shotgunfiles
    threads: 16
    log: '{spe}/log/{refname}_filter.log'
    shell:
        "ChorusNGSfilter"
        " -i {params.shotgun}"
        " -t {threads}"
        " -z gz"
        " -p {input.probe}"
        " -g {input.genome}"
        " -o {output}"
        " > {log}"

rule ngsselect:
    input:
        '{spe}/filtout/{refname}_filterout.bed'
    output:
        '{spe}/selectout/{refname}_selectout.bed'
    shell:
        "ChorusNGSselect"
        " -i {input}"
        " -o {output}"