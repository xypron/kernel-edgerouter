#!/bin/sh
make prepare
make clean
dpkg-buildpackage
