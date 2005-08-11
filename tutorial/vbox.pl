#!/usr/bin/perl
use strict;
use warnings;

# So we had two exaples already one with a label and one with a button
# Let's combine them.
# As it turns out a Window can hold only one Widget in it.
# In order to put both a label and a button on the Window we need to use
# a Widget holder that can contain more than one Widgets such as a VBox.

# A VBox or Vertical Box can hold as many child widgets as you want and
# will render them one below the other.

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->signal_connect (destroy => \&handle_exit);


# We create the VBox
my $vbox = Gtk2::VBox->new();
# optionally we set the border width
#$vbox->set("border_width"=> 10);

# and add the vbox to the window
$window->add($vbox);

# now we can create a label and a button and add them to the vbox
my $label = Gtk2::Label->new("Hello world!");
$vbox->add($label);

my $button = Gtk2::Button->new("Exit");
$button->signal_connect(clicked=> \&handle_exit);
$vbox->add($button);

$window->show_all();
Gtk2->main;

sub handle_exit {
	print "Exiting...\n";
	Gtk2->main_quit;
}

