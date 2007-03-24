#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->set_title ("File Selector");
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

my $button = Gtk2::Button->new("Select");
$button->signal_connect(clicked => \&file_selector);
$window->add($button);
$window->show_all();

Gtk2->main;

sub file_selector {
	my $f = Gtk2::FileChooserDialog->new("FS", $window, "open",
				"Cancel" => "cancel",
				"OK"     => "accept",
					);
	my $response = $f->run();
	if ("accept"  eq $response) {
		print $f->get_filename(), "\n";
	}
	$f->destroy;
}


