#!/usr/bin/env python

import argparse
import datetime
import os
import threading
import traceback
import time
import BaseHTTPServer
import SimpleHTTPServer

import data
import render

from watchdog import observers, events

WORKDIR = os.path.abspath(os.path.curdir)
IGNORED_FILES = ('*~', '.*.swp', '.*.swo')
gcu_data = None
dataLock = threading.Lock()


def _tsprint(s):
    """Helper: print s with a timestamp in front of it."""
    print '%s %s' % (datetime.datetime.now(), s)


def reloadData():
    global gcu_data
    dataLock.acquire()
    _tsprint('loading data')
    gcu_data = data.getEverything(WORKDIR)
    dataLock.release()


def renderSite(outdir=None, skip_static=False):
    if not outdir:
        raise ValueError('output directory needs to be set, is %s' % outdir)
    dataLock.acquire()
    _tsprint('rendering site')
    render.renderEverything(WORKDIR, gcu_data, outdir, skip_static)
    _tsprint('site rendered')
    dataLock.release()


class GCUFileChangedHandler(events.PatternMatchingEventHandler):
    """File event handler for fs watcher. Watches files only, on event
    optionally reloads GCU data and rerenders everything."""

    def __init__(self, reload_data=False, outdir=None, **kwargs):
        self.outdir = outdir
        self.reload_data = reload_data
        super(GCUFileChangedHandler, self).__init__(**kwargs)

    def on_any_event(self, event):
        _tsprint(event)
        try:
            if self.reload_data:
                reloadData()
            renderSite(self.outdir)
        except Exception:
            traceback.print_exc()
            os._exit(1)


def build(output_dir, skip_static):
    reloadData()
    renderSite(output_dir, skip_static)


def serve_cmd(args):
    outdir = os.path.join(WORKDIR, 'public')
    build(outdir, False)
    os.chdir(outdir)
    server = BaseHTTPServer.HTTPServer(
        ('', 8000), SimpleHTTPServer.SimpleHTTPRequestHandler)
    thread = threading.Thread(target=server.serve_forever)
    thread.daemon = True
    thread.start()
    observer = observers.Observer()
    observer.schedule(GCUFileChangedHandler(patterns=('*.yaml', ),
                                            ignore_patterns=IGNORED_FILES,
                                            outdir=outdir,
                                            reload_data=True),
                      os.path.join(WORKDIR, 'kits'),
                      recursive=True)
    observer.schedule(GCUFileChangedHandler(patterns=('*.j2', ),
                                            ignore_patterns=IGNORED_FILES,
                                            outdir=outdir),
                      os.path.join(WORKDIR, 'templates'),
                      recursive=True)
    observer.schedule(GCUFileChangedHandler(ignore_patterns=IGNORED_FILES,
                                            outdir=outdir),
                      os.path.join(WORKDIR, 'static'),
                      recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(10)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


def build_cmd(args):
    build(args.output_dir, args.skip_static)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()
    parser_build = subparsers.add_parser('build', help='render site')
    parser_build.add_argument('--output_dir',
                              default='public',
                              help='custom output directory (default: public)')
    parser_build.add_argument('--skip_static',
                              action='store_true',
                              help="don't copy static/ to the outputdir")
    parser_build.set_defaults(func=build_cmd)
    parser_serve = subparsers.add_parser(
        'serve', help='serve rendered site locally, update when input changes')
    parser_serve.set_defaults(func=serve_cmd)
    args = parser.parse_args()
    args.func(args)
