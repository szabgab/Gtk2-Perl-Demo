#!/usr/bin/perl
use strict;
use warnings;


# Some people don't like to close applications using the [x] button as they
# fear (sometimes correctly) that the application might not save their data
# or will show some other incorrect behavior.
# So let's provide them a button that can be used to exit the application.

# We replaced the Label creation by a Button creation.
# added s signal handler to the button to handle events of type "clicked"
# that will quite the application
# Then we add the button to the window.


use Gtk2 '-init';

my $window = Gtk2::Window->new;
$window->signal_connect (destroy => sub { Gtk2->main_quit; });

my $button = Gtk2::Button->new("Exit");

# this is the same as 
# my $button = Gtk2::Button->new_with_label("Exit");

# A better approach is to use mnemonic.
# In this case we can add an _ infront of one of the characters.
# GTK automatically will mark the character with an undeline and create an
# accelerator Alt-   with the given letter.
# In our case Alt-x will invoke the button and exit the application.
#my $button = Gtk2::Button->new_with_mnemonic("E_xit");


# Probably the best approach is to use stock item.
# There are many stock items 
# (see gtk-Stock-Items.html in the documentation)
#my $button = Gtk2::Button->new_from_stock("gtk-quit");


# Style
#$button->set_relief('half');   # normal, half, none    normal is the default


$button->signal_connect(clicked=> sub { Gtk2->main_quit; });
$window->add($button);

$window->show_all();
Gtk2->main;



