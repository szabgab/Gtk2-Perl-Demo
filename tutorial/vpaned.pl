#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->signal_connect (destroy => \&handle_exit);

# The window is resizable
my $main = Gtk2::VBox->new();

# Replace the above line with this one.
# The windows is resizable and the user can also change the relative size of
# the windows
#my $main = Gtk2::VPaned->new();




$window->add($main);
$window->set_default_size(300, 250);


my $upper_buffer   = Gtk2::TextBuffer->new();
my $upper_textview = Gtk2::TextView->new_with_buffer($upper_buffer);
$upper_buffer->insert($upper_buffer->get_iter_at_line(0), "Upper text");
$main->add($upper_textview);

my $lower_buffer   = Gtk2::TextBuffer->new();
my $lower_textview = Gtk2::TextView->new_with_buffer($lower_buffer);
$lower_buffer->insert($lower_buffer->get_iter_at_line(0), "Lower text");
$main->add($lower_textview);


$window->show_all();
Gtk2->main;

sub handle_exit { 
	Gtk2->main_quit; 
}
