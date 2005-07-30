#!/usr/bin/perl
use strict;
use warnings;

# Simple window with nothing on it
# This is the simplest application we can create, nothing just a window

# Loading the Gtk2 module with the "magic" -init paramter 
use Gtk2 '-init';

# Create a window object
my $window = Gtk2::Window->new;

# A signal handler, we will explain later, 
# for now we just make sure it is in our code
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

# Feel free to remove the # from the following lines and play with the values
#$window->set_title("Welcome to GTK+");
#$window->set_border_width(200);



# Ask the system to show the window, (though it will only show up when we start the main loop)
$window->show_all();


# Start the main loop
Gtk2->main;

