#!/usr/bin/env python

import codecs
import collections
import glob
import jinja2
import os
import sys
import yaml

OBLIGATORY_META_FIELDS = ('cover_img', 'date', 'slug')
KNOWN_META_FIELDS = ('aliases',) + OBLIGATORY_META_FIELDS


def _keyFromFilename(fn):
    return os.path.splitext(os.path.basename(fn))[0]


def _loadKitData(d):
    data = {}
    for fn in glob.iglob(os.path.join(d, '*.yaml')):
        with open(fn) as f:
            parsed = yaml.load(f)
            data[_keyFromFilename(fn)] = collections.OrderedDict(
                sorted(parsed.items(), key=lambda t: t[0]))
    return data


def _loadPosts(d, tmpl_dir):
    posts = {}
    with codecs.open(os.path.join(tmpl_dir, 'macros.j2'), 'r', 'utf-8') as mf:
        macros = mf.read()
    for fn in glob.iglob(os.path.join(d, '*.md')):
        with codecs.open(fn, 'r', 'utf-8') as f:
            fc = f.read()
            if fc.count('---') < 2:
                sys.exit(
                    'post %s malformed, doesn\'t contain two \'---\' markers'
                    % fn)
                continue
            post = {}
            yaml_bit, md_bit = fc.split('---', 2)[1:]
            post['meta'] = yaml.load(yaml_bit)
            missing_meta_fields = set(
                    OBLIGATORY_META_FIELDS) - set(post['meta'].keys())
            if missing_meta_fields:
                sys.exit(
                    'post %s malformed, doesn\'t contain following headers: %s'
                    % (fn, ', '.join([str(x) for x in missing_meta_fields])))
            post_tmpl = jinja2.Template(macros + md_bit.strip())
            post['content'] = post_tmpl.render().strip()
            post['fn'] = fn
            posts[_keyFromFilename(fn)] = post
    return collections.OrderedDict(sorted(
        posts.items(), reverse=True, key=lambda t: t[1]['meta']['date']))


def _preprocess(data, posts):
    # Add a canonical url to each kit
    for (grade, kits) in data.items():
        kit_names = kits.keys()
        for idx, kit in enumerate(kits):
            if idx + 1 < len(kit_names):
                data[grade][kit]['next'] = kit_names[idx + 1]
            data[grade][kit]['canonical_url'] = '/%s/%s/' % (grade, kit)
            if idx > 0:
                data[grade][kit]['prev'] = kit_names[idx - 1]

    # Build a grade -> kit -> posts index, a flat post -> kits index, set some
    # convenience fields for each post.
    grade_index = {}
    for (post_key, post) in posts.items():
        post['short_date'] = post['meta']['date'].strftime('%Y-%m-%d')
        post['kits'] = []
        for (grade, kit_list) in post['meta'].items():
            # Is this field actually a grade?
            if grade in KNOWN_META_FIELDS:
                continue
            # Is this grade present in data/ ?
            if grade not in data.keys():
                sys.exit(
                    'post %s malformed, grade "%s" not present under data/'
                    % (post['fn'], grade))
            # Is this field's content populated with kit names?
            if type(kit_list) is not list:
                continue
            kits = grade_index.setdefault(grade, {})
            for kit in kit_list:
                # Is this kit present in data/ ?
                if kit not in data[grade]:
                    sys.exit(
                        'post %s malformed, kit "%s" not present under '
                        'data/%s.yaml' % (post['fn'], kit, grade))
                if 'redir_url' not in post:
                    post['redir_url'] = '%s#%s' % (
                        data[grade][kit]['canonical_url'],
                        post['short_date'])
                kits.setdefault(kit, []).append(post_key)
            grade_index[grade] = kits

    # Determine the newest kits to show on the main page.
    newest = []
    for (grade, kits) in grade_index.items():
        for (kit, kit_posts) in kits.items():
            lpk = sorted(kit_posts, reverse=True)[0]
            newest.append((posts[lpk], data[grade][kit]['title']))
    newest = sorted(newest, reverse=True, key=lambda x: x[0]['short_date'])

    gcu = {}
    gcu['data'] = data
    gcu['posts'] = posts
    gcu['grade_index'] = grade_index
    gcu['newest'] = newest
    return gcu


def getEverything(d=None):
    return _preprocess(
        _loadKitData(os.path.join(d, 'data')),
        _loadPosts(os.path.join(d, 'posts'), os.path.join(d, 'templates')))
