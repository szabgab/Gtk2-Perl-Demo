#!/usr/bin/perl
use strict;
use warnings;

# Simple window with a label on it
# The first real example where we already put a widget in the window
# is the usual "Hello World" example. Here we add a single label widget
# to the main window.

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

# Create a label widget with the string "Hello world!" on it
# and add it to the window
my $label = Gtk2::Label->new("Hello world!");
$window->add($label);

$window->show_all();
Gtk2->main;

