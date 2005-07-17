#!/usr/bin/perl
use strict;
use warnings;

# So we had two exaples already one with a label and one with a button
# Let's combine them.
# As it turns out a Window can hold only one Widget in it.
# So in order to put both a label and a button on the Window we need a Widget
# holder that can contain more than one Widgets such as a VBox.

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->signal_connect (destroy => sub { Gtk2->main_quit; });


# We create the VBox
my $vbox = Gtk2::VBox->new();
$vbox->set("border_width"=> 10); #optionally we set the border width
$window->add($vbox);

my $label = Gtk2::Label->new("Hello world!");
$vbox->pack_start($label, 0, 0, 5);

my $button = Gtk2::Button->new("Exit");
$button->signal_connect(clicked=> \&handle_exit_button);
$vbox->pack_start($button, 0, 0, 5);

$window->show_all();
Gtk2->main;

sub handle_exit_button {
	print "Exiting...\n";
	Gtk2->main_quit;
}
