#!/usr/bin/perl
use strict;
use warnings;

# The same as the previous example but now in a horizontal organization using HBox

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->signal_connect (destroy => sub { Gtk2->main_quit; });


# We create the HBox
my $hbox = Gtk2::HBox->new();
$hbox->set("border_width"=> 10); #optionally we set the border width
$window->add($hbox);

my $label = Gtk2::Label->new("Hello world!");
$hbox->pack_start($label, 0, 0, 5);

my $button = Gtk2::Button->new("Exit");
$button->signal_connect(clicked=> \&handle_exit_button);
$hbox->pack_start($button, 0, 0, 5);

$window->show_all();
Gtk2->main;

sub handle_exit_button {
	print "Exiting...\n";
	Gtk2->main_quit;
}
