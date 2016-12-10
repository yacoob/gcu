#!/usr/bin/env python

import codecs
import collections
import dateutil.parser
import glob
import jinja2
import os
import sys
import yaml

def _keyFromFilename(fn):
    return os.path.splitext(os.path.basename(fn))[0]

def _loadKits(d):
    # TODO: w sumie to sluga możemy czytać z nazwy pliku
    data = {}
    for dirpath, dirnames, filenames in os.walk(root, followlinks=True):
        for fn in filenames:
            if not fn.endswith('.yaml'):
                continue
            fp = os.path.join(dirpath, fn)
            with open(fn) as f:
                parsed = yaml.load(f)
                data[_keyFromFilename(fn)] = collections.OrderedDict(
                    sorted(parsed.items(), key=lambda t: t[0]))
    return data
def _preprocess(data):
    gcu = {}
    gcu['data'] = data
    # gcu['posts'] = posts
    # gcu['grade_index'] = grade_index
    # gcu['newest'] = newest
    return gcu

def getEverything(d=None):
    return _preprocess(_loadKits(os.path.join(d, 'kits')))
