#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import fnmatch
import re
import sys

def find_files(directory, pattern):
    for root, dirs, files in os.walk(directory):
        for basename in files:
            if fnmatch.fnmatch(basename, pattern):
                filename = os.path.join(root, basename)
                yield filename

def check_encoding(data):
    lines = 0
    for line in data:
        if re.match("# -\\*- coding:\\s.*\\s-\\*-", line):
            return True
        lines += 1
        if lines > 1:
            break
    return False

if __name__ == '__main__':
    encoding = 'utf-8'
    counts = { 'ok': 0, 'missing': 0 }
    for filename in find_files(os.getcwd(), '*.py'):
        sys.stdout.write('{0}...'.format(filename))
        with open(filename, 'r') as f:
            data = f.readlines()
        if not check_encoding(data):
            counts['missing'] += 1
            sys.stdout.write('MISSING\n')
            with open(filename, 'w') as f:
                if len(data):
                    if re.match("#\\!( ?)/usr/bin/env\\spython", data[0]):
                        f.write(data[0])
                        del data[0]
                f.write('# -*- coding: {0} -*-\n'.format(encoding))
                if not len(data[0].strip()) == 0:
                    f.write('\n')
                f.writelines(data)
        else:
            counts['ok'] += 1
            sys.stdout.write('ok\n')

    sys.stdout.write('\nFound: {0}\nMissing: {1}\n'.format(counts['ok'], counts['missing']))