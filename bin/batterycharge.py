#!/usr/bin/env python
# coding=UTF-8

import math
import subprocess
import sys

# TODO: Add a command line option for color output

total_slots = 8

p = subprocess.Popen(["ioreg", "-rc", "AppleSmartBattery"], stdout=subprocess.PIPE)
output = p.communicate()[0]

o_max = [l for l in output.splitlines() if 'MaxCapacity' in l][0]
o_cur = [l for l in output.splitlines() if 'CurrentCapacity' in l][0]

b_max = float(o_max.rpartition('=')[-1].strip())
b_cur = float(o_cur.rpartition('=')[-1].strip())

charge = b_cur / b_max
charge_threshold = int(math.ceil(float(total_slots) * charge))

# Output

slots = []
filled = int(math.ceil(charge_threshold * (float(total_slots) / 8.0))) * u'•'
empty = (total_slots - len(filled)) * u'▹'

out = (filled + empty).encode('utf-8')

color_green = '%{[32m%}'
color_yellow = '%{[1;33m%}'
color_red = '%{[31m%}'
color_reset = '%{[00m%}'
color_out = (
    color_green if len(filled) > 6
    else color_yellow if len(filled) > 4
    else color_red
)

#out = color_out + out + color_reset
sys.stdout.write(out)
