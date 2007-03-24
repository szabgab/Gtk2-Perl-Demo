#!/usr/bin/perl -w

use strict;
use Time::HiRes qw(gettimeofday tv_interval);

my $t0 = [gettimeofday];
require Glib; Glib->import;
my $t1 = [gettimeofday];
require Gtk2; Gtk2->import;
my $t2 = [gettimeofday];
Gtk2->init;
my $t3 = [gettimeofday];

print "\n";
printf "time to load Glib %s: %.3fs\n", $Glib::VERSION, tv_interval($t0, $t1);
printf "time to load Gtk2 %s: %.3fs\n", $Gtk2::VERSION, tv_interval($t1, $t2);
printf "time for Gtk2->init:     %.3fs\n", tv_interval($t2, $t3);
printf "total startup time:      %.3fs\n", tv_interval($t0, $t3);

# The versions of the libs against which the bindings were built determine
# how many classes there are to be initialized at startup time.  The version
# info stuff appeared in 1.040.
print "   Glib built for ".join(".", Glib->GET_VERSION_INFO).", running with "
    .join(".", &Glib::major_version, &Glib::minor_version, &Glib::micro_version)
    ."\n"
  if $Glib::VERSION >= 1.040;
print "   Gtk2 built for ".join(".", Gtk2->GET_VERSION_INFO).", running with "
    .join(".", &Gtk2::major_version, &Gtk2::minor_version, &Gtk2::micro_version)
    ."\n"
  if $Gtk2::VERSION >= 1.040;
print "\n";

