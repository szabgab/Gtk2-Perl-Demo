#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';
use Glib qw/TRUE FALSE/;

my $window = Gtk2::Window->new;
$window->set_title ("User entry");
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

my $vbox = Gtk2::VBox->new();
$window->add($vbox);


my $label = Gtk2::Label->new("");
$vbox->add($label);


my $entry = Gtk2::Entry->new();
$vbox->add($entry);

my $password = Gtk2::Entry->new();
$password->set_visibility(0);
$vbox->add($password);

my $show_button = Gtk2::Button->new("Show");
$show_button->signal_connect(clicked=> \&show_button_clicked);
$vbox->add($show_button);


my $exit_button = Gtk2::Button->new("Exit");
$exit_button->signal_connect(clicked=> sub { Gtk2->main_quit; });
$vbox->add($exit_button);

$window->show_all();
Gtk2->main;


sub show_button_clicked { 
	my $text = $entry->get_text . " / " . $password->get_text;
	$label->set_text($text);
}

