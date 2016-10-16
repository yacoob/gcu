#!/usr/bin/env python

import codecs
import datetime
import jinja2
import os
import pytz
import re
import tzlocal

WORKDIR = os.curdir
TMPL = jinja2.Template("""---
date: {{ now }}
slug: {{ slug }}
xg:
 - awesome-gundam
cover_img: //urlwithoutprotocol
---
{% raw -%}
{{ photo(title='witty description', href='//urlwithoutprotocol') }}
{%- endraw -%}
""")

post_name = raw_input('Name of your new post? ')
slug = re.sub('\W+', '-', post_name)
now = datetime.datetime.now(tzlocal.get_localzone())
fn = '%s.%s' % (now.strftime('%Y-%m-%d'), slug.replace('-', '.'))

with codecs.open(os.path.join(WORKDIR, 'posts', fn + '.md'),
                 'w', 'utf-8') as f:
    f.write(TMPL.render(now=now.isoformat(), slug=slug))
