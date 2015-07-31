#!/usr/bin/perl
use strict;
use warnings;

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->set_title ("Grid");
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

my $vbox = Gtk2::VBox->new();
$vbox->set("border_width"=> 10);
$window->add($vbox);

my $rows = 3;
my $cols = 4;
my @table;

my $table = Gtk2::Table->new($rows, $cols, 1);
foreach my $i (1..$rows) {
	foreach my $j (1..$cols) {
		my $entry = Gtk2::Entry->new();
		$table[$i-1][$j-1] = $entry;
		$table->attach_defaults($entry, $j-1, $j, $i-1, $i);
		$entry->signal_connect(changed => sub { print $_[0]->get_text . "\n";});
		$entry->signal_connect("focus-out-event" => \&lost_focus, [$i, $j]);

	}
}

sub lost_focus {
	my ($widget, $event, $loc) = @_;
	print "Lost: $$loc[0], $$loc[1]\n";
	return;
}

my $button = Gtk2::Button->new("Exit");
$button->signal_connect(clicked=> sub { print "bye\n"; Gtk2->main_quit; });

$vbox->pack_start($table, 0, 0, 5);
$vbox->pack_start($button, 0, 0, 5);
$window->show_all();

Gtk2->main;

