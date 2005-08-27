use strict;
use warnings;

use Gtk2 -init;
use Gtk2::GladeXML;
use Phonebook;
my $gladexml = Gtk2::GladeXML->new("phonebook/phonebook.glade");
$gladexml->signal_autoconnect_from_package("Phonebook");
Gtk2->main;



