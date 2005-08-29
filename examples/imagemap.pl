#!/usr/bin/perl
use warnings;
use strict;
use Glib qw/TRUE FALSE/;
use Gtk2 '-init';

# create a new window
my $window = Gtk2::Window->new('toplevel');
$window->set_title("Pixmap'd Buttons!");
$window ->signal_connect( "destroy" => sub { Gtk2->main_quit; } );

# sets the border width of the window
$window->set_border_width(10);

my @zxpm = (
" 16 12 4 1 ",
"   s None  c None",
".  c black",
"X  c red",
"o  c #5B5B57574646",
"                ",
"  ...........   ",
"  XXXXXXXXXXX   ",
"         XXX    ",
"        XXX     ",
"       XXX      ",
"    ooXXXoo     ",
"     XXX        ",
"    XXX         ",
"   XXX          ",
"  XXXXXXXXXXXX  ",
"  ...........   "
);


# the stock id our stock item will be accessed with
my $stock_id = 'Z';

# add a new entry to the stock system with our id
#Gtk2::Stock->add ({
#    stock_id => $stock_id,
#    label    => 'Zentara',
    #modifier => [],
    #keyval   => $Gtk2::Gdk::Keysyms{L},
    #translation_domain => 'gtk2-perl-example',
#});

# create an icon set, with only one member in this particular case
#my $icon_set = Gtk2::IconSet->new_from_pixbuf (
#           Gtk2::Gdk::Pixbuf->new_from_xpm_data ( @zxpm ));

# create a new icon factory to handle rendering the image at various sizes...
#my $icon_factory = Gtk2::IconFactory->new;
# add our new stock icon to it...
#$icon_factory->add ($stock_id, $icon_set);
# and then add this custom icon factory to the list of default places in
# which to search for stock ids, so any gtk+ code can find our stock icon.
#$icon_factory->add_default;


# create a new button
#my $button = Gtk2::Button->new_from_stock('Z');

# connect the 'clicked' signal of the button to our callback
#$button->signal_connect( "clicked" => \&callback, "cool button" );

#$button->show();

#$window->add($button);
#
my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_xpm_data ( @zxpm );
my $image = Gtk2::Image->new_from_pixbuf($pixbuf);
#my @imagesize = $image->size;
#$window->add($image);

my $eventbox = Gtk2::EventBox->new;
$eventbox->add ($image);

$eventbox->add_events (['button-press-mask']);

$eventbox->signal_connect ('button-press-event' => 
    sub {
        my ($widget, $event) = @_;
	#use Data::Dumper;
	#print Dumper $event;
	#exit;
        my ($x, $y) = ($event->x, $event->y);
        # If the image is smaller than the window, we need to 
        # translate these window coords into the image coords.
        # Get the allocated size of the image first.
        # I assume that the image is always centered within the allocation.
        # Then the coords are transformed.
        # $imagesize is the actual size of the image (in this case the png image)
	#my @imageallocatedsize = $image->allocation->values;
	#$x -= ($imageallocatedsize[2] - $imagesize[0])/2;
	#$y -= ($imageallocatedsize[3] - $imagesize[1])/2;
	print "$x $y\n";
    }
);

=pod
$eventbox->add_events (['pointer-motion-mask', 'pointer-motion-hint-mask']);

$eventbox->signal_connect ('motion-notify-event' => 
    sub {
        my ($widget, $event) = @_;
        my ($x, $y) = ($event->x, $event->y);
        # If the image is smaller than the window, we need to 
        # translate these window coords into the image coords.
        # Get the allocated size of the image first.
        # I assume that the image is always centered within the allocation.
        # Then the coords are transformed.
        # $imagesize is the actual size of the image (in this case the png image)
	#my @imageallocatedsize = $image->allocation->values;
	#$x -= ($imageallocatedsize[2] - $imagesize[0])/2;
	#$y -= ($imageallocatedsize[3] - $imagesize[1])/2;
	print "$x $y\n";
    }
);
=cut


$window->add($eventbox);

$window->show_all();

# rest in the GTK main loop and wait for the fun to begin!
Gtk2->main;


# http://gtk2-perl.sourceforge.net/doc/pod/Gtk2/Gdk/Event.html


