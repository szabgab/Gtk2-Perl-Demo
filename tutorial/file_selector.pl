#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->set_title ("File Selector");
$window->signal_connect (destroy => sub { Gtk2->main_quit; });
$window->set_default_size(200, 100);

my $hbox = Gtk2::HBox->new();
$window->add($hbox);

my $select_button = Gtk2::Button->new("Select");
$select_button->signal_connect(clicked => \&file_selector);
$hbox->pack_start($select_button, 1, 1, 5);

my $exit_button = Gtk2::Button->new("Exit");
$exit_button->signal_connect(clicked => sub { Gtk2->main_quit; });
$hbox->pack_start($exit_button, 0, 0, 5);

$window->show_all();
Gtk2->main;


sub file_selector {
	my $f = Gtk2::FileChooserDialog->new("File Selector", $window, "open",
				"gtk-cancel" => "cancel",
				"gtk-open"   => "accept",
					);
	my $response = $f->run();
	if ("accept"  eq $response) {
		print $f->get_filename(), "\n";
	}
	$f->destroy;
}
