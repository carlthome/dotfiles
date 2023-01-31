#!/bin/sh
set -e

perl -wE 'my @xs; for (1..2**20) { push @xs, q{a} x 2**20 }; say scalar @xs;'
