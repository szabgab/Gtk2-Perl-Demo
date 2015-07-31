#!/usr/bin/perl

use strict;
use warnings;
our $AUTOLOAD;
#my $VERSION =


use Gtk2 -init;
use Gtk2::GladeXML;
my $gladexml = Gtk2::GladeXML->new("editor.glade");
$gladexml->signal_autoconnect_from_package("main");
Gtk2->main;


AUTOLOAD {
	print $AUTOLOAD . "\n";
}

sub on_main_window_destroy {
	Gtk2->main_quit;
}

sub on_button1_clicked {
	my $text = $gladexml->get_widget('entry1')->get_text;
	$gladexml->get_widget('label1')->set_text($text)
}


