#!/usr/bin/env python

import codecs
import collections
import dateutil.parser
import glob
import jinja2
import os
import sys
import yaml

OBLIGATORY_FIELDS = ('entries', 'kit_cover', 'title')


def _loadKits(d):
    # There's a bug in PyYAML that makes it parse the timestamps to naive
    # datetime objects, discarding timezone information in the process.
    # Workaround courtessy of http://stackoverflow.com/a/13295663
    def timestamp_constructor(loader, node):
        return dateutil.parser.parse(node.value)
    yaml.add_constructor(u'tag:yaml.org,2002:timestamp', timestamp_constructor)
    data = {}
    for dirpath, dirnames, filenames in os.walk(d, followlinks=True):
        for filename in filenames:
            if not filename.endswith('.yaml'):
                continue
            fp = os.path.join(dirpath, filename)
            f = codecs.open(fp, 'r', 'utf-8')
            parsed = yaml.load(f)
            missing_fields = set(OBLIGATORY_FIELDS) - set(parsed.keys())
            if missing_fields:
                sys.exit(
                    'post %s malformed, doesn\'t contain following headers: %s'
                    % (fp, ', '.join([str(x) for x in missing_fields])))
            grade = dirpath[len(d)+1:].split(os.sep)[0]
            parsed['grade'] = grade
            slug = os.path.splitext(os.path.basename(fp))[0]
            parsed['slug'] = slug
            parsed['fp'] = fp
            data.setdefault(grade, []).append(parsed)
    return data


def _preprocess(data):
    newest = []
    for grade in data:
        data[grade] = sorted(data[grade], key=lambda x: x['slug'])
        for idx, kit in enumerate(data[grade]):
            # Add a canonical url to each kit.
            kit['canonical_url'] = '/%s/%s/' % (kit['grade'], kit['slug'])
            # Add prev/next links.
            if idx > 0:
                kit['prev'] = data[grade][idx-1]['slug']
            if idx + 1 < len(data[grade]):
                kit['next'] = data[grade][idx+1]['slug']
            # Create a list of newest posts, one per kit.
            last_post_date = sorted(kit['entries'].keys(), reverse=True)[0]
            newest.append((last_post_date, kit))
    newest = sorted(newest, reverse=True, key=lambda x: x[0])
    gcu = {}
    gcu['grade_index'] = data
    gcu['newest'] = newest
    return gcu


def getEverything(d=None):
    return _preprocess(_loadKits(os.path.join(d, 'kits')))
