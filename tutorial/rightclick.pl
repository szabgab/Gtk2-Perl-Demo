#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper qw(Dumper);

# Written by Gabor Szabo
# Based on an example from Jens Luedicke

use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->set_title ("Right click");
$window->signal_connect (destroy => \&handle_exit);

my $vbox = Gtk2::VBox->new();
$vbox->set("border_width"=> 10);
$window->add($vbox);

my $button = Gtk2::Button->new("Right-click to show popup or left-click to Exit");
$button->signal_connect(clicked => \&handle_exit);
$button->signal_connect(button_press_event => \&handle_clicks);

$vbox->pack_start($button, 0, 0, 5);
$window->show_all();

Gtk2->main;



sub handle_clicks {
	my ($check, $event) = @_;

	if (3 eq $event->button) {
		print "right click pressed\n";


		# do your stuff...
		my $item_factory = Gtk2::ItemFactory->new("Gtk2::Menu", '<main>', undef);
		my $popup_menu = $item_factory->get_widget('<main>');

		my @menu_items = (
			{ path => '/Copy',    item_type => '<Item>',       callback => \&foo, callback_action => 1},
			{ path => '/Move',    item_type => '<Item>',       callback => \&foo, callback_action => 2},
			{ path => '/sep1',    item_type => '<Separator>'},
			{ path => '/Rename',  item_type => '<Item>',       callback => \&foo, callback_action => 3},
			{ path => '/sep2',    item_type => '<Separator>'},
			{ path => '/Exit',    item_type => '<Item>',       callback => \&foo, callback_action => 4},
		);

		$item_factory->create_items(undef, @menu_items);
		$popup_menu->show_all;
		$popup_menu->popup(undef, undef, undef, undef, 0, 0);

		# block event propagation
		return 1;
	}
			
	# let the event chain proceed
	return 0;
}

sub foo {
	my ($param, $callback_action, $widget) = @_;  
	#print "P: $param\n";
	#print "E: $callback_action\n";
	#print "W: $widget\n";            # Gtk2::MenuItem
	print Dumper @_;

	if (4 == $callback_action) {
		print "Bye-Bye\n";
		Gtk2->main_quit;
	}
}
sub handle_exit { 
	print "bye\n"; 
	Gtk2->main_quit; 
}
