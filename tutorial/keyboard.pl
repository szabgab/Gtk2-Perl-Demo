#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
use Gtk2::Gdk::Keysyms;

my $window = Gtk2::Window->new;

# http://gtk2-perl.sourceforge.net/doc/pod/Gtk2/Gdk/Keysyms.html
#

my %Values = reverse %Gtk2::Gdk::Keysyms;
#print  keys(%Gtk2::Gdk::Keysyms) . "\n"; # 1337
#print keys(%Values) . "\n";           # 1255

sub duplicate_keynames {
	my %v;
	foreach my $k (keys %Gtk2::Gdk::Keysyms) {
		if ($v{$Gtk2::Gdk::Keysyms{$k}}) {
			print $v{$Gtk2::Gdk::Keysyms{$k}}, "    $k\n";
		}
		$v{$Gtk2::Gdk::Keysyms{$k}} = $k;
	}
}

# How can we catch double-keys such as Ctr-C ?

#print $Gtk2::Gdk::Keysyms{Escape}, "\n";
#print $Gtk2::Gdk::Keysyms{F1}, "\n";

$window->signal_connect (key_press_event => sub {
    my ($widget, $event) = @_;
    print "Keyval: ", $event->keyval, "\n";
    print "Name  : ", $Values{$event->keyval}, "\n"; 
    #return  unless $event->keyval == $Gtk2::Gdk::Keysyms{Escape};
    return 0;
});




$window->set_title ("User entry");
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

my $vbox = Gtk2::VBox->new();
$window->add($vbox);


$window->show_all();
Gtk2->main;

