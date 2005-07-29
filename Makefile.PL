#!/usr/bin/perl -w
use strict;
use warnings;

use ExtUtils::MakeMaker;

my @make = (
	NAME          => 'Gtk2-Perl-Demo',
	VERSION_FROM  => 'gtk-perl-demo.pl',
	PREREQ_PM     => {
		Gtk2  => '1.01'
	},
);

WriteMakefile(@make);
