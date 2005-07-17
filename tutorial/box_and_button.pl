#!/usr/bin/perl
use strict;
use warnings;

# At times you will want to let a user type in some text.
# Upon pressing a button, "Show" in our case you will read what is
# in the Entry box and do with it something. In our case we display the
# text in our label, just above the entry box.

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->set_title ("User entry");
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

my $vbox = Gtk2::VBox->new();
#$vbox->set("border_width"=> 50);
$window->add($vbox);


my $label = Gtk2::Label->new("");
$vbox->pack_start($label, 0, 0, 5);


my $entry = Gtk2::Entry->new();
$vbox->pack_start($entry, 0, 0, 5);


my $show_button = Gtk2::Button->new("Show");
$show_button->signal_connect(clicked=> \&show_button_clicked);
$vbox->pack_start($show_button, 0, 0, 5);


my $exit_button = Gtk2::Button->new("Exit");
$exit_button->signal_connect(clicked=> sub { Gtk2->main_quit; });
$vbox->pack_start($exit_button, 0, 0, 5);


$window->show_all();
Gtk2->main;


# of course we could write this simple function in an anonymous
# subroutin and without the temporary variable
sub show_button_clicked { 
	my $text = $entry->get_text;
	$label->set_text($text);
}



