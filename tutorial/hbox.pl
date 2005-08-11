#!/usr/bin/perl
use strict;
use warnings;

# Similary to the previous example we can use an HBox (Horizontal Box) 
# That will render the widgets we put in it, well horizontally

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->signal_connect (destroy => \&handle_exit);


# We create the HBox
my $hbox = Gtk2::HBox->new();
$hbox->set("border_width"=> 10); #optionally we set the border width
$window->add($hbox);

my $label = Gtk2::Label->new("Hello world!");
$hbox->add($label);

my $button = Gtk2::Button->new("Exit");
$button->signal_connect(clicked=> \&handle_exit);
$hbox->add($button);

$window->show_all();
Gtk2->main;

sub handle_exit {
	print "Exiting...\n";
	Gtk2->main_quit;
}
