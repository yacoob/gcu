#!/usr/bin/env python

import codecs
import os
import sys
import yaml
import dateutil.parser

OBLIGATORY_FIELDS = ('entries', 'cover', 'title')


def _loadKits(d):
    # There's a bug in PyYAML that makes it parse the timestamps to naive
    # datetime objects, discarding timezone information in the process.
    # Workaround courtessy of http://stackoverflow.com/a/13295663
    def timestamp_constructor(loader, node):
        return dateutil.parser.parse(node.value)
    yaml.add_constructor(u'tag:yaml.org,2002:timestamp', timestamp_constructor)
    data = {}
    for dirpath, _, filenames in os.walk(d, followlinks=True):
        for filename in filenames:
            if not filename.endswith('.yaml'):
                continue
            fp = os.path.join(dirpath, filename)
            f = codecs.open(fp, 'r', 'utf-8')
            parsed = yaml.load(f)
            if parsed:
                missing_fields = set(OBLIGATORY_FIELDS) - set(parsed.keys())
            else:
                missing_fields = OBLIGATORY_FIELDS
            if missing_fields:
                sys.exit(
                    'post %s malformed, doesn\'t contain following headers: %s'
                    % (fp, ', '.join([str(x) for x in missing_fields])))
            grade = dirpath[len(d)+1:].split(os.sep)[0]
            parsed['grade'] = grade
            slug = os.path.splitext(os.path.basename(fp))[0]
            parsed['slug'] = slug
            parsed['fp'] = fp
            # Add a canonical url to each kit.
            parsed['canonical_url'] = '/%s/%s/' % (parsed['grade'], parsed['slug'])
            data.setdefault(grade, []).append(parsed)
    return data


def _preprocess(data):
    newest_kits = []
    newest_entries = []
    for grade in data:
        data[grade] = sorted(data[grade], key=lambda x: x['slug'])
        for idx, kit in enumerate(data[grade]):
            kit['entries'] = sorted(kit['entries'], key=lambda x: x['date'])
            # Add canonical urls to each entry.
            for entry in kit['entries']:
                entry['canonical_url'] = (
                    kit['canonical_url'] + '#' +
                    entry['date'].strftime('%Y-%m-%d'))
            # Add prev/next links.
            if idx > 0:
                kit['prev'] = data[grade][idx-1]['canonical_url']
            if idx + 1 < len(data[grade]):
                kit['next'] = data[grade][idx+1]['canonical_url']
            # Create a list of newest kits and newest entries.
            last_post_date = kit['entries'][-1]['date']
            kit['last_updated'] = last_post_date
            newest_kits.append(kit)
            for entry in kit['entries']:
                ec = entry.copy()
                ec['kit'] = kit['title']
                newest_entries.append(ec)
    newest_kits = sorted(
        newest_kits, reverse=True, key=lambda x: x['last_updated'])
    newest_entries = sorted(
        newest_entries, reverse=True, key=lambda x: x['date'])
    gcu = {}
    gcu['grade_index'] = data
    gcu['newest_kits'] = newest_kits
    gcu['newest_entries'] = newest_entries
    return gcu


def getEverything(d=None):
    return _preprocess(_loadKits(os.path.join(d, 'kits')))
