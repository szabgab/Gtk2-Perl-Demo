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

my $button1 = Gtk2::Button->new("One");
$button1->signal_connect(clicked=> sub {$button1->set_label("None")});
my $button2 = Gtk2::Button->new("Two");
$button2->signal_connect(clicked=> sub {$button2->set_label("None")});

my $exit_button = Gtk2::Button->new("Exit");
$exit_button->signal_connect(clicked=> sub { Gtk2->main_quit; });

my $notebook = Gtk2::Notebook->new();
#$notebook->set_tab_hborder(30);
$vbox->add($notebook);
$notebook->append_page($button1, "left");
$notebook->append_page($exit_button, "middle");
$notebook->append_page($button2, "right");


$window->show_all();
Gtk2->main;


