#!/usr/bin/env python

import codecs
import email
import os
import shutil
import jinja2


SPECIAL_PAGES = {
    '404.html': '404.j2',
    'everything/index.html': 'everything.j2',
    'index.html': 'mainpage.j2',
    'index.xml': 'rss.j2',
    'robots.txt': 'robots_txt.j2',
    'sitemap.xml': 'sitemap.j2',
}
DEFAULT_BASE_URL = 'https://gcu.tactical-grace.net'
BASE_URL_ENV_NAME = 'GCU_BASE_URL'


class Renderer(object):
    def __init__(self, d):
        def fancyGradeFilter(grade):
            if len(grade) == 2:
                return grade.upper()
            else:
                return grade.capitalize()

        def datetimeToRFC822(dt):
            return email.Utils.formatdate(float(dt.strftime('%s')))

        def datetimeToISO(dt):
            return dt.isoformat()

        def datetimeToShortDate(dt):
            return dt.strftime('%Y-%m-%d')

        def entryNumberedImageLink(url, n):
            return url.rsplit('#',1)[0] + '#p/%s' % n



        self.jinja = jinja2.Environment(
            trim_blocks=True, lstrip_blocks=True,
            loader=jinja2.FileSystemLoader(d))
        if BASE_URL_ENV_NAME in os.environ:
            base_url = os.environ[BASE_URL_ENV_NAME]
        else:
            base_url = DEFAULT_BASE_URL
        self.jinja.globals['base_url'] = base_url
        self.jinja.filters['datetime_to_iso'] = datetimeToISO
        self.jinja.filters['datetime_to_rfc822'] = datetimeToRFC822
        self.jinja.filters['entry_image_link'] = entryNumberedImageLink
        self.jinja.filters['short_date'] = datetimeToShortDate
        self.jinja.filters['fancy_grade'] = fancyGradeFilter

    def render(self, fn, tmpl_fn=None, **kwargs):
        try:
            os.makedirs(os.path.dirname(fn))
        except OSError, e:
            if e.errno == 17:
                pass
        with codecs.open(fn, 'w', 'utf-8') as f:
            if tmpl_fn:
                template = self.jinja.get_template(tmpl_fn)
                f.write(template.render(**kwargs))
            f.close()


def renderEverything(d=None, gcu=None):
    outdir = os.path.join(d, 'public')
    r = Renderer(os.path.join(d, 'templates'))

    # Remove old output.
    # Can't just rmtree outdir, as we want httpd to reuse it. Need to remove
    # outdir/* instead.
    for p in os.listdir(outdir):
        fp = os.path.join(outdir, p)
        if os.path.isfile(fp) or os.path.islink(fp):
            os.remove(fp)
            continue
        if os.path.isdir(fp):
            shutil.rmtree(fp)
            continue
        raise RuntimeError('Unexpected item: %s is not a file, symlink or a directory' % fp)

    # copy static content
    static_dir = os.path.join(d, 'static')
    for item in os.listdir(static_dir):
        src = os.path.join(static_dir, item)
        dst = os.path.join(outdir, item)
        if os.path.isdir(src):
            shutil.copytree(src, dst)
        else:
            shutil.copy2(src, dst)


    sitemap_urls = []
    # for every grade:
    for (grade, kits) in gcu['grade_index'].items():
        # render a page with all kits
        r.render(
            os.path.join(outdir, grade, 'index.html'),
            tmpl_fn='grade.j2', gcu=gcu, grade=grade)
        # for every kit:
        for kit in kits:
            # render a kit page with all entries
            r.render(
                os.path.join(outdir, grade, kit['slug'], 'index.html'),
                tmpl_fn='kit.j2', gcu=gcu, grade=grade, kit=kit)
            sitemap_urls.append((
                '/%s/%s/' % (grade, kit['slug']), kit['last_updated']))
        latest_grade_post_date = max(
            [x[1] for x in sitemap_urls
             if x[0].startswith('/%s/' % grade)])
        sitemap_urls.append(('/%s/' % grade, latest_grade_post_date))

    # generate special pages
    last_site_update_date = gcu['newest_kits'][0]['last_updated']
    for (fn, tmpl) in SPECIAL_PAGES.items():
        r.render(
            os.path.join(outdir, fn),
            tmpl_fn=tmpl, gcu=gcu, last_site_update_date=last_site_update_date,
            sitemap_urls=sitemap_urls)

    # symlink photo dir
    os.symlink(os.path.join(d, 'photo'), os.path.join(outdir, 'p'))

    # chmod a+rX for a good measure
    for root, dirs, files in os.walk(outdir, followlinks=False):
        for d in dirs:
            os.chmod(os.path.join(root, d), 0755)
        for f in files:
            os.chmod(os.path.join(root, f), 0644)
