#!/usr/bin/perl
use strict;
use warnings;

# At times you will want to let a user type in some text and then do something
# with that text.

# Upon pressing a button, "Show" in our case you will read what is
# in the Entry box and do with it something. In our case we display the
# text in our label, just above the entry box.

use Gtk2 '-init';

# Now we also import some magic TRUE and FALSE values
# This is mainly a style issue inherited from the underlying C code
# but we can stay with it for better readability
use Glib qw/TRUE FALSE/;

my $window = Gtk2::Window->new;
$window->set_title ("User entry");
$window->signal_connect (destroy => \&handle_exit);

my $vbox = Gtk2::VBox->new();
#$vbox->set_border_width(50);
$window->add($vbox);


my $label = Gtk2::Label->new("");
$vbox->add($label);


my $entry = Gtk2::Entry->new();
$vbox->add($entry);


my $show_button = Gtk2::Button->new("Show");
$show_button->signal_connect(clicked=> \&show_button_clicked);
$vbox->add($show_button);


my $exit_button = Gtk2::Button->new("Exit");
$exit_button->signal_connect(clicked=> \&handle_exit);
$vbox->add($exit_button);

# This is somehow inconvenient. We are used to be able to type in text
# press ENTER and activate some default behavior. We can achive the same
# by using the following three lines:

# let the button be able to accept default behavior
#$show_button->can_default(TRUE);
# tell the entry box that when ENTER is pressed while the focus on it, it will
# activate the currently default widget
#$entry->set_activates_default (TRUE);
# finally set the currently default widget
#$window->set_default($show_button);

$window->show_all();
Gtk2->main;


# of course we could write this simple function in an anonymous
# subroutin and without the temporary variable
sub show_button_clicked { 
	my $text = $entry->get_text;
	$label->set_text($text);

	# To play with default buttons further, once you enable the 3 lines
	# above related to default button behavior you can also enable the
	# next two.
	# Once the user types in the word "exit" and presses ENTER the
	# application will replace the default button. So on the next ENTER
	# it will exit the application
	#$exit_button->can_default(TRUE);
	#$window->set_default($exit_button) if $text eq "exit";
}

sub handle_exit { Gtk2->main_quit; }

