#!/usr/bin/env python

import data
import render

import os

WORKDIR = os.curdir


def main():
    render.renderEverything(d=WORKDIR, gcu=data.getEverything(d=WORKDIR))


if __name__ == '__main__':
    main()
