#!/usr/bin/env python

import datetime
import os
import sys
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


def renderSite():
    dataLock.acquire()
    _tsprint('rendering site')
    render.renderEverything(WORKDIR, gcu_data)
    _tsprint('site rendered')
    dataLock.release()


class GCUFileChangedHandler(events.PatternMatchingEventHandler):
    """File event handler for fs watcher. Watches files only, on event
    optionally reloads GCU data and rerenders everything."""

    def __init__(self, reload_data=False, **kwargs):
        self.reload_data = reload_data
        super(GCUFileChangedHandler, self).__init__(**kwargs)

    def on_any_event(self, event):
        _tsprint(event)
        try:
            if self.reload_data:
                reloadData()
            renderSite()
        except Exception:
            traceback.print_exc()
            os._exit(1)


def serve():
    os.chdir(os.path.join(WORKDIR, 'public'))
    server = BaseHTTPServer.HTTPServer(
        ('', 8000), SimpleHTTPServer.SimpleHTTPRequestHandler)
    thread = threading.Thread(target=server.serve_forever)
    thread.daemon = True
    thread.start()


def watch():
    once()
    serve()
    observer = observers.Observer()
    observer.schedule(GCUFileChangedHandler(patterns=('*.yaml', ),
                                            ignore_patterns=IGNORED_FILES,
                                            reload_data=True),
                      os.path.join(WORKDIR, 'kits'),
                      recursive=True)
    observer.schedule(GCUFileChangedHandler(patterns=('*.j2', ),
                                            ignore_patterns=IGNORED_FILES),
                      os.path.join(WORKDIR, 'templates'),
                      recursive=True)
    observer.schedule(GCUFileChangedHandler(ignore_patterns=IGNORED_FILES),
                      os.path.join(WORKDIR, 'static'),
                      recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(10)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


def once():
    reloadData()
    renderSite()


def print_usage():
    print """Usage: %s COMMAND [ARGS]
Commands:
    build [outputdir] - renders site to outputdir ('public/' by default)
    serve             - renders site, serves it locally, updates when input
                        changes
""" % sys.argv[0]


if __name__ == '__main__':
    if len(sys.argv) > 1:
        if sys.argv[1] == 'serve':
            watch()
        elif sys.argv[1] == 'build':
            once()
        else:
            print_usage()
    else:
        print_usage()
