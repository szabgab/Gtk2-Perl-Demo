#!/usr/bin/perl
use strict;
use warnings;


# Some people don't like to close applications using the [x] button as they
# fear (sometimes correctly) that the application might not save their data
# or will show some other incorrect behavior.
# So let's provide them a button that can be used to exit the application.

# We replaced the Label creation by a Button creation.
# added s signal handler to the button to handle events of type "clicked"
# that will quite the application
# Then we add the button to the window.


use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

my $button = Gtk2::Button->new("Exit");
$button->signal_connect(clicked=> sub { Gtk2->main_quit; });
$window->add($button);

$window->show_all();
Gtk2->main;

